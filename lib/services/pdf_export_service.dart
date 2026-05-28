import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' as fw;
// printing not needed in this file
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

// Regex que detecta sequências de emoji (bases + modificadores opcionais).
// Consome o variation selector U+FE0F, tons de pele (U+1F3FB-FF) e ZWJ
// para evitar que os caracteres modificadores "sobrem" no texto normal.
final _emojiRegex = RegExp(
  r'(?:'
  r'[\u{1F1E0}-\u{1F1FF}]{2}|' // Bandeiras
  r'[\u{1F600}-\u{1F64F}][\u{1F3FB}-\u{1F3FF}]?\u{FE0F}?|' // Faces + pele + VS
  r'[\u{1F300}-\u{1F5FF}]\u{FE0F}?|' // Símbolos Misc
  r'[\u{1F680}-\u{1F6FF}]\u{FE0F}?|' // Transporte
  r'[\u{1F700}-\u{1F7FF}]\u{FE0F}?|' // Alquimia
  r'[\u{1F800}-\u{1F8FF}]\u{FE0F}?|' // Setas Supl.
  r'[\u{1F900}-\u{1F9FF}]\u{FE0F}?|' // Símbolos Supl.
  r'[\u{1FA00}-\u{1FAFF}]\u{FE0F}?|' // Ext-A
  r'[#*0-9]\u{FE0F}\u{20E3}|' // Keycaps
  r'[\u{2600}-\u{27BF}]\u{FE0F}?' // Misc BMP + VS opt.
  r')(?:\u{200D}(?:[\u{1F300}-\u{1FAFF}][\u{1F3FB}-\u{1F3FF}]?\u{FE0F}?|[\u{2600}-\u{27BF}]\u{FE0F}?))*',
  unicode: true,
);

/// Pré-renderiza todos os emojis únicos encontrados em [text] e retorna
/// um [pw.TextSpan] com [pw.TextSpan] e [pw.WidgetSpan] mesclados, de
/// modo que cada emoji apareça como imagem inline no PDF.
Future<pw.TextSpan> _buildContentSpans(
  String text,
  pw.Font font,
  double fontSize,
) async {
  // Coleta emojis únicos e pré-renderiza cada um para PNG
  final uniqueEmojis = _emojiRegex
      .allMatches(text)
      .map((m) => m.group(0)!)
      .toSet();
  final Map<String, Uint8List> cache = {};
  for (final emoji in uniqueEmojis) {
    try {
      cache[emoji] = await _renderEmojiToPng(emoji, fontSize * 1.4);
    } catch (e) {
      // Ignora emoji que não puder ser rasterizado
      debugPrint('PdfExportService: falha ao renderizar emoji inline "$emoji": $e');
    }
  }

  // Monta a lista de spans intercalando texto e imagens inline
  final List<pw.InlineSpan> spans = [];
  int lastEnd = 0;
  for (final match in _emojiRegex.allMatches(text)) {
    // Segmento de texto antes do emoji
    if (match.start > lastEnd) {
      spans.add(
        pw.TextSpan(
          text: text.substring(lastEnd, match.start),
          style: pw.TextStyle(font: font, fontSize: fontSize),
        ),
      );
    }
    final emojiChar = match.group(0)!;
    final png = cache[emojiChar];
    if (png != null) {
      // Emoji renderizado como imagem inline; baseline alinha o topo da
      // imagem com o topo do glifo (valor 0 = alinhado ao ascendente).
      spans.add(
        pw.WidgetSpan(
          baseline: fontSize * 0.15,
          child: pw.Image(
            pw.MemoryImage(png),
            width: fontSize,
            height: fontSize,
          ),
        ),
      );
    } else {
      // Fallback: insere o caractere bruto (pode aparecer como ▯ na fonte)
      spans.add(
        pw.TextSpan(
          text: emojiChar,
          style: pw.TextStyle(font: font, fontSize: fontSize),
        ),
      );
    }
    lastEnd = match.end;
  }
  // Trecho final de texto após o último emoji
  if (lastEnd < text.length) {
    spans.add(
      pw.TextSpan(
        text: text.substring(lastEnd),
        style: pw.TextStyle(font: font, fontSize: fontSize),
      ),
    );
  }
  // Se não havia nenhum emoji, retorna um único TextSpan simples
  if (spans.isEmpty) {
    return pw.TextSpan(
      text: text,
      style: pw.TextStyle(font: font, fontSize: fontSize),
    );
  }
  return pw.TextSpan(children: spans);
}

