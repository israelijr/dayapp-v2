import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../services/biometric_service.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool enableBiometric = false;

  String? errorMessage;
  bool loading = false;
  bool biometricAvailable = false;
  bool biometricEnabled = false;

  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();

    setState(() {
      biometricAvailable = available;
      biometricEnabled = enabled;
    });

    // Se a biometria está habilitada, tenta fazer login automaticamente
    if (enabled && available) {
      _biometricLogin();
    }
  }

  Future<void> _biometricLogin() async {
    final authenticated = await _biometricService.authenticate(
      reason: AppLocalizations.of(context)!.accessAccount,
    );

    if (authenticated) {
      final credentials = await _biometricService.getSavedCredentials();
      if (credentials != null) {
        setState(() {
          loading = true;
          errorMessage = null;
        });

        // ignore: use_build_context_synchronously
        final auth = Provider.of<AuthProvider>(context, listen: false);
        // ignore: use_build_context_synchronously
        final pinProvider = Provider.of<PinProvider>(context, listen: false);
        // ignore: use_build_context_synchronously
        final navigator = Navigator.of(context);

        final success = await auth.login(
          credentials['email']!,
          credentials['password']!,
          remember: true,
        );

        if (!mounted) return;
        setState(() {
          loading = false;
        });

        if (success) {
          // Atualiza o status de login no PinProvider
          // skipPinCheck: true porque o usuário acabou de se autenticar com biometria
          pinProvider.updateUserLoginStatus(true, skipPinCheck: true);

          if (!mounted) return;
          navigator.pushReplacementNamed('/home');
        } else {
          setState(() {
            errorMessage = AppLocalizations.of(context)!.biometricLoginError;
          });
          // Se falhar, desabilita a biometria
          await _biometricService.disableBiometric();
        }
      }
    }
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    // Sempre lembrar o login para persistência
    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text,
      remember: true,
    );
    if (!mounted) return;
    setState(() {
      loading = false;
    });
    if (success) {
      // Atualiza o status de login no PinProvider
      // skipPinCheck: true porque o usuário acabou de se autenticar com email/senha
      pinProvider.updateUserLoginStatus(true, skipPinCheck: true);

      if (!mounted) return;

      if (!mounted) return;
      // Se o login foi bem-sucedido e o usuário marcou para habilitar biometria
      if (enableBiometric && biometricAvailable) {
        await _biometricService.enableBiometric(
          emailController.text.trim(),
          passwordController.text,
        );
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.biometricsEnabledSuccess,
              ),
              backgroundColor: AppColors.emoticonGreen,
            ),
          );
        });
      }
      navigator.pushReplacementNamed('/home');
    } else {
      setState(() {
        errorMessage = 'E-mail ou senha inválidos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Image.asset('assets/icon/icon.png', width: 80, height: 80),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.accessAccount,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: AppLocalizations.of(context)!.informYourEmail,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  label: AppLocalizations.of(context)!.enterPassword,
                  controller: passwordController,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade900),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (biometricAvailable && !biometricEnabled) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: enableBiometric,
                        onChanged: (value) {
                          setState(() {
                            enableBiometric = value ?? false;
                          });
                        },
                        fillColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                        checkColor: AppColors.primary,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.enableBiometrics,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (biometricEnabled) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: loading ? null : _biometricLogin,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(AppLocalizations.of(context)!.enableBiometrics),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loading ? null : () => _login(context),
                    child: loading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.signIn,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/password_recovery');
                  },
                  child: Text(
                    AppLocalizations.of(context)!.forgotPassword,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/create_account');
                  },
                  child: Text(
                    AppLocalizations.of(context)!.noAccountCreateHere,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Informações de contato e privacidade
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.needHelp,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'contato@iijrapp.com.br',
                          queryParameters: {
                            'subject': 'Suporte DayApp - Login',
                            'body':
                                'Olá, preciso de ajuda com o login no DayApp...',
                          },
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                      child: Text(
                        'contato@iijrapp.com.br',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        const url =
                            'https://iijrapp.com.br/politica_de_privacidade';
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.privacyPolicy,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
