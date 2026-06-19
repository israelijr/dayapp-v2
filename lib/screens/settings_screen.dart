import 'dart:async';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_preferences_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/settings_security_provider.dart';
import '../providers/theme_provider.dart';
import '../services/inactivity_service.dart';
import '../services/notification_preferences_service.dart';
import '../theme/custom_color_schemes.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/custom_text_field.dart';
import 'background_restrictions_info_screen.dart';
import 'setup_pin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.securityProvider});

  final SettingsSecurityProvider? securityProvider;

  @override
  Widget build(BuildContext context) {
    final providedSecurityProvider = securityProvider;
    if (providedSecurityProvider != null) {
      return ChangeNotifierProvider.value(
        value: providedSecurityProvider,
        child: const _SettingsView(),
      );
    }

    final auth = context.read<AuthProvider>();

    return ChangeNotifierProvider(
      create: (context) => SettingsSecurityProvider(
        pinProvider: context.read<PinProvider>(),
        userId: auth.user?.id,
      )..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenTheme = theme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(theme.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        theme.primaryTextTheme,
      ),
    );

    return Theme(
      data: screenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.settings,
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color:
                  theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.primary,
            ),
          ),
        ),
        body: ListView(
          children: const [
            SizedBox(height: 16),
            _PremiumSection(),
            Divider(),
            _ThemeSection(),
            Divider(),
            _LanguageSection(),
            Divider(),
            _SecuritySection(),
            Divider(),
            _NotificationSection(),
            Divider(),
            _BackupSection(),
            Divider(),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({required this.value, required this.label});

  final String value;
  final String Function(AppLocalizations loc) label;
}

const List<_LanguageOption> _languageOptions = [
  _LanguageOption(value: 'system', label: _deviceDefaultLabel),
  _LanguageOption(value: 'en', label: _englishLabel),
  _LanguageOption(value: 'es', label: _spanishLabel),
  _LanguageOption(value: 'fr', label: _frenchLabel),
  _LanguageOption(value: 'it', label: _italianLabel),
];

String _deviceDefaultLabel(AppLocalizations loc) => loc.deviceDefault;
String _englishLabel(AppLocalizations loc) => loc.english;
String _spanishLabel(AppLocalizations loc) => loc.spanish;
String _frenchLabel(AppLocalizations loc) => loc.french;
String _italianLabel(AppLocalizations loc) => loc.italian;

class _PremiumSection extends StatelessWidget {
  const _PremiumSection();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final premium = context.watch<PremiumProvider>();

    return ListTile(
      leading: const Icon(Icons.workspace_premium, color: Colors.amber),
      title: Text(loc.premiumVersion),
      subtitle: Text(premium.isPremium ? loc.premiumPlan : loc.freePlan),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).pushNamed('/premium');
      },
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

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

class _ThemeOption {
  const _ThemeOption({
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

const List<_ThemeOption> _themeOptions = [
  _ThemeOption(icon: Icons.auto_awesome, label: _defaultThemeLabel),
  _ThemeOption(
    icon: Icons.eco,
    label: _relvaThemeLabel,
    familyKey: CustomColorSchemes.relvaFamilyKey,
    premium: true,
  ),
  _ThemeOption(
    icon: Icons.local_florist_outlined,
    label: _outonoThemeLabel,
    familyKey: CustomColorSchemes.outonoFamilyKey,
    premium: true,
  ),
  _ThemeOption(
    icon: Icons.cloud_outlined,
    label: _ceuThemeLabel,
    familyKey: CustomColorSchemes.ceuFamilyKey,
    premium: true,
  ),
  _ThemeOption(
    icon: Icons.wb_incandescent_outlined,
    label: _confortThemeLabel,
    familyKey: CustomColorSchemes.confortFamilyKey,
    premium: true,
  ),
  _ThemeOption(
    icon: Icons.wb_twilight_outlined,
    label: _sunsetThemeLabel,
    familyKey: CustomColorSchemes.sunsetFamilyKey,
    premium: true,
  ),
  _ThemeOption(
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

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

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
              _SchemePreview(themeProvider: themeProvider),
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
                          _ThemeModeButton(
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
                          _ThemeModeButton(
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
                      _ThemeListOption(
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
                        _ThemeListOption(
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

class _SchemePreview extends StatelessWidget {
  const _SchemePreview({required this.themeProvider});

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

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.enabled,
    required this.onPressed,
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

class _ThemeListOption extends StatelessWidget {
  const _ThemeListOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.onLockedTap,
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

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Consumer<SettingsSecurityProvider>(
      builder: (context, security, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: loc.security),
            ListTile(
              leading: const Icon(Icons.pin),
              title: Text(loc.pinUnlock),
              subtitle: Text(security.pinEnabled ? loc.enabled : loc.disabled),
              trailing: Switch(
                value: security.pinEnabled,
                onChanged: (value) => _onPinToggle(context, value),
              ),
            ),
            if (security.pinEnabled)
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(loc.changePin),
                dense: true,
                onTap: () => _openSetupPin(context, isChanging: true),
              ),
            if (security.pinEnabled || security.biometricEnabled)
              ListTile(
                leading: const Icon(Icons.lock_clock),
                title: Text(loc.backgroundLock),
                subtitle: Text(
                  '${loc.backgroundLock}: '
                  '${InactivityService.getBackgroundTimeoutLabel(security.backgroundLockTimeout, loc)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showBackgroundLockTimeoutDialog(context),
              ),
            if (security.pinEnabled)
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(loc.informYourEmail),
                subtitle: Text(security.userEmail ?? loc.noEmailRegistered),
                onTap: () => _showEmailDialog(context),
              ),
            const Divider(),
            if (!security.biometricAvailable)
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: Text(loc.biometrics),
                subtitle: Text(loc.biometricsNotAvailable),
              )
            else
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: Text(loc.enableBiometrics),
                subtitle: Text(
                  security.biometricEnabled ? loc.enabled : loc.disabled,
                ),
                trailing: Switch(
                  value: security.biometricEnabled,
                  onChanged: (value) => _onBiometricToggle(context, value),
                ),
              ),
            if (security.biometricEnabled)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(loc.information),
                subtitle: Text(loc.biometricConfiguredInfo),
                dense: true,
              ),
          ],
        );
      },
    );
  }

  Future<void> _openSetupPin(
    BuildContext context, {
    required bool isChanging,
  }) async {
    final navigator = Navigator.of(context);
    final security = context.read<SettingsSecurityProvider>();
    final result = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (context) => SetupPinScreen(isChanging: isChanging),
      ),
    );
    if (result == true) {
      await security.refreshPinStatus();
    }
  }

  Future<void> _onPinToggle(BuildContext context, bool value) async {
    if (value) {
      await _openSetupPin(context, isChanging: false);
      return;
    }

    final loc = AppLocalizations.of(context)!;
    final security = context.read<SettingsSecurityProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final successMessage = loc.pinConfiguredSuccess;
    final incorrectMessage = loc.pinIncorrect;

    final pin = await showDialog<String>(
      context: context,
      builder: (context) => const _PinConfirmationDialog(),
    );
    if (pin == null) return;

    final success = await security.disablePin(pin);
    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : incorrectMessage),
        backgroundColor: success ? AppColors.emoticonGreen : errorColor,
      ),
    );
  }

  Future<void> _onBiometricToggle(BuildContext context, bool value) async {
    final loc = AppLocalizations.of(context)!;
    final security = context.read<SettingsSecurityProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;

    if (!value) {
      await security.disableBiometric();
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc.biometricsDisabled),
          backgroundColor: tertiaryColor,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final credentials = await showDialog<_BiometricCredentials>(
      context: context,
      builder: (context) => const _BiometricCredentialsDialog(),
    );
    if (credentials == null) return;

    final validCredentials = await authProvider.verifyCredentials(
      email: credentials.email,
      password: credentials.password,
    );
    if (!validCredentials) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc.invalidCredentials),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    final enabled = await security.enableBiometric(
      email: credentials.email,
      password: credentials.password,
      reason: loc.confirmIdentityToEnableBiometrics,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          enabled ? loc.biometricsEnabledSuccess : loc.biometricAuthFailed,
        ),
        backgroundColor: enabled ? AppColors.emoticonGreen : errorColor,
      ),
    );
  }

  Future<void> _showBackgroundLockTimeoutDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final security = context.read<SettingsSecurityProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final selectedSeconds = await showDialog<int>(
      context: context,
      builder: (context) => _BackgroundLockTimeoutDialog(
        initialSeconds: security.backgroundLockTimeout,
      ),
    );
    if (selectedSeconds == null) return;

    final message =
        '${loc.backgroundLock}: '
        '${InactivityService.getBackgroundTimeoutLabel(selectedSeconds, loc)}';
    await security.setBackgroundLockTimeout(selectedSeconds);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showEmailDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final security = context.read<SettingsSecurityProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final email = await showDialog<String>(
      context: context,
      builder: (context) => _EmailDialog(initialEmail: security.userEmail),
    );
    if (email == null) return;

    await security.saveUserEmail(email);
    messenger.showSnackBar(
      SnackBar(
        content: Text(loc.profileUpdatedSuccess),
        backgroundColor: AppColors.emoticonGreen,
      ),
    );
  }
}

