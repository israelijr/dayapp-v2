import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_security_provider.dart';
import '../../../services/inactivity_service.dart';
import '../../../theme/m3_expressive_theme.dart';
import '../../../widgets/custom_text_field.dart';
import '../../setup_pin_screen.dart';
import 'shared_widgets.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Consumer<SettingsSecurityProvider>(
      builder: (context, security, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: loc.security),
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
            if (security.pinEnabled || security.biometricEnabled) ...[
              const Divider(),
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
            ],
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
      builder: (context) => const PinConfirmationDialog(),
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
    final userEmail = authProvider.user?.email ?? '';
    final credentials = await showDialog<BiometricCredentials>(
      context: context,
      builder: (context) => BiometricCredentialsDialog(
        authProvider: authProvider,
        userEmail: userEmail,
      ),
    );
    if (credentials == null) return;

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
      builder: (context) => BackgroundLockTimeoutDialog(
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
}

class BiometricCredentials {
  const BiometricCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class BiometricCredentialsDialog extends StatefulWidget {
  const BiometricCredentialsDialog({
    required this.authProvider,
    required this.userEmail,
    super.key,
  });

  final AuthProvider authProvider;
  final String userEmail;

  @override
  State<BiometricCredentialsDialog> createState() =>
      BiometricCredentialsDialogState();
}

class BiometricCredentialsDialogState
    extends State<BiometricCredentialsDialog> {
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm(AppLocalizations loc) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = loc.fillEmailAndPassword);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final valid = await widget.authProvider.verifyCredentials(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (!valid) {
      setState(() {
        _isLoading = false;
        _errorMessage = loc.invalidCredentials;
      });
      return;
    }

    Navigator.of(context).pop(
      BiometricCredentials(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.enableBiometrics,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _emailController,
                label: loc.email,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: loc.password,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(loc.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _onConfirm(loc),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(loc.confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PinConfirmationDialog extends StatefulWidget {
  const PinConfirmationDialog({super.key});

  @override
  State<PinConfirmationDialog> createState() => PinConfirmationDialogState();
}

class PinConfirmationDialogState extends State<PinConfirmationDialog> {
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

class BackgroundLockTimeoutDialog extends StatefulWidget {
  const BackgroundLockTimeoutDialog({required this.initialSeconds, super.key});

  final int initialSeconds;

  @override
  State<BackgroundLockTimeoutDialog> createState() =>
      BackgroundLockTimeoutDialogState();
}

class BackgroundLockTimeoutDialogState
    extends State<BackgroundLockTimeoutDialog> {
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
