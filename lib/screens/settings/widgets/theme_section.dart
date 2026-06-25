import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/premium_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/custom_color_schemes.dart';

class ThemeOption {
  const ThemeOption({
    required this.icon,
    required this.label,
    this.familyKey,
    this.premium = false,
  });

  final IconData icon;
  final String Function(AppLocalizations loc) label;
  final String? familyKey;
  final bool premium;
}

const List<ThemeOption> _themeOptions = [
  ThemeOption(icon: Icons.auto_awesome, label: _defaultThemeLabel),
  ThemeOption(
    icon: Icons.eco,
    label: _relvaThemeLabel,
    familyKey: CustomColorSchemes.relvaFamilyKey,
    premium: true,
  ),
  ThemeOption(
    icon: Icons.local_florist_outlined,
    label: _outonoThemeLabel,
    familyKey: CustomColorSchemes.outonoFamilyKey,
    premium: true,
  ),
  ThemeOption(
    icon: Icons.cloud_outlined,
    label: _ceuThemeLabel,
    familyKey: CustomColorSchemes.ceuFamilyKey,
    premium: true,
  ),
  ThemeOption(
    icon: Icons.wb_incandescent_outlined,
    label: _confortThemeLabel,
    familyKey: CustomColorSchemes.confortFamilyKey,
    premium: true,
  ),
  ThemeOption(
    icon: Icons.wb_twilight_outlined,
    label: _sunsetThemeLabel,
    familyKey: CustomColorSchemes.sunsetFamilyKey,
    premium: true,
  ),
  ThemeOption(
    icon: Icons.nightlight_round,
    label: _midnightGalaxyThemeLabel,
    familyKey: CustomColorSchemes.midnightGalaxyFamilyKey,
    premium: true,
  ),
];

String _defaultThemeLabel(AppLocalizations loc) => loc.defaultLabel;
String _relvaThemeLabel(AppLocalizations loc) => loc.themeRelva;
String _outonoThemeLabel(AppLocalizations loc) => loc.themeOutono;
String _ceuThemeLabel(AppLocalizations loc) => loc.themeCeu;
String _confortThemeLabel(AppLocalizations loc) => loc.themeConfort;
String _sunsetThemeLabel(AppLocalizations loc) => loc.themeSunset;
String _midnightGalaxyThemeLabel(AppLocalizations loc) =>
    loc.themeMidnightGalaxy;

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.brightness_6),
          title: Text(loc.theme),
          subtitle: Text(_getThemeSummary(context, themeProvider)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SchemePreview(themeProvider: themeProvider),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => _showThemeDialog(context),
        );
      },
    );
  }

  String _getThemeSummary(BuildContext context, ThemeProvider themeProvider) {
    final loc = AppLocalizations.of(context)!;

    if (themeProvider.themeMode == ThemeMode.system) {
      return loc.themeSystem;
    }

    final selectedOption = _themeOptions.firstWhere(
      (option) => option.familyKey == themeProvider.selectedSchemeKey,
      orElse: () => _themeOptions.first,
    );

    return '${selectedOption.label(loc)} - '
        '${_getThemeModeText(loc, themeProvider.themeMode)}';
  }

  String _getThemeModeText(AppLocalizations loc, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => loc.themeLight,
      ThemeMode.dark => loc.themeDark,
      ThemeMode.system => loc.themeSystem,
    };
  }

  void _showThemeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer2<ThemeProvider, PremiumProvider>(
          builder: (context, themeProvider, premium, child) {
            final loc = AppLocalizations.of(context)!;
            final isSystemSelected =
                themeProvider.themeMode == ThemeMode.system;

            return AlertDialog(
              title: Text(loc.themeAndScheme),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ThemeModeButton(
                            icon: Icons.wb_sunny_outlined,
                            tooltip: loc.themeLight,
                            selected:
                                themeProvider.themeMode == ThemeMode.light,
                            enabled: !isSystemSelected,
                            onPressed: () {
                              unawaited(
                                themeProvider.setThemeMode(ThemeMode.light),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          ThemeModeButton(
                            icon: Icons.dark_mode_outlined,
                            tooltip: loc.themeDark,
                            selected: themeProvider.themeMode == ThemeMode.dark,
                            enabled: !isSystemSelected,
                            onPressed: () {
                              unawaited(
                                themeProvider.setThemeMode(ThemeMode.dark),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ThemeListOption(
                        icon: Icons.phone_iphone,
                        label: loc.themeSystem,
                        selected: isSystemSelected,
                        onTap: () => _selectThemeOption(
                          context,
                          themeProvider,
                          themeMode: ThemeMode.system,
                        ),
                      ),
                      for (final option in _themeOptions) ...[
                        const SizedBox(height: 8),
                        ThemeListOption(
                          icon: option.icon,
                          label: option.label(loc),
                          selected:
                              !isSystemSelected &&
                              option.familyKey ==
                                  themeProvider.selectedSchemeKey,
                          locked:
                              option.premium && !premium.canUsePremiumThemes,
                          onLockedTap: () {
                            _showPremiumThemeDialog(context, loc);
                          },
                          onTap: () => _selectThemeOption(
                            context,
                            themeProvider,
                            themeMode: _resolveCustomThemeMode(
                              context,
                              themeProvider,
                            ),
                            familyKey: option.familyKey,
                          ),
                        ),
                      ],
                    ],
                  ),
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

  void _showPremiumThemeDialog(BuildContext context, AppLocalizations loc) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.premiumFeature),
        content: Text(loc.premiumFeatureInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.close),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed('/premium');
            },
            child: Text(loc.insightPremiumCTA),
          ),
        ],
      ),
    );
  }

  ThemeMode _resolveCustomThemeMode(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    if (themeProvider.themeMode != ThemeMode.system) {
      return themeProvider.themeMode;
    }

    return Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void _selectThemeOption(
    BuildContext context,
    ThemeProvider themeProvider, {
    required ThemeMode themeMode,
    String? familyKey,
  }) {
    unawaited(themeProvider.setThemeMode(themeMode));
    unawaited(themeProvider.setSelectedSchemeKey(familyKey));
  }
}

class SchemePreview extends StatelessWidget {
  const SchemePreview({required this.themeProvider, super.key});

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    final brightness = themeProvider.themeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
    final scheme =
        CustomColorSchemes.getSchemeForFamily(
          themeProvider.selectedSchemeKey,
          brightness,
        ) ??
        Theme.of(context).colorScheme;
    final isMidnightGalaxy =
        themeProvider.selectedSchemeKey ==
        CustomColorSchemes.midnightGalaxyFamilyKey;
    final previewColors = isMidnightGalaxy
        ? <Color>[scheme.primary, scheme.primaryContainer]
        : <Color>[scheme.primary, scheme.secondary];

    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(colors: previewColors),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.12)),
      ),
    );
  }
}

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        foregroundColor: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
        disabledBackgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(
          alpha: 0.5,
        ),
      ),
      icon: Icon(icon),
    );
  }
}

class ThemeListOption extends StatelessWidget {
  const ThemeListOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.onLockedTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, color: locked ? disabledColor : null),
      title: Text(
        label,
        style: locked ? TextStyle(color: disabledColor) : null,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: selected && !locked,
      selectedTileColor: colorScheme.secondaryContainer.withValues(alpha: 0.7),
      trailing: locked
          ? Icon(Icons.lock_outline, color: disabledColor)
          : selected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: locked ? onLockedTap : onTap,
    );
  }
}
