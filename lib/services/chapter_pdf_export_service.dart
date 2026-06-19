import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/chapter_export_document.dart';
import '../domain/export_block.dart';

class ChapterPdfExportService {
  const ChapterPdfExportService();

  static Future<_PdfFonts>? _fontsFuture;
  static const int _maxBlocks = 400;
  static const Duration _defaultMaxExportDuration = Duration(seconds: 20);

  Future<File> export({
    required ChapterExportDocument document,
    required String localeName,
    required String storyCountLabel,
    Duration maxExportDuration = _defaultMaxExportDuration,
  }) async {
    final stopwatch = Stopwatch()..start();
    _validateExportLimits(document, localeName);
    _ensureWithinDeadline(stopwatch, maxExportDuration, localeName);
    final fonts = await _loadFonts();
    _ensureWithinDeadline(stopwatch, maxExportDuration, localeName);
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fonts.bodyRegular,
        bold: fonts.bodyBold,
      ),
    );

    final blocks = <pw.Widget>[
      pw.Text(
        document.chapterTitle,
        style: pw.TextStyle(
          font: fonts.titleBold,
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        _buildPeriodLabel(document, localeName),
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        storyCountLabel,
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 16),
    ];

    final coverWidget = await _buildCoverWidget(document.coverImagePath);
    if (coverWidget != null) {
      blocks.add(coverWidget);
      blocks.add(pw.SizedBox(height: 16));
    }
    _ensureWithinDeadline(stopwatch, maxExportDuration, localeName);

    for (final block in document.blocks) {
      final widget = await _buildPdfBlock(block, localeName);
      if (widget != null) {
        blocks.add(widget);
      }
      _ensureWithinDeadline(stopwatch, maxExportDuration, localeName);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 26, vertical: 28),
        build: (_) => blocks,
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final fileName = '${_slugify(document.chapterTitle)}.pdf';
    final path = p.join(tempDir.path, fileName);
    final file = File(path);
    _ensureWithinDeadline(stopwatch, maxExportDuration, localeName);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

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

  void _ensureWithinDeadline(
    Stopwatch stopwatch,
    Duration maxExportDuration,
    String localeName,
  ) {
    if (stopwatch.elapsed <= maxExportDuration) {
      return;
    }

    throw ChapterPdfExportTimeoutException(
      localeName.toLowerCase().startsWith('pt')
          ? 'A exportação do capítulo demorou demais e foi interrompida. Tente dividir o capítulo ou remover algumas imagens.'
          : 'Chapter export took too long and was interrupted. Try splitting the chapter or removing some images.',
    );
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

  Future<_PdfFonts> _loadFonts() async {
    final cachedFonts = _fontsFuture;
    if (cachedFonts != null) {
      return cachedFonts;
    }

    final loader = _loadFontsInternal();
    _fontsFuture = loader;
    return loader;
  }

  Future<_PdfFonts> _loadFontsInternal() async {
    final bodyRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'),
    );
    final bodyBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'),
    );
    final titleBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSerif-Bold.ttf'),
    );

    return _PdfFonts(
      bodyRegular: bodyRegular,
      bodyBold: bodyBold,
      titleBold: titleBold,
    );
  }

  String _buildPeriodLabel(ChapterExportDocument document, String localeName) {
    final formatter = DateFormat('dd/MM/yyyy', localeName);
    return '${formatter.format(document.startDate)} - ${formatter.format(document.endDate)}';
  }

  Future<pw.Widget?> _buildCoverWidget(String? coverImagePath) async {
    if (coverImagePath == null || coverImagePath.trim().isEmpty) {
      return null;
    }

    final imageBytes = await _readOptimizedImageBytes(
      coverImagePath,
      maxDimension: 1800,
      quality: 85,
    );
    if (imageBytes == null) {
      return null;
    }

    return pw.ClipRRect(
      horizontalRadius: 10,
      verticalRadius: 10,
      child: pw.Image(
        pw.MemoryImage(imageBytes),
        fit: pw.BoxFit.cover,
        height: 180,
      ),
    );
  }

  Future<pw.Widget?> _buildPdfBlock(
    ExportBlock block,
    String localeName,
  ) async {
    if (block is TitleExportBlock) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
        child: pw.Text(
          block.text,
          style: const pw.TextStyle(
            fontSize: 17,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    if (block is DateExportBlock) {
      final label = DateFormat('dd/MM/yyyy', localeName).format(block.date);
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
        child: pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
      );
    }

    if (block is ParagraphExportBlock) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          block.text,
          style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
          textAlign: pw.TextAlign.justify,
        ),
      );
    }

    if (block is ImageExportBlock) {
      final imageBytes = await _readOptimizedImageBytes(
        block.imagePath,
        maxDimension: 1400,
        quality: 80,
      );
      if (imageBytes == null) {
        return null;
      }

      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.ClipRRect(
              horizontalRadius: 8,
              verticalRadius: 8,
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.cover,
                height: 170,
              ),
            ),
            if (block.caption != null && block.caption!.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  block.caption!,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return null;
  }

  Future<Uint8List?> _readOptimizedImageBytes(
    String filePath, {
    required int maxDimension,
    required int quality,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final originalBytes = await file.readAsBytes();
      if (originalBytes.length < 350 * 1024) {
        return originalBytes;
      }
      // Offload heavy image decode/resize/encode to a background Isolate
      try {
        final result = await compute<_ImageProcessingRequest, Uint8List?>(
          _processImageInIsolate,
          _ImageProcessingRequest(
            bytes: originalBytes,
            maxDimension: maxDimension,
            quality: quality,
          ),
        );

        // If isolate failed or returned null, fallback to original bytes
        return result ?? originalBytes;
      } catch (_) {
        return originalBytes;
      }
    } catch (_) {
      return null;
    }
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

class _PdfFonts {
  final pw.Font bodyRegular;
  final pw.Font bodyBold;
  final pw.Font titleBold;

  const _PdfFonts({
    required this.bodyRegular,
    required this.bodyBold,
    required this.titleBold,
  });
}

class ChapterPdfExportLimitException implements Exception {
  final String message;

  const ChapterPdfExportLimitException(this.message);

  @override
  String toString() => message;
}

class ChapterPdfExportTimeoutException implements Exception {
  final String message;

  const ChapterPdfExportTimeoutException(this.message);

  @override
  String toString() => message;
}
