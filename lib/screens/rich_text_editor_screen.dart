import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../helpers/rich_text_helper.dart';
import '../theme/animation_durations.dart';
import '../widgets/rich_text_editor_widget.dart';

class SentenceCapitalizationTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String capitalizeText(String text) {
      if (text.isEmpty) return text;

      // Capitaliza a primeira letra do texto
      String result = text;
      if (result.isNotEmpty) {
        result = result[0].toUpperCase() + result.substring(1);
      }

      // Capitaliza após pontos finais (., !, ?) seguidos de espaço e letra minúscula
      result = result.replaceAllMapped(
        RegExp(r'([.!?]\s+)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      // Capitaliza após quebras de linha
      result = result.replaceAllMapped(
        RegExp(r'(\n)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      return result;
    }

    final capitalized = capitalizeText(newValue.text);
    return newValue.copyWith(text: capitalized, selection: newValue.selection);
  }
}

class RichTextEditorScreen extends StatefulWidget {
  final String? initialText;

  const RichTextEditorScreen({super.key, this.initialText});

  @override
  State<RichTextEditorScreen> createState() => _RichTextEditorScreenState();
}

class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
  late TextEditingController _controller;
  double _dragOffset = 0.0;
  // Configurable threshold and return animation duration
  final double _threshold = 120.0;
  final Duration _returnDuration = AppDurations.modalReturn;
  bool _isAutoSaving = false;
  bool _showAutoSaveCheck = false;
  late String _initialText;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initialText = widget.initialText ?? '';
    _controller = TextEditingController(text: _initialText);
    _controller.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges = _controller.text != _initialText;
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  void _saveAndExit() async {
    if (_isAutoSaving) return;
    setState(() {
      _isAutoSaving = true;
      _showAutoSaveCheck = true;
    });
    HapticFeedback.mediumImpact();
    final navigator = Navigator.of(context);
    await Future.delayed(AppDurations.modalReturn);
    if (!mounted) return;
    navigator.pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // Wrap the whole scaffold so we can translate it while dragging down
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // Se não há alterações não salvas, pode sair
        if (!_hasUnsavedChanges) {
          Navigator.of(context).pop();
          return;
        }

        // Se está salvando, bloqueia
        if (_isAutoSaving) {
          return;
        }

        // Mostra diálogo de confirmação
        final dialogResult = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(loc.discardChangesTitle),
            content: Text(loc.discardChangesPrompt),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('discard'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(loc.discard),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('save'),
                child: Text(loc.save),
              ),
            ],
          ),
        );

        if (!context.mounted) return;

        if (dialogResult == 'save') {
          _saveAndExit();
        } else if (dialogResult == 'discard') {
          Navigator.of(context).pop();
        }
        // Se 'cancel' ou null, não faz nada (permanece na tela)
      },
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Only consider downward drag
          if (details.delta.dy > 0) {
            setState(() {
              _dragOffset += details.delta.dy;
              // cap to screen height
              _dragOffset = _dragOffset.clamp(
                0.0,
                MediaQuery.of(context).size.height,
              );
            });
          }
        },
        onVerticalDragEnd: (details) async {
          // If dragged sufficiently far, auto-save (return text) and show check feedback
          if (_dragOffset > _threshold && !_isAutoSaving) {
            setState(() {
              _isAutoSaving = true;
              _showAutoSaveCheck = true;
            });

            final navigator = Navigator.of(context);
            // show check animation briefly before popping
            await Future.delayed(AppDurations.modalReturn);
            if (!mounted) return;
            navigator.pop(_controller.text);
            return;
          }

          // otherwise animate back
          setState(() {
            _dragOffset = 0.0;
          });
        },
        child: AnimatedContainer(
          duration: _returnDuration,
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          child: Builder(
            builder: (context) {
              final height = MediaQuery.of(context).size.height;
              final dragFraction = (height > 0)
                  ? (_dragOffset / height).clamp(0.0, 1.0)
                  : 0.0;
              final scale = 1.0 - (dragFraction * 0.05); // up to 5% shrink
              final overlayOpacity = _isAutoSaving
                  ? 0.6
                  : (_dragOffset / _threshold).clamp(0.0, 1.0) * 0.5;

              return Stack(
                children: [
                  Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: Scaffold(
                      // Animated AppBar: fades and slides slightly based on drag
                      appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: AnimatedOpacity(
                          opacity: 1.0 - (dragFraction * 0.95),
                          duration: const Duration(milliseconds: 120),
                          child: Transform.translate(
                            offset: Offset(0, -dragFraction * 20),
                            child: AppBar(
                              title: Text(loc.editDescription),
                              elevation: dragFraction > 0.02 ? 2 : 4,
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () async {
                                  // Se não há alterações, sai direto
                                  if (!_hasUnsavedChanges) {
                                    Navigator.of(context).pop();
                                    return;
                                  }

                                  // Se está salvando, bloqueia
                                  if (_isAutoSaving) return;

                                  // Mostra diálogo
                                  final dialogResult = await showDialog<String>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: Text(loc.discardChangesTitle),
                                      content: Text(loc.discardChangesPrompt),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            context,
                                          ).pop('cancel'),
                                          child: Text(loc.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            context,
                                          ).pop('discard'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                          child: Text(loc.discard),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop('save'),
                                          child: Text(loc.save),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (!context.mounted) return;

                                  if (dialogResult == 'save') {
                                    _saveAndExit();
                                  } else if (dialogResult == 'discard') {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                              actions: [
                                IconButton(
                                  icon: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Image.asset(
                                      'assets/image/salvar.png',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.save, size: 20),
                                    ),
                                  ),
                                  onPressed: _saveAndExit,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Usa resizeToAvoidBottomInset para ajustar o layout quando o teclado aparece
                      resizeToAvoidBottomInset: true,
                      body: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _RichTextEditorBody(controller: _controller),
                        ),
                      ),
                    ),
                  ),
                  // Dark overlay that grows with drag, or is fixed during auto-save
                  if (overlayOpacity > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: overlayOpacity),
                        ),
                      ),
                    ),
                  // Animated check icon when auto-saving
                  if (_showAutoSaveCheck)
                    Positioned.fill(
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isAutoSaving ? 1.0 : 0.0,
                          duration: AppDurations.short,
                          child: AnimatedScale(
                            scale: _isAutoSaving ? 1.0 : 0.6,
                            duration: AppDurations.short,
                            child: Icon(
                              Icons.check_circle,
                              size: 96,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ), // GestureDetector
    ); // PopScope
  }

  @override
  void dispose() {
    _controller.removeListener(_checkForChanges);
    _controller.dispose();
    super.dispose();
  }
}

/// Widget que encapsula o editor Rich Text
class _RichTextEditorBody extends StatefulWidget {
  final TextEditingController controller;

  const _RichTextEditorBody({required this.controller});

  @override
  State<_RichTextEditorBody> createState() => _RichTextEditorBodyState();
}

class _RichTextEditorBodyState extends State<_RichTextEditorBody> {
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    // Inicializa o controller Quill com o texto do TextEditingController
    _quillController = RichTextHelper.smartController(widget.controller.text);
    // Sincroniza mudanças do Quill para o TextEditingController
    _quillController.addListener(_syncToTextController);
  }

  void _syncToTextController() {
    final json = RichTextHelper.controllerToJson(_quillController);
    widget.controller.text = json;
  }

  @override
  Widget build(BuildContext context) {
    return RichTextEditorWidget(
      controller: _quillController,
      showToolbar: true,
      minLines: 10,
      maxLines: null,
      hintText: AppLocalizations.of(context)!.editorPlaceholder,
      expand: true, // Expande para ocupar todo o espaço disponível na tela
    );
  }

  @override
  void dispose() {
    _quillController.removeListener(_syncToTextController);
    _quillController.dispose();
    super.dispose();
  }
}
