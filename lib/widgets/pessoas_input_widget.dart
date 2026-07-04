import 'dart:async';

import 'package:flutter/material.dart';

import '../db/pessoa_helper.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/pessoa.dart';

/// Widget de entrada de pessoas com autocomplete, chips e suporte a renomear.
///
/// Comportamento:
///  - Exibe as pessoas selecionadas como chips com botão de remoção.
///  - Enquanto o usuário digita, sugestões de pessoas existentes são exibidas
///    em tempo real (busca pelo slug normalizado — sem diferença de acentos
///    ou capitalização).
///  - Pressionar Enter, vírgula ou o botão "+" adiciona a pessoa digitada
///    (cria se não existir, reutiliza se o slug já existir).
///  - Toque longo num chip abre diálogo para renomear a pessoa (a renomeação
///    afeta todas as histórias que usam aquela pessoa).
class PessoasInputWidget extends StatefulWidget {
  /// ID do usuário autenticado, necessário para buscar/criar pessoas.
  final String userId;

  /// Lista inicial de pessoas já associadas.
  final List<Pessoa> initialPessoas;

  /// Callback chamado sempre que a lista de pessoas selecionadas muda.
  final ValueChanged<List<Pessoa>> onPessoasChanged;

  const PessoasInputWidget({
    required this.userId,
    required this.initialPessoas,
    required this.onPessoasChanged,
    super.key,
  });

  @override
  State<PessoasInputWidget> createState() => _PessoasInputWidgetState();
}

class _PessoasInputWidgetState extends State<PessoasInputWidget> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  late List<Pessoa> _selectedPessoas;
  List<Pessoa> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedPessoas = List.from(widget.initialPessoas);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(PessoasInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPessoas != widget.initialPessoas) {
      setState(() {
        _selectedPessoas = List.from(widget.initialPessoas);
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
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _suggestions = []);
      });
    }
  }

  /// Pesquisa sugestões com debounce de 300ms
  void _onTextChanged(String value) {
    if (value.contains(',')) {
      final parts = value.split(',');
      for (int i = 0; i < parts.length - 1; i++) {
        _addPessoaFromText(parts[i]);
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
      final results = await PessoaHelper().searchPessoas(widget.userId, text);
      final filtered = results
          .where((p) => !_selectedPessoas.any((s) => s.slug == p.slug))
          .toList();
      if (mounted) setState(() => _suggestions = filtered);
    });
  }

  /// Adiciona a pessoa digitada (cria no banco se necessário)
  Future<void> _addPessoaFromText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final slug = Pessoa.generateSlug(trimmed);
    if (slug.isEmpty) return;

    if (_selectedPessoas.any((p) => p.slug == slug)) {
      _textController.clear();
      setState(() => _suggestions = []);
      return;
    }

    final pessoa = await PessoaHelper().getOrCreatePessoa(
      widget.userId,
      trimmed,
    );
    if (mounted) {
      setState(() {
        _selectedPessoas.add(pessoa);
        _suggestions = [];
      });
      _textController.clear();
      widget.onPessoasChanged(List.from(_selectedPessoas));
    }
  }

  /// Seleciona uma sugestão existente
  void _onSuggestionSelected(Pessoa pessoa) {
    if (!_selectedPessoas.any((p) => p.slug == pessoa.slug)) {
      setState(() {
        _selectedPessoas.add(pessoa);
        _suggestions = [];
      });
      _textController.clear();
      widget.onPessoasChanged(List.from(_selectedPessoas));
    } else {
      setState(() => _suggestions = []);
      _textController.clear();
    }
  }

  /// Remove uma pessoa dos chips selecionados
  void _removePessoa(Pessoa pessoa) {
    setState(() {
      _selectedPessoas.removeWhere(
        (p) => p.id == pessoa.id || p.slug == pessoa.slug,
      );
    });
    widget.onPessoasChanged(List.from(_selectedPessoas));
  }

  /// Abre diálogo para renomear a pessoa
  Future<void> _showRenameDialog(Pessoa pessoa) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: pessoa.nome);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.renamePessoaTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.renamePessoaWarning,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: loc.pessoaNameLabel),
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
        result.trim() != pessoa.nome) {
      if (pessoa.id != null) {
        await PessoaHelper().renamePessoa(pessoa.id!, result.trim());
      }
      final newSlug = Pessoa.generateSlug(result.trim());
      if (mounted) {
        setState(() {
          final index = _selectedPessoas.indexWhere(
            (p) => p.id == pessoa.id || p.slug == pessoa.slug,
          );
          if (index != -1) {
            _selectedPessoas[index] = Pessoa(
              id: pessoa.id,
              userId: pessoa.userId,
              nome: result.trim(),
              slug: newSlug,
            );
          }
        });
        widget.onPessoasChanged(List.from(_selectedPessoas));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chips das pessoas selecionadas
        if (_selectedPessoas.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedPessoas.map((pessoa) {
              return GestureDetector(
                onLongPress: () => _showRenameDialog(pessoa),
                child: InputChip(
                  label: Text(pessoa.nome),
                  avatar: const Icon(Icons.person_outline, size: 14),
                  onDeleted: () => _removePessoa(pessoa),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  tooltip: loc.pessoaLongPressHint,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // Campo de entrada
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: loc.pessoasLabel,
            helperText: loc.pessoasHint,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.person_outline),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: loc.addPessoa,
              onPressed: () => _addPessoaFromText(_textController.text),
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
          onSubmitted: _addPessoaFromText,
          textInputAction: TextInputAction.done,
        ),

        // Lista de sugestões
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
                  final pessoa = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.person_outline, size: 18),
                    title: Text(pessoa.nome),
                    dense: true,
                    onTap: () => _onSuggestionSelected(pessoa),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
