import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../helpers/rich_text_helper.dart';

/// Widget reutilizável para edição de Rich Text
/// Fornece uma interface completa com toolbar de formatação
/// Totalmente transparente para o usuário - sem necessidade de conhecer códigos
class RichTextEditorWidget extends StatefulWidget {
  /// Controller do Quill - gerencia o conteúdo do editor
  final QuillController controller;

  /// Texto de hint quando o editor estiver vazio
  final String? hintText;

  /// Altura mínima do editor (em número de linhas)
  final int minLines;

  /// Altura máxima do editor (em número de linhas, null = sem limite)
  final int? maxLines;

  /// Se true, mostra a toolbar de formatação
  final bool showToolbar;

  /// Callback quando o texto muda
  final VoidCallback? onChanged;

  /// Se true, o editor está em modo somente leitura
  final bool readOnly;

  /// Estilo customizado para o editor
  final TextStyle? textStyle;

  /// Se true, o editor expande para ocupar todo o espaço disponível
  /// Use true quando o widget estiver em um contexto com altura definida (Scaffold body)
  /// Use false quando estiver dentro de SingleChildScrollView
  final bool expand;

  /// Se true, a barra de ferramentas fica embaixo do editor
  final bool toolbarAtBottom;

  const RichTextEditorWidget({
    required this.controller,
    super.key,
    this.hintText,
    this.minLines = 5,
    this.maxLines,
    this.showToolbar = true,
    this.onChanged,
    this.readOnly = false,
    this.textStyle,
    this.expand = false,
    this.toolbarAtBottom = true,
  });

  @override
  State<RichTextEditorWidget> createState() => _RichTextEditorWidgetState();
}

class _RichTextEditorWidgetState extends State<RichTextEditorWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Adiciona listener para detectar mudanças
    widget.controller.addListener(_onTextChanged);
    // Adiciona listener de foco para rolar a tela quando o teclado abrir
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && mounted) {
      // Pequeno atraso para dar tempo ao teclado abrir e redimensionar a tela
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_focusNode.context != null && mounted) {
          Scrollable.ensureVisible(
            _focusNode.context!,
            duration: const Duration(milliseconds: 200),
            alignment: 0.8, // 80% do topo da tela (mantém o campo acima do teclado)
          );
        }
      });
    }
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!();
    }

    // Se o usuário está digitando ativamente, garante que o cursor/campo permaneça visível
    if (_focusNode.hasFocus && mounted) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_focusNode.context != null && mounted) {
          Scrollable.ensureVisible(
            _focusNode.context!,
            duration: const Duration(milliseconds: 150),
            alignment: 0.8,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle =
        widget.textStyle ??
        DefaultTextStyle.of(context).style.copyWith(fontSize: 16);
    final effectivePlaceholderStyle = effectiveTextStyle.copyWith(
      color:
          effectiveTextStyle.color?.withValues(alpha: 0.62) ??
          theme.colorScheme.onSurface.withValues(alpha: 0.62),
    );

    final customStyles = DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        effectiveTextStyle,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        effectivePlaceholderStyle,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
    );

    // Widget do editor com decoração
    Widget editorContainer = Container(
      constraints: widget.expand
          ? null
          : BoxConstraints(
              minHeight: widget.minLines * 20.0,
              maxHeight: widget.maxLines != null
                  ? widget.maxLines! * 20.0
                  : double.infinity,
            ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: widget.showToolbar && !widget.readOnly
            ? (widget.toolbarAtBottom
                ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  )
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ))
            : BorderRadius.circular(8),
      ),
      child: QuillEditor(
        controller: widget.controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        config: QuillEditorConfig(
          placeholder: widget.hintText ?? AppLocalizations.of(context)!.editorPlaceholder,
          padding: const EdgeInsets.all(12),
          customStyles: customStyles,
        ),
      ),
    );

    // Se expand é true, envolve com Expanded para ocupar o espaço disponível
    if (widget.expand) {
      editorContainer = Expanded(child: editorContainer);
    }

    final toolbar = (widget.showToolbar && !widget.readOnly)
        ? Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: widget.toolbarAtBottom
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
            ),
            child: QuillSimpleToolbar(
              controller: widget.controller,
              config: const QuillSimpleToolbarConfig(
                multiRowsDisplay: false,
                showFontFamily: false,
                showFontSize: false,
                showAlignmentButtons: false,
                showDirection: false,
                showHeaderStyle: false,
                showListCheck: false,
                showCodeBlock: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: true,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showListBullets: true,
                showListNumbers: true,
                showIndent: false,
                showLink: false,
                showQuote: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
              ),
            ),
          )
        : null;

    return Column(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (toolbar != null && !widget.toolbarAtBottom) toolbar,
        editorContainer,
        if (toolbar != null && widget.toolbarAtBottom) toolbar,
      ],
    );
  }
}

/// Widget helper para criar um editor de forma simples
/// Retorna tanto o widget quanto o controller para facilitar o uso
class RichTextEditorHelper {
  /// Cria um editor com conteúdo inicial (pode ser JSON ou texto simples)
  static Widget createEditor({
    required QuillController controller,
    String? hintText,
    int minLines = 5,
    int? maxLines,
    bool showToolbar = true,
    VoidCallback? onChanged,
  }) {
    return RichTextEditorWidget(
      controller: controller,
      hintText: hintText,
      minLines: minLines,
      maxLines: maxLines,
      showToolbar: showToolbar,
      onChanged: onChanged,
    );
  }

  /// Cria um controller a partir de conteúdo existente
  /// Detecta automaticamente se é JSON do Quill ou texto simples
  static QuillController createController(String? initialContent) {
    return RichTextHelper.smartController(initialContent);
  }

  /// Converte o conteúdo do controller para JSON (para salvar no banco)
  static String getJsonContent(QuillController controller) {
    return RichTextHelper.controllerToJson(controller);
  }

  /// Obtém o texto simples do controller (sem formatação)
  static String getPlainText(QuillController controller) {
    return controller.document.toPlainText();
  }
}
