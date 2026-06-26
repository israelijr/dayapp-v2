import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/chapter_export_document.dart';
import '../domain/export_block.dart';

class ChapterPdfExportService {
  const ChapterPdfExportService();

  // Parâmetro ajustável para o limite absoluto de segurança de blocos por parte de arquivo
  static const int _maxBlocks = 5000;

  /// Exporta o capítulo como um arquivo HTML básico (Título, período, blocos).
  /// Permite opcionalmente adicionar sufixo ao nome do arquivo e título customizado.
  Future<File> exportHtml({
    required ChapterExportDocument document,
    required String localeName,
    required String storyCountLabel,
    String? partSuffix,
    String? partTitle,
  }) async {
    _validateExportLimits(document, localeName);

    final displayTitle = partTitle ?? document.chapterTitle;

    final buffer = StringBuffer();
    buffer.writeln('<!doctype html>');
    buffer.writeln('<html lang="${_normalizeLocale(localeName)}">');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln(
      '<meta name="viewport" content="width=device-width,initial-scale=1">',
    );
    buffer.writeln('<title>${_escapeHtml(displayTitle)}</title>');
    buffer.writeln('<style>');
    buffer.writeln('/* Configuração de páginas físicas A4 e quebras de página */');
    buffer.writeln('@page { size: A4; margin: 20mm 15mm; }');
    buffer.writeln('body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; line-height: 1.6; font-size: 14px; max-width: 800px; margin: 0 auto; padding: 20px; color: #222; }');
    buffer.writeln('h1 { font-family: Noto Serif, serif; font-size: 28px; margin: 0 0 8px; page-break-after: avoid; break-after: avoid; }');
    buffer.writeln('h2 { font-family: Noto Serif, serif; font-size: 20px; margin: 24px 0 8px; page-break-after: avoid; break-after: avoid; }');
    buffer.writeln('.meta { color: #666; font-size: 12px; margin-bottom: 12px; page-break-after: avoid; break-after: avoid; }');
    buffer.writeln('.cover { max-width: 100%; max-height: 250px; border-radius: 8px; overflow: hidden; margin-bottom: 16px; page-break-inside: avoid; break-inside: avoid; }');
    buffer.writeln('.cover img { width: 100%; height: 250px; object-fit: cover; }');
    buffer.writeln('.image-block { max-width: 350px; margin: 12px auto; page-break-inside: avoid; break-inside: avoid; text-align: center; }');
    buffer.writeln('.image { max-width: 100%; height: auto; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }');
    buffer.writeln('.caption { color: #666; font-size: 11px; margin-top: 4px; line-height: 1.3; }');
    buffer.writeln('p { margin: 8px 0; orphans: 3; widows: 3; }');
    buffer.writeln('/* Estilo de grid para imagens consecutivas (tipo jornal) */');
    buffer.writeln('.image-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin: 16px 0; page-break-inside: avoid; break-inside: avoid; }');
    buffer.writeln('.grid-item { display: flex; flex-direction: column; align-items: center; }');
    buffer.writeln('.grid-item .image { width: 100%; height: 120px; object-fit: cover; }');
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    buffer.writeln('<h1>${_escapeHtml(displayTitle)}</h1>');
    buffer.writeln(
      '<div class="meta">${_escapeHtml(_buildPeriodLabel(document, localeName))} • ${_escapeHtml(storyCountLabel)}</div>',
    );

    // Cover (embed as data URI so HTML is self-contained)
    if (document.coverImagePath != null &&
        document.coverImagePath!.isNotEmpty) {
      final dataUri = await _imageFileToDataUri(document.coverImagePath!);
      if (dataUri != null) {
        buffer.writeln(
          '<div class="cover"><img class="image" src="$dataUri" alt="cover"></div>',
        );
      }
    }

    int i = 0;
    while (i < document.blocks.length) {
      final block = document.blocks[i];
      if (block is TitleExportBlock) {
        buffer.writeln('<h2>${_escapeHtml(block.text)}</h2>');
        i++;
      } else if (block is DateExportBlock) {
        buffer.writeln(
          '<div class="meta">${_escapeHtml(DateFormat('dd/MM/yyyy', localeName).format(block.date))}</div>',
        );
        i++;
      } else if (block is ParagraphExportBlock) {
        buffer.writeln('<p>${_escapeHtml(block.text)}</p>');
        i++;
      } else if (block is ImageExportBlock) {
        final consecutiveImages = <ImageExportBlock>[];
        while (i < document.blocks.length && document.blocks[i] is ImageExportBlock) {
          consecutiveImages.add(document.blocks[i] as ImageExportBlock);
          i++;
        }

        if (consecutiveImages.length == 1) {
          final imgBlock = consecutiveImages.first;
          final pathSafe = _escapeHtmlAttr(imgBlock.imagePath);
          if (pathSafe.isNotEmpty) {
            final dataUri = await _imageFileToDataUri(imgBlock.imagePath);
            buffer.writeln('<div class="image-block">');
            if (dataUri != null) {
              buffer.writeln('<img class="image" src="$dataUri" alt="image">');
            }
            if (imgBlock.caption != null && imgBlock.caption!.isNotEmpty) {
              buffer.writeln(
                '<div class="caption">${_escapeHtml(imgBlock.caption!)}</div>',
              );
            }
            buffer.writeln('</div>');
          }
        } else if (consecutiveImages.isNotEmpty) {
          buffer.writeln('<div class="image-grid">');
          for (final imgBlock in consecutiveImages) {
            final pathSafe = _escapeHtmlAttr(imgBlock.imagePath);
            if (pathSafe.isNotEmpty) {
              final dataUri = await _imageFileToDataUri(imgBlock.imagePath);
              buffer.writeln('<div class="grid-item">');
              if (dataUri != null) {
                buffer.writeln('<img class="image" src="$dataUri" alt="image">');
              }
              if (imgBlock.caption != null && imgBlock.caption!.isNotEmpty) {
                buffer.writeln(
                  '<div class="caption">${_escapeHtml(imgBlock.caption!)}</div>',
                );
              }
              buffer.writeln('</div>');
            }
          }
          buffer.writeln('</div>');
        }
      } else {
        i++;
      }
    }

    buffer.writeln('</body></html>');

    final tempDir = await getTemporaryDirectory();
    final baseName = _slugify(document.chapterTitle);
    final fileName = partSuffix != null ? '$baseName$partSuffix.html' : '$baseName.html';
    final path = p.join(tempDir.path, fileName);
    final file = File(path);
    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }

  String _normalizeLocale(String localeName) => localeName.split('_').first;

  String _escapeHtml(String input) => input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  String _escapeHtmlAttr(String input) =>
      _escapeHtml(input).replaceAll('"', '&quot;');

  Future<String?> _imageFileToDataUri(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final originalBytes = await file.readAsBytes();

      // Prefer native compression via flutter_image_compress (non-blocking native code)
      try {
        final compressed = await FlutterImageCompress.compressWithList(
          originalBytes,
          minWidth: 450,
          minHeight: 450,
          quality: 65,
          rotate: 0,
        );
        final bytes = compressed.isNotEmpty
            ? Uint8List.fromList(compressed)
            : originalBytes;
        final lower = path.toLowerCase();
        final mime = lower.endsWith('.png')
            ? 'image/png'
            : (lower.endsWith('.gif') ? 'image/gif' : 'image/jpeg');
        final base64 = base64Encode(bytes);
        return 'data:$mime;base64,$base64';
      } catch (_) {
        // Fallback to isolate-based compression if native fails
        final processed = await compute<_ImageProcessingRequest, Uint8List?>(
          _processImageInIsolate,
          _ImageProcessingRequest(
            bytes: originalBytes,
            maxDimension: 450,
            quality: 65,
          ),
        );

        final bytes = processed ?? originalBytes;
        final lower = path.toLowerCase();
        final mime = lower.endsWith('.png')
            ? 'image/png'
            : (lower.endsWith('.gif') ? 'image/gif' : 'image/jpeg');
        final base64 = base64Encode(bytes);
        return 'data:$mime;base64,$base64';
      }
    } catch (_) {
      return null;
    }
  }

  void _validateExportLimits(
    ChapterExportDocument document,
    String localeName,
  ) {
    if (document.blocks.length > _maxBlocks) {
      throw ChapterPdfExportLimitException(
        _buildLimitMessage(localeName, blockCount: document.blocks.length),
      );
    }
  }

  String _buildLimitMessage(String localeName, {required int blockCount}) {
    final isPortuguese = localeName.toLowerCase().startsWith('pt');
    return isPortuguese
        ? 'Capítulo grande demais para exportar com segurança ($blockCount blocos > $_maxBlocks). Divida o conteúdo em partes menores.'
        : 'Chapter is too large to export safely ($blockCount blocks > $_maxBlocks). Split the content into smaller parts.';
  }

  String _buildPeriodLabel(ChapterExportDocument document, String localeName) {
    final formatter = DateFormat('dd/MM/yyyy', localeName);
    return '${formatter.format(document.startDate)} - ${formatter.format(document.endDate)}';
  }

  String _slugify(String value) {
    final lower = value.toLowerCase().trim();
    final cleaned = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (cleaned.isEmpty) {
      return 'chapter_export';
    }
    return cleaned;
  }
}

// Request object for compute() isolate
class _ImageProcessingRequest {
  final Uint8List bytes;
  final int maxDimension;
  final int quality;

  _ImageProcessingRequest({
    required this.bytes,
    required this.maxDimension,
    required this.quality,
  });
}

// Top-level function invoked in an isolate via compute()
Future<Uint8List?> _processImageInIsolate(_ImageProcessingRequest req) async {
  try {
    final decoded = img.decodeImage(req.bytes);
    if (decoded == null) return req.bytes;

    final needsResize =
        decoded.width > req.maxDimension || decoded.height > req.maxDimension;

    final targetWidth = needsResize ? req.maxDimension : decoded.width;
    final targetHeight = needsResize ? req.maxDimension : decoded.height;

    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? targetWidth : null,
      height: decoded.height > decoded.width ? targetHeight : null,
      interpolation: img.Interpolation.average,
    );

    final encoded = img.encodeJpg(resized, quality: req.quality);
    if (encoded.length >= req.bytes.length) {
      return req.bytes;
    }

    return Uint8List.fromList(encoded);
  } catch (_) {
    return null;
  }
}

class ChapterPdfExportLimitException implements Exception {
  final String message;

  const ChapterPdfExportLimitException(this.message);

  @override
  String toString() => message;
}