class _BiometricCredentials {
  const _BiometricCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class _BiometricCredentialsDialog extends StatefulWidget {
  const _BiometricCredentialsDialog();

  @override
  State<_BiometricCredentialsDialog> createState() =>
      _BiometricCredentialsDialogState();
}

class _BiometricCredentialsDialogState
    extends State<_BiometricCredentialsDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.enableBiometrics),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.biometricLoginError),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: loc.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: loc.password,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final email = _emailController.text.trim();
            final password = _passwordController.text;
            if (email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.fillEmailAndPassword),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
              return;
            }

            Navigator.of(
              context,
            ).pop(_BiometricCredentials(email: email, password: password));
          },
          child: Text(loc.confirm),
        ),
      ],
    );
  }
}

class _PinConfirmationDialog extends StatefulWidget {
  const _PinConfirmationDialog();

  @override
  State<_PinConfirmationDialog> createState() => _PinConfirmationDialogState();
}

class _PinConfirmationDialogState extends State<_PinConfirmationDialog> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.changePin),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.enterCurrentPin),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _pinController,
            label: loc.currentPinLabel,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final pin = _pinController.text.trim();
            if (pin.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.enterPin),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
              return;
            }

            Navigator.of(context).pop(pin);
          },
          child: Text(loc.confirm),
        ),
      ],
    );
  }
}

