import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/locale_provider.dart';

class LanguageOption {
  const LanguageOption({required this.value, required this.label});

  final String value;
  final String Function(AppLocalizations loc) label;
}

const List<LanguageOption> _languageOptions = [
  LanguageOption(value: 'system', label: _deviceDefaultLabel),
  LanguageOption(value: 'en', label: _englishLabel),
  LanguageOption(value: 'es', label: _spanishLabel),
  LanguageOption(value: 'fr', label: _frenchLabel),
  LanguageOption(value: 'it', label: _italianLabel),
];

String _deviceDefaultLabel(AppLocalizations loc) => loc.deviceDefault;
String _englishLabel(AppLocalizations loc) => loc.english;
String _spanishLabel(AppLocalizations loc) => loc.spanish;
String _frenchLabel(AppLocalizations loc) => loc.french;
String _italianLabel(AppLocalizations loc) => loc.italian;

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final selectedOption = _languageOptions.firstWhere(
          (option) => option.value == localeProvider.selection,
          orElse: () => _languageOptions.first,
        );

        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(loc.language),
          subtitle: Text(selectedOption.label(loc)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            final loc = AppLocalizations.of(context)!;

            return AlertDialog(
              title: Text(loc.language),
              content: RadioGroup<String>(
                groupValue: localeProvider.selection,
                onChanged: (value) {
                  if (value == null) return;
                  unawaited(localeProvider.setSelection(value));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in _languageOptions)
                      RadioListTile<String>(
                        value: option.value,
                        title: Text(option.label(loc)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(loc.close),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
