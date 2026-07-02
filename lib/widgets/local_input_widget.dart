import 'dart:async';

import 'package:flutter/material.dart';

import '../db/local_helper.dart';
import '../l10n/generated/app_localizations.dart';

/// Campo de local com autocomplete baseado nos locais já cadastrados.
class LocalInputWidget extends StatefulWidget {
  final String userId;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const LocalInputWidget({
    required this.userId,
    required this.controller,
    this.onChanged,
    super.key,
  });

  @override
  State<LocalInputWidget> createState() => _LocalInputWidgetState();
}

class _LocalInputWidgetState extends State<LocalInputWidget> {
  final _focusNode = FocusNode();
  List<String> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _suggestions = []);
        }
      });
    }
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final text = widget.controller.text.trim();
      if (text.isEmpty) {
        if (mounted) {
          setState(() => _suggestions = []);
        }
        return;
      }

      final results = await LocalHelper().searchLocaisByUser(
        widget.userId,
        text,
      );
      final loweredText = text.toLowerCase();
      final filtered = results
          .where((local) => local.toLowerCase() != loweredText)
          .toList(growable: false);

      if (mounted) {
        setState(() => _suggestions = filtered);
      }
    });
  }

  void _selectSuggestion(String local) {
    widget.controller.value = TextEditingValue(
      text: local,
      selection: TextSelection.collapsed(offset: local.length),
    );
    widget.onChanged?.call(local);
    setState(() => _suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          selectAllOnFocus: false,
          decoration: InputDecoration(
            labelText: loc.localLabel,
            helperText: loc.localHint,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.location_on_outlined),
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
          textInputAction: TextInputAction.done,
        ),
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
                  final local = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, size: 18),
                    title: Text(local),
                    dense: true,
                    onTap: () => _selectSuggestion(local),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