/// Serviço para gerar PDF a partir de dados de uma história.
/// Comentários e nomes em português conforme convenção do projeto.
class PdfExportService {
  /// Gera um PDF contendo título, data, emoticon, tags, texto e imagens.
  /// Retorna os bytes do PDF prontos para salvar/compartilhar.
  static Future<Uint8List> generatePdfFromHistoria({
    required String title,
    required String content,
    required DateTime date,
    List<Uint8List>? images,
    String? tags,
    String? emoticon,
    bool highQuality = false,
    String? locale,
    int? backgroundColorHex,
  }) async {
    final doc = pw.Document();

    // Formata a data conforme o locale selecionado no app
    final resolvedLocale = locale ?? 'pt_BR';
    await initializeDateFormatting(resolvedLocale, null);
    final dateStr = DateFormat.yMd(resolvedLocale).add_Hm().format(date);

    // Tenta carregar fontes TTF (Noto) em assets para suporte Unicode.
    // Se não existir, mantém o fallback para Helvetica (sem suporte Unicode).
    pw.Font baseFont;
    pw.Font boldFont;
    try {
      final bd = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final bytes = bd.buffer.asUint8List();
      // Verifica se o arquivo carregado tem um cabeçalho compatível com
      // TTF/OTF/TrueType Collection para evitar erro de parsing mais
      // adiante quando o PDF tentar construir a fonte.
      if (!_looksLikeTtf(bytes)) {
        throw const FormatException('Arquivo de fonte inválido');
      }
      baseFont = pw.Font.ttf(bd);
    } catch (e) {
      debugPrint('PdfExportService: fallback para Helvetica (fonte regular): $e');
      baseFont = pw.Font.helvetica();
    }
    try {
      final bd = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      final bytes = bd.buffer.asUint8List();
      if (!_looksLikeTtf(bytes)) {
        throw const FormatException('Arquivo de fonte inválido');
      }
      boldFont = pw.Font.ttf(bd);
    } catch (e) {
      debugPrint('PdfExportService: fallback para HelveticaBold (fonte bold): $e');
      boldFont = pw.Font.helveticaBold();
    }

    // Limites de página (considera margens)
    const pageFormat = pdf.PdfPageFormat.a4;
    const marginAll = 24.0;
    const horizontalMargin = marginAll * 2; // left + right
    const verticalMargin = marginAll * 2; // top + bottom
    final maxImageWidth = pageFormat.width - horizontalMargin;
    final maxImageHeight =
        pageFormat.height -
        verticalMargin -
        120; // reserva espaço para header/text

    // Pré-comprimir/redimensionar imagens assincronamente para evitar que
    // o layout do PDF estoure a altura da página ou consuma muita memória.
    final List<Uint8List> compressedImages = [];
    if (images != null && images.isNotEmpty) {
      final int cap = highQuality ? 2000 : 1200;
      final int maxWidthPx = math.min((maxImageWidth * 2).toInt(), cap);
      final int quality = highQuality ? 95 : 80;
      for (final img in images) {
        try {
          final compressed = await FlutterImageCompress.compressWithList(
            img,
            minWidth: maxWidthPx,
            quality: quality,
            rotate: 0,
          );
          if (compressed.isNotEmpty) {
            compressedImages.add(compressed);
          } else {
            compressedImages.add(img);
          }
        } catch (e) {
          debugPrint('PdfExportService: falha ao comprimir imagem para PDF: $e');
          compressedImages.add(img);
        }
      }
    }

    // Renderiza o emoticon como PNG pequeno usando TextPainter para garantir
    // que mesmo que a fonte embutida do PDF não contenha o glifo, teremos
    // uma representação visual (bitmap) que será incorporada no PDF.
    Uint8List? emoticonPng;
    if (emoticon != null && emoticon.isNotEmpty) {
      try {
        emoticonPng = await _renderEmojiToPng(emoticon, 28);
      } catch (e) {
        debugPrint('PdfExportService: falha ao renderizar emoticon: $e');
        emoticonPng = null;
      }
    }

    // Carrega o ícone do app para o cabeçalho do PDF
    Uint8List? iconBytes;
    try {
      final iconData = await rootBundle.load('assets/icon/icon.png');
      iconBytes = iconData.buffer.asUint8List();
    } catch (e) {
      debugPrint('PdfExportService: ícone não disponível para cabeçalho do PDF: $e');
      iconBytes = null;
    }

    // Pré-renderiza emojis do conteúdo textual para uso inline no PDF
    final contentSpans = await _buildContentSpans(content, baseFont, 12);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(marginAll),
          // Renderiza cor de fundo sólid cobrindo a página inteira
          buildBackground: backgroundColorHex != null
              ? (context) => pw.FullPage(
                  ignoreMargins: true,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: pdf.PdfColor.fromInt(
                        // Garante alpha = 0xFF (totalmente opáco)
                        backgroundColorHex | 0xFF000000,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Cabeçalho da marca DayApp
          widgets.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (iconBytes != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(right: 8),
                    child: pw.Image(
                      pw.MemoryImage(iconBytes),
                      width: 36,
                      height: 36,
                    ),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DayApp',
                      style: pw.TextStyle(font: boldFont, fontSize: 18),
                    ),
                    pw.Text(
                      'Seu diário pessoal',
                      style: pw.TextStyle(
                        font: baseFont,
                        fontSize: 10,
                        color: const pdf.PdfColor.fromInt(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 8));
          widgets.add(pw.Divider());
          widgets.add(pw.SizedBox(height: 8));

          // Título da história
          widgets.add(
            pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 20)),
          );

          widgets.add(pw.SizedBox(height: 6));

          // Linha com data/hora à esquerda e emoticon à direita
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      dateStr,
                      style: pw.TextStyle(
                        font: baseFont,
                        fontSize: 10,
                        color: const pdf.PdfColor.fromInt(0xFF666666),
                      ),
                    ),
                    if (tags != null && tags.isNotEmpty)
                      pw.Text(
                        'Tags: $tags',
                        style: pw.TextStyle(
                          font: baseFont,
                          fontSize: 10,
                          color: const pdf.PdfColor.fromInt(0xFF666666),
                        ),
                      ),
                  ],
                ),
                if (emoticonPng != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(left: 8),
                    child: pw.Image(
                      pw.MemoryImage(emoticonPng),
                      width: 26,
                      height: 26,
                    ),
                  )
                else if (emoticon != null)
                  pw.Text(
                    emoticon,
                    style: pw.TextStyle(font: baseFont, fontSize: 20),
                  ),
              ],
            ),
          );

          // Conteúdo textual — usa RichText para renderizar emojis inline
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(pw.RichText(text: contentSpans));

          // Imagens (uma por linha, redimensionadas)
          if (compressedImages.isNotEmpty) {
            widgets.add(pw.SizedBox(height: 12));
            widgets.add(
              pw.Text(
                'Imagens',
                style: pw.TextStyle(font: boldFont, fontSize: 14),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (final img in compressedImages) {
              try {
                final pwImage = pw.MemoryImage(img);

                // Ajusta largura máxima e altura máxima, preservando proporção.
                widgets.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Center(
                      child: pw.Image(
                        pwImage,
                        fit: pw.BoxFit.contain,
                        width: math.min(maxImageWidth, 450),
                        height: math.min(maxImageHeight, 800),
                      ),
                    ),
                  ),
                );
              } catch (e) {
                // Ignora imagem que não puder ser inserida
                debugPrint('PdfExportService: falha ao inserir imagem no PDF: $e');
              }
            }
          }

          return widgets;
        },
      ),
    );

    return doc.save();
  }
}

