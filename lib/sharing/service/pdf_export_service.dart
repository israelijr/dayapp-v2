import 'dart:convert';
import 'dart:io';

import 'package:dayapp/helpers/rich_text_helper.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfExportService {
  static Future<File> generateStoryPdf(StoryData story) async {
    final buffer = StringBuffer();
    final dateFormat = DateFormat.yMMMMd(story.localeName);
    final dateString = dateFormat.format(story.date);

    buffer.writeln('<!doctype html>');
    buffer.writeln('<html lang="${_normalizeLocale(story.localeName)}">');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln(
      '<meta name="viewport" content="width=device-width,initial-scale=1">',
    );
    buffer.writeln('<title>${_escapeHtml(story.title)}</title>');
    buffer.writeln('<style>');
    buffer.writeln(
      '/* Configuração de páginas físicas A4 e quebras de página */',
    );
    buffer.writeln('@page { size: A4; margin: 20mm 15mm; }');
    buffer.writeln(
      'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; line-height: 1.6; font-size: 14px; max-width: 800px; margin: 0 auto; padding: 20px; color: #222; }',
    );
    buffer.writeln(
      'h1 { font-family: Noto Serif, serif; font-size: 28px; margin: 0 0 8px; page-break-after: avoid; break-after: avoid; }',
    );
    buffer.writeln(
      '.meta { color: #666; font-size: 12px; margin-bottom: 24px; page-break-after: avoid; break-after: avoid; border-bottom: 1px solid #eee; padding-bottom: 12px; }',
    );
    buffer.writeln('.content { margin: 8px 0; orphans: 3; widows: 3; }');
    buffer.writeln('.content p { margin: 8px 0; }');
    buffer.writeln(
      '.image-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin: 24px 0; page-break-inside: avoid; break-inside: avoid; }',
    );
    buffer.writeln(
      '.grid-item { display: flex; flex-direction: column; align-items: center; }',
    );
    buffer.writeln(
      '.grid-item .image { width: 100%; height: auto; max-height: 200px; object-fit: cover; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }',
    );
    buffer.writeln(
      '.footer { text-align: center; margin-top: 40px; padding-top: 10px; color: #999; font-size: 11px; border-top: 1px solid #eee; page-break-inside: avoid; break-inside: avoid; }',
    );
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    buffer.writeln('<h1>${_escapeHtml(story.title)}</h1>');
    buffer.writeln('<div class="meta">${_escapeHtml(dateString)}</div>');

    if (story.description != null && story.description!.isNotEmpty) {
      String htmlContent = RichTextHelper.jsonToHtml(story.description);
      // Fallback if the parser didn't produce HTML tags
      if (!htmlContent.contains('<') && htmlContent.isNotEmpty) {
        htmlContent =
            '<p>${_escapeHtml(htmlContent).replaceAll('\\n', '<br>')}</p>';
      }
      buffer.writeln('<div class="content">$htmlContent</div>');
    }

    if (story.images.isNotEmpty) {
      buffer.writeln('<div class="image-grid">');
      for (final imgBytes in story.images) {
        final dataUri = await _imageBytesToDataUri(imgBytes);
        if (dataUri != null) {
          buffer.writeln('<div class="grid-item">');
          buffer.writeln('<img class="image" src="$dataUri" alt="image">');
          buffer.writeln('</div>');
        }
      }
      buffer.writeln('</div>');
    }

    buffer.writeln('<div class="footer">DayApp</div>');

    buffer.writeln('</body></html>');

    final tempDir = await getTemporaryDirectory();
    final baseName = 'dayapp_story_${DateTime.now().millisecondsSinceEpoch}';
    final path = p.join(tempDir.path, '$baseName.html');
    final file = File(path);
    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }

  static String _normalizeLocale(String localeName) =>
      localeName.split('_').first;

  static String _escapeHtml(String input) => input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  static Future<String?> _imageBytesToDataUri(Uint8List originalBytes) async {
    try {
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
        // Since we don't have the path/extension, we'll assume jpeg
        final base64 = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64';
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
        final base64 = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64';
      }
    } catch (_) {
      return null;
    }
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
