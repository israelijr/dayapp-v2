import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
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
          style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold),
        ),
      );
    }

    if (block is DateExportBlock) {
      final label = DateFormat('dd/MM/yyyy', localeName).format(block.date);
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
        child: pw.Text(
          label,
          style: pw.TextStyle(
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
