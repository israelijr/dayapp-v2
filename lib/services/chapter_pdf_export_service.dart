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

  static const int _maxBlocks = 400;

  /// Exporta o capítulo como um arquivo HTML básico (Título, período, blocos).
  Future<File> exportHtml({
    required ChapterExportDocument document,
    required String localeName,
    required String storyCountLabel,
  }) async {
    _validateExportLimits(document, localeName);

    final buffer = StringBuffer();
    buffer.writeln('<!doctype html>');
    buffer.writeln('<html lang="${_normalizeLocale(localeName)}">');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln(
      '<meta name="viewport" content="width=device-width,initial-scale=1">',
    );
    buffer.writeln('<title>${_escapeHtml(document.chapterTitle)}</title>');
    buffer.writeln('<style>');
    buffer.writeln(
      'body{font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; padding:20px; color:#222}',
    );
    buffer.writeln(
      'h1{font-family: Noto Serif, serif; font-size:28px; margin:0 0 8px}',
    );
    buffer.writeln('.meta{color:#666;font-size:12px;margin-bottom:12px}');
    buffer.writeln(
      '.cover{max-width:720px;border-radius:10px;overflow:hidden;margin-bottom:14px}',
    );
    buffer.writeln('.image{max-width:100%;height:auto;border-radius:8px}');
    buffer.writeln('.caption{color:#666;font-size:12px;margin-top:6px}');
    buffer.writeln('p{line-height:1.6;font-size:14px;margin:8px 0}');
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    buffer.writeln('<h1>${_escapeHtml(document.chapterTitle)}</h1>');
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

    for (final block in document.blocks) {
      if (block is TitleExportBlock) {
        buffer.writeln('<h2>${_escapeHtml(block.text)}</h2>');
      } else if (block is DateExportBlock) {
        buffer.writeln(
          '<div class="meta">${_escapeHtml(DateFormat('dd/MM/yyyy', localeName).format(block.date))}</div>',
        );
      } else if (block is ParagraphExportBlock) {
        buffer.writeln('<p>${_escapeHtml(block.text)}</p>');
      } else if (block is ImageExportBlock) {
        final pathSafe = _escapeHtmlAttr(block.imagePath);
        if (pathSafe.isNotEmpty) {
          final dataUri = await _imageFileToDataUri(block.imagePath);
          buffer.writeln('<div class="image-block">');
          if (dataUri != null) {
            buffer.writeln('<img class="image" src="$dataUri" alt="image">');
          }
          if (block.caption != null && block.caption!.isNotEmpty) {
            buffer.writeln(
              '<div class="caption">${_escapeHtml(block.caption!)}</div>',
            );
          }
          buffer.writeln('</div>');
        }
      }
    }

    buffer.writeln('</body></html>');

    final tempDir = await getTemporaryDirectory();
    final fileName = '${_slugify(document.chapterTitle)}.html';
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
          minWidth: 800,
          minHeight: 800,
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
            maxDimension: 800,
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