class _BackgroundLockTimeoutDialog extends StatefulWidget {
  const _BackgroundLockTimeoutDialog({required this.initialSeconds});

  final int initialSeconds;

  @override
  State<_BackgroundLockTimeoutDialog> createState() =>
      _BackgroundLockTimeoutDialogState();
}

class _BackgroundLockTimeoutDialogState
    extends State<_BackgroundLockTimeoutDialog> {
  late int _selectedSeconds = widget.initialSeconds;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        loc.backgroundLock,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.labelColor(context),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.backgroundLockDialogPrompt),
            const SizedBox(height: 16),
            Text(
              loc.backgroundLockSuggestions,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.labelColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final seconds
                    in InactivityService.backgroundTimeoutOptions)
                  ActionChip(
                    label: Text(
                      InactivityService.getBackgroundTimeoutLabel(seconds, loc),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _selectedSeconds == seconds
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: () {
                      setState(() => _selectedSeconds = seconds);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedSeconds),
          child: Text(loc.save),
        ),
      ],
    );
  }
}

class _EmailDialog extends StatefulWidget {
  const _EmailDialog({required this.initialEmail});

  final String? initialEmail;

  @override
  State<_EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends State<_EmailDialog> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        loc.informYourEmail,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.labelColor(context),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.informYourEmail),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: loc.email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () {
            final email = _emailController.text.trim();
            if (email.isEmpty || !email.contains('@')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.emailInvalid),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
              return;
            }

            Navigator.of(context).pop(email);
          },
          child: Text(loc.save),
        ),
      ],
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _SectionTitle(title: loc.notifications)),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                icon: const Icon(Icons.info_outline, size: 20),
                label: Text(
                  loc.information,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => _openBackgroundRestrictionsInfoScreen(context),
              ),
            ],
          ),
        ),
        Consumer<NotificationPreferencesProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.isLoading &&
                !notificationProvider.isLoaded) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(loc.entryNotifications),
                  subtitle: Text(
                    notificationProvider.notificationEnabled
                        ? loc.enabled
                        : loc.disabled,
                  ),
                  trailing: Switch(
                    value: notificationProvider.notificationEnabled,
                    onChanged: (value) {
                      unawaited(
                        notificationProvider.setNotificationEnabled(value),
                      );
                    },
                  ),
                ),
                if (notificationProvider.notificationEnabled)
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(loc.defaultAdvanceTitle),
                    subtitle: Text(
                      NotificationPreferencesService.getLocalizedAdvanceLabel(
                        notificationProvider.notificationAdvance,
                        loc,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showNotificationAdvanceDialog(context),
                    dense: true,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _openBackgroundRestrictionsInfoScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BackgroundRestrictionsInfoScreen(),
      ),
    );
  }

  Future<void> _showNotificationAdvanceDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final notificationProvider = context
        .read<NotificationPreferencesProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final value = await showDialog<int>(
      context: context,
      builder: (context) => _NotificationAdvanceDialog(
        selectedMinutes: notificationProvider.notificationAdvance,
      ),
    );
    if (value == null) return;

    await notificationProvider.setNotificationAdvance(value);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${loc.notificationAdvanceDefault}: '
          '${NotificationPreferencesService.getLocalizedAdvanceLabel(value, loc)}',
        ),
      ),
    );
  }
}

class _NotificationAdvanceDialog extends StatelessWidget {
  const _NotificationAdvanceDialog({required this.selectedMinutes});

  final int selectedMinutes;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.notificationAdvanceTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.notificationAdvancePrompt),
          const SizedBox(height: 16),
          RadioGroup<int>(
            groupValue: selectedMinutes,
            onChanged: (value) {
              if (value == null) return;
              Navigator.of(context).pop(value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final minutes
                    in NotificationPreferencesService.advanceOptions)
                  RadioListTile<int>(
                    title: Text(
                      NotificationPreferencesService.getLocalizedAdvanceLabel(
                        minutes,
                        loc,
                      ),
                    ),
                    value: minutes,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.close),
        ),
      ],
    );
  }
}

class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: loc.backup),
        ListTile(
          leading: const Icon(Icons.folder_zip),
          title: Text(loc.manageCompleteBackup),
          subtitle: Text(loc.backupWithVideosZip),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/backup-manager'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _SectionTitle(title: title),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.labelColor(context),
      ),
    );
  }
}