// Verifica de forma simples os primeiros bytes para identificar formatos
// TTF/OTF/TTF Collection. Retorna `true` se o cabeçalho corresponder a
// uma das assinaturas conhecidas: 0x00010000 (TTF), 'OTTO' (OpenType),
// 'ttcf' (TrueType Collection).
bool _looksLikeTtf(Uint8List bytes) {
  if (bytes.length < 4) return false;
  // 00 01 00 00
  if (bytes[0] == 0x00 &&
      bytes[1] == 0x01 &&
      bytes[2] == 0x00 &&
      bytes[3] == 0x00) {
    return true;
  }
  // 'OTTO'
  if (bytes[0] == 0x4F &&
      bytes[1] == 0x54 &&
      bytes[2] == 0x54 &&
      bytes[3] == 0x4F) {
    return true;
  }
  // 'ttcf'
  if (bytes[0] == 0x74 &&
      bytes[1] == 0x74 &&
      bytes[2] == 0x63 &&
      bytes[3] == 0x66) {
    return true;
  }
  return false;
}

/// Renderiza um emoji/emoji-like `String` para PNG usando `TextPainter`.
/// Retorna `Uint8List` com bytes PNG ou lança se houver erro.
Future<Uint8List> _renderEmojiToPng(String emoji, double size) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final textSpan = fw.TextSpan(
    text: emoji,
    style: fw.TextStyle(fontSize: size),
  );
  final tp = fw.TextPainter(
    text: textSpan,
    textDirection: fw.TextDirection.ltr,
  );
  tp.layout();

  tp.paint(canvas, const ui.Offset(0, 0));

  final picture = recorder.endRecording();
  final img = await picture.toImage(tp.width.ceil(), tp.height.ceil());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Não foi possível gerar PNG do emoticon');
  }
  return byteData.buffer.asUint8List();
}
