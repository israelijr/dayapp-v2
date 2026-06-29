import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/rich_text_helper.dart';
import '../screens/rich_text_editor_screen.dart';
import '../theme/animation_durations.dart';
import 'rich_text_editor_widget.dart';

class ExpandableRichTextEditor extends StatefulWidget {
  final QuillController controller;
  final String label;
  final String hintText;
  final String expandTooltip;
  final int minLines;
  final int maxLines;
  final VoidCallback? onChanged;
  final bool showBorder;

  const ExpandableRichTextEditor({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.expandTooltip,
    this.minLines = 8,
    this.maxLines = 15,
    this.onChanged,
    this.showBorder = true,
    super.key,
  });

  @override
  State<ExpandableRichTextEditor> createState() => _ExpandableRichTextEditorState();
}

class _ExpandableRichTextEditorState extends State<ExpandableRichTextEditor> {
  void _expandDescriptionEditor() async {
    final navigator = Navigator.of(context);
    final richTextJson = RichTextHelper.controllerToJson(widget.controller);
    final result = await navigator.push<String>(
      PageRouteBuilder<String>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RichTextEditorScreen(initialText: richTextJson),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from bottom
          final slideTween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));
          // Fade in
          final fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.routeTransition,
      ),
    );
    if (result != null && mounted) {
      // Reconstrói o controller com o JSON retornado
      final newController = RichTextHelper.smartController(result);
      // Substitui todo o documento
      widget.controller.replaceText(
        0,
        widget.controller.document.length - 1,
        newController.document.toDelta(),
        null,
      );
      if (widget.onChanged != null) {
        widget.onChanged!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            SizedBox(
              width: 34,
              height: 34,
              child: FloatingActionButton.small(
                heroTag: null,
                elevation: 1,
                backgroundColor: theme.colorScheme.surfaceContainerLow,
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                tooltip: widget.expandTooltip,
                onPressed: _expandDescriptionEditor,
                child: const Icon(
                  Icons.open_in_full_rounded,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RichTextEditorWidget(
          key: const Key('description_field'),
          controller: widget.controller,
          hintText: widget.hintText,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: theme.colorScheme.onSurface,
          ),
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          showToolbar: true,
          toolbarAtBottom: true, // Força a barra de ferramentas a ficar embaixo para evitar a sobreposição
          showBorder: widget.showBorder,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
