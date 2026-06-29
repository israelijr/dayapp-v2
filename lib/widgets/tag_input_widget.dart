import 'dart:async';

import 'package:flutter/material.dart';

import '../db/tag_helper.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/tag.dart';

/// Widget de entrada de tags com autocomplete, chips e suporte a renomear.
///
/// Comportamento:
///  - Exibe as tags selecionadas como chips com botão de remoção.
///  - Enquanto o usuário digita, sugestões de tags existentes são exibidas
///    em tempo real (busca pelo slug normalizado — sem diferença de acentos
///    ou capitalização).
///  - Pressionar Enter, vírgula ou o botão "+" adiciona a tag digitada
///    (cria se não existir, reutiliza se o slug já existir).
///  - Toque longo num chip abre diálogo para renomear a tag (a renomeação
///    afeta todas as histórias que usam aquela tag).
class TagInputWidget extends StatefulWidget {
  /// ID do usuário autenticado, necessário para buscar/criar tags.
  final String userId;

  /// Lista inicial de tags já associadas (ex.: ao editar uma história).
  final List<Tag> initialTags;

  /// Callback chamado sempre que a lista de tags selecionadas muda.
  final ValueChanged<List<Tag>> onTagsChanged;

  const TagInputWidget({
    required this.userId,
    required this.initialTags,
    required this.onTagsChanged,
    super.key,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  late List<Tag> _selectedTags;
  List<Tag> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(TagInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza as tags selecionadas quando o pai carrega as tags
    // assincronamente (ex: ao abrir a tela de edição)
    if (oldWidget.initialTags != widget.initialTags) {
      setState(() {
        _selectedTags = List.from(widget.initialTags);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Pequeno delay para permitir que o toque na sugestão seja registrado
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _suggestions = []);
      });
    }
  }

  /// Pesquisa sugestões com debounce de 300ms
  void _onTextChanged(String value) {
    // Detecta vírgula como separador
    if (value.contains(',')) {
      final parts = value.split(',');
      for (int i = 0; i < parts.length - 1; i++) {
        _addTagFromText(parts[i]);
      }
      _textController.value = TextEditingValue(
        text: parts.last.trimLeft(),
        selection: TextSelection.collapsed(
          offset: parts.last.trimLeft().length,
        ),
      );
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final text = _textController.text.trim();
      if (text.isEmpty) {
        if (mounted) setState(() => _suggestions = []);
        return;
      }
      final results = await TagHelper().searchTags(widget.userId, text);
      // Filtra tags já selecionadas
      final filtered = results
          .where((t) => !_selectedTags.any((s) => s.slug == t.slug))
          .toList();
      if (mounted) setState(() => _suggestions = filtered);
    });
  }

  /// Adiciona a tag digitada (cria no banco se necessário)
  Future<void> _addTagFromText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final slug = Tag.generateSlug(trimmed);
    if (slug.isEmpty) return;

    // Já selecionada → apenas limpa o campo
    if (_selectedTags.any((t) => t.slug == slug)) {
      _textController.clear();
      setState(() => _suggestions = []);
      return;
    }

    final tag = await TagHelper().getOrCreateTag(widget.userId, trimmed);
    if (mounted) {
      setState(() {
        _selectedTags.add(tag);
        _suggestions = [];
      });
      _textController.clear();
      widget.onTagsChanged(List.from(_selectedTags));
    }
  }

  /// Seleciona uma sugestão existente
  void _onSuggestionSelected(Tag tag) {
    if (!_selectedTags.any((t) => t.slug == tag.slug)) {
      setState(() {
        _selectedTags.add(tag);
        _suggestions = [];
      });
      _textController.clear();
      widget.onTagsChanged(List.from(_selectedTags));
    } else {
      setState(() => _suggestions = []);
      _textController.clear();
    }
  }

  /// Remove uma tag dos chips selecionados
  void _removeTag(Tag tag) {
    setState(() {
      _selectedTags.removeWhere((t) => t.id == tag.id || t.slug == tag.slug);
    });
    widget.onTagsChanged(List.from(_selectedTags));
  }

  /// Abre diálogo para renomear a tag (afeta todas as histórias)
  Future<void> _showRenameDialog(Tag tag) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: tag.nome);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.renameTagTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.renameTagWarning,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: loc.tagNameLabel),
              onSubmitted: (v) => Navigator.pop(ctx, v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(loc.save),
          ),
        ],
      ),
    );

    if (!mounted) return;
    controller.dispose();

    if (result != null &&
        result.trim().isNotEmpty &&
        result.trim() != tag.nome) {
      if (tag.id != null) {
        await TagHelper().renameTag(tag.id!, result.trim());
      }
      final newSlug = Tag.generateSlug(result.trim());
      if (mounted) {
        setState(() {
          final index = _selectedTags.indexWhere(
            (t) => t.id == tag.id || t.slug == tag.slug,
          );
          if (index != -1) {
            _selectedTags[index] = Tag(
              id: tag.id,
              userId: tag.userId,
              nome: result.trim(),
              slug: newSlug,
            );
          }
        });
        widget.onTagsChanged(List.from(_selectedTags));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Chips das tags selecionadas ──────────────────────────────────────
        if (_selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedTags.map((tag) {
              return GestureDetector(
                onLongPress: () => _showRenameDialog(tag),
                child: InputChip(
                  label: Text(tag.nome),
                  avatar: const Icon(Icons.tag, size: 14),
                  onDeleted: () => _removeTag(tag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  tooltip: loc.tagLongPressHint,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // ── Campo de entrada ─────────────────────────────────────────────────
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: loc.tagsLabel,
            helperText: loc.tagsHint,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.tag),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: loc.addTag,
              onPressed: () => _addTagFromText(_textController.text),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: _onTextChanged,
          onSubmitted: _addTagFromText,
          textInputAction: TextInputAction.done,
        ),

        // ── Lista de sugestões ───────────────────────────────────────────────
        if (_suggestions.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 2),
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final tag = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.tag, size: 18),
                    title: Text(tag.nome),
                    trailing: Text(
                      '#${tag.slug}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    dense: true,
                    onTap: () => _onSuggestionSelected(tag),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
