import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../helpers/rich_text_helper.dart';

/// Widget reutilizável para visualização de Rich Text
/// Exibe o conteúdo formatado sem permitir edição
/// Usado em cards, detalhes e visualizações do app
class RichTextViewerWidget extends StatelessWidget {
  /// Conteúdo em JSON do Quill (vindo do banco de dados)
  final String? jsonContent;

  /// Número máximo de linhas para exibir (null = sem limite)
  final int? maxLines;

  /// Estilo do texto
  final TextStyle? textStyle;

  /// Se o texto deve ter overflow com elipses
  final bool showOverflow;

  /// Padding interno do viewer
  final EdgeInsets? padding;

  const RichTextViewerWidget({
    required this.jsonContent, super.key,
    this.maxLines,
    this.textStyle,
    this.showOverflow = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Se não houver conteúdo, retorna vazio
    if (jsonContent == null || jsonContent!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Cria o controller a partir do JSON ou Texto Simples
    final controller = RichTextHelper.smartController(jsonContent);

    return QuillEditor(
      controller: controller,
      focusNode: FocusNode(canRequestFocus: false),
      scrollController: ScrollController(),
      config: QuillEditorConfig(
        padding: padding ?? EdgeInsets.zero,
        // Desabilita todas as interações
        enableInteractiveSelection: false,
        enableScribble: false,
      ),
    );
  }
}

/// Widget reutilizável para visualização de Rich Text com limite de caracteres
/// Ideal para cards e listas onde o espaço é limitado
class RichTextViewerCompactWidget extends StatelessWidget {
  /// Conteúdo em JSON do Quill (vindo do banco de dados)
  final String? jsonContent;

  /// Número máximo de caracteres para exibir
  final int maxLength;

  /// Estilo do texto
  final TextStyle? textStyle;

  /// Cor do texto
  final Color? textColor;

  const RichTextViewerCompactWidget({
    required this.jsonContent, super.key,
    this.maxLength = 150,
    this.textStyle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Se não houver conteúdo, retorna vazio
    if (jsonContent == null || jsonContent!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Obtém o texto simples truncado
    final plainText = RichTextHelper.truncateForCard(
      jsonContent,
      maxLength: maxLength,
    );

    return Text(
      plainText,
      style:
          textStyle ??
          Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Helper para criar visualizadores de forma simples
class RichTextViewerHelper {
  /// Cria um visualizador completo (com formatação)
  static Widget createViewer({
    required String? jsonContent,
    int? maxLines,
    TextStyle? textStyle,
    EdgeInsets? padding,
  }) {
    return RichTextViewerWidget(
      jsonContent: jsonContent,
      maxLines: maxLines,
      textStyle: textStyle,
      padding: padding,
    );
  }

  /// Cria um visualizador compacto (texto simples truncado)
  /// Ideal para cards e listas
  static Widget createCompactViewer({
    required String? jsonContent,
    int maxLength = 150,
    TextStyle? textStyle,
    Color? textColor,
  }) {
    return RichTextViewerCompactWidget(
      jsonContent: jsonContent,
      maxLength: maxLength,
      textStyle: textStyle,
      textColor: textColor,
    );
  }

  /// Obtém o texto simples de um JSON do Quill
  /// Útil para notificações, buscas, etc.
  static String getPlainText(String? jsonContent) {
    return RichTextHelper.jsonToPlainText(jsonContent);
  }

  /// Obtém o texto truncado de um JSON do Quill
  /// Útil para pré-visualizações
  static String getTruncatedText(String? jsonContent, {int maxLength = 150}) {
    return RichTextHelper.truncateForCard(jsonContent, maxLength: maxLength);
  }
}
