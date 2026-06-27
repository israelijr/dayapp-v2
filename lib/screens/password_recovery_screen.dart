import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/password_recovery_service.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/strong_password_field.dart';

/// Tela de recuperação de senha por token enviado por e-mail.
/// Fluxo em etapas:
/// 1. Informar e-mail cadastrado
/// 2. Enviar código de recuperação por e-mail
/// 3. Digitar o código recebido
/// 4. Definir nova senha
class PasswordRecoveryScreen extends StatefulWidget {
  /// Chamado quando o usuário cancela no modo overlay
  final VoidCallback? onCancel;

  /// Chamado quando a senha é redefinida com sucesso no modo overlay
  final VoidCallback? onSuccess;

  const PasswordRecoveryScreen({this.onCancel, this.onSuccess, super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final PasswordRecoveryService _recoveryService = PasswordRecoveryService();

  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool isNewPasswordValid = false;
  String? errorMessage;
  String? successMessage;

  /// Etapa atual do fluxo de recuperação
  /// 0 = informar e-mail, 1 = digitar código, 2 = nova senha
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Etapa 1: Verificar se o e-mail existe e enviar código de recuperação
  Future<void> _sendRecoveryCode() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(
        () => errorMessage = AppLocalizations.of(context)!.informYourEmail,
      );
      return;
    }

    // Validação básica de formato de e-mail
    if (!RegExp(r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email)) {
      setState(() => errorMessage = AppLocalizations.of(context)!.invalidEmail);
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      successMessage = null;
    });

    // Verifica se o e-mail está cadastrado
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final exists = await auth.emailExists(email);

    if (!mounted) return;

    if (!exists) {
      setState(() {
        loading = false;
        errorMessage = AppLocalizations.of(context)!.emailNotFound;
      });
      return;
    }

    // Gera e envia o código de recuperação
    final success = await _recoveryService.sendRecoveryCode(email);

    if (!mounted) return;

    setState(() => loading = false);

    if (success) {
      setState(() {
        currentStep = 1;
        successMessage = AppLocalizations.of(context)!.codeSent(email);
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.errorResetPassword;
      });
    }
  }

  /// Etapa 2: Verificar o código de recuperação
  Future<void> _verifyCode() async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      setState(() => errorMessage = AppLocalizations.of(context)!.codeMustBe6);
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      successMessage = null;
    });

    final isValid = await _recoveryService.verifyRecoveryCode(code);

    if (!mounted) return;

    setState(() => loading = false);

    if (isValid) {
      setState(() {
        currentStep = 2;
        successMessage = AppLocalizations.of(context)!.codeVerified;
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.codeInvalid;
      });
    }
  }

  /// Etapa 3: Definir nova senha
  Future<void> _resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty) {
      setState(
        () => errorMessage = AppLocalizations.of(context)!.enterNewPassword,
      );
      return;
    }

    final hasMinLength = newPassword.length >= 8;
    final hasUppercase = newPassword.contains(RegExp(r'[A-Z]'));
    final hasLowercase = newPassword.contains(RegExp(r'[a-z]'));
    final hasNumber = newPassword.contains(RegExp(r'[0-9]'));
    final hasSpecial = newPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_+\-=\[\]\/\\]'));

    if (!hasMinLength || !hasUppercase || !hasLowercase || !hasNumber || !hasSpecial) {
      setState(
        () => errorMessage = AppLocalizations.of(context)!.passwordMinLength,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      setState(
        () => errorMessage = AppLocalizations.of(context)!.passwordsDoNotMatch,
      );
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      successMessage = null;
    });

    final email = emailController.text.trim();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updatePasswordByEmail(email, newPassword);

    if (!mounted) return;

    if (success) {
      // Limpa o código de recuperação usado
      await _recoveryService.clearRecoveryCode();

      if (!mounted) return;

      setState(() => loading = false);

      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordResetSuccess),
          backgroundColor: AppColors.emoticonGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      // Fecha a tela: usa callback de overlay ou navegação normal
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        loading = false;
        errorMessage = AppLocalizations.of(context)!.errorResetPassword;
      });
    }
  }

  /// Reenvia o código de recuperação
  Future<void> _resendCode() async {
    final email = emailController.text.trim();

    setState(() {
      loading = true;
      errorMessage = null;
      successMessage = null;
    });

    final success = await _recoveryService.sendRecoveryCode(email);

    if (!mounted) return;

    setState(() => loading = false);

    if (success) {
      setState(() {
        successMessage = AppLocalizations.of(context)!.resendCodeSuccess;
      });
    } else {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.resendCodeError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.forgotPassword,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone e título
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  _getStepTitle(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getStepSubtitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                // Indicador de etapas
                const SizedBox(height: 24),
                _buildStepIndicator(),

                const SizedBox(height: 24),

                // Mensagens de sucesso/erro
                if (successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.emoticonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.emoticonGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            successMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campos de cada etapa
                _buildStepContent(),

                const SizedBox(height: 24),

                // Botão principal
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
                    onPressed: loading ? null : _getStepAction(),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _getStepButtonLabel(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),

                // Botões secundários
                if (currentStep == 1) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: loading ? null : _resendCode,
                    child: Text(
                      AppLocalizations.of(context)!.resendCode,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  FutureBuilder<int?>(
                    future: _recoveryService.getRemainingTime(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppLocalizations.of(context)!.codeExpiresMinutes(snapshot.data!),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],

                if (currentStep > 0) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            setState(() {
                              currentStep = 0;
                              errorMessage = null;
                              successMessage = null;
                              codeController.clear();
                              newPasswordController.clear();
                              confirmPasswordController.clear();
                            });
                          },
                    child: Text(
                      AppLocalizations.of(context)!.backToStart,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o indicador visual de etapas
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(0, AppLocalizations.of(context)!.email),
        _buildStepLine(0),
        _buildStepDot(1, AppLocalizations.of(context)!.codeLabel),
        _buildStepLine(1),
        _buildStepDot(2, AppLocalizations.of(context)!.password),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryVariant
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
            border: isCurrent
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  )
                : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = currentStep > afterStep;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: 40,
        height: 2,
        color: isActive
            ? AppColors.primaryVariant
            : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
      ),
    );
  }

  /// Constrói os campos da etapa atual
  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildCodeStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Etapa 0: Campo de e-mail
  Widget _buildEmailStep() {
    return CustomTextField(
      label: AppLocalizations.of(context)!.informRegisteredEmail,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
    );
  }

  /// Etapa 1: Campo do código de recuperação
  Widget _buildCodeStep() {
    return Column(
      children: [
        CustomTextField(
          controller: codeController,
          label: AppLocalizations.of(context)!.recoveryCodeLabel,
          prefixIcon: const Icon(Icons.lock_outline),
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Etapa 2: Campos de nova senha
  Widget _buildNewPasswordStep() {
    return Column(
      children: [
        StrongPasswordField(
          label: AppLocalizations.of(context)!.newPasswordMinLengthLabel,
          controller: newPasswordController,
          textColor: Theme.of(context).colorScheme.onPrimary,
          successColor: AppColors.emoticonGreen,
          onValidChanged: (valid) {
            setState(() {
              isNewPasswordValid = valid;
            });
          },
        ),
        CustomTextField(
          label: AppLocalizations.of(context)!.confirmNewPasswordLabel,
          controller: confirmPasswordController,
          obscureText: obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () => setState(
              () => obscureConfirmPassword = !obscureConfirmPassword,
            ),
          ),
        ),
      ],
    );
  }

  /// Retorna o título da etapa atual
  String _getStepTitle() {
    switch (currentStep) {
      case 0:
        return AppLocalizations.of(context)!.informYourEmailTitle;
      case 1:
        return AppLocalizations.of(context)!.enterCodeTitle;
      case 2:
        return AppLocalizations.of(context)!.newPasswordTitle;
      default:
        return '';
    }
  }

  /// Retorna o subtítulo da etapa atual
  String _getStepSubtitle() {
    switch (currentStep) {
      case 0:
        return AppLocalizations.of(context)!.emailStepSubtitle;
      case 1:
        return AppLocalizations.of(context)!.codeStepSubtitle;
      case 2:
        return AppLocalizations.of(context)!.passwordStepSubtitle;
      default:
        return '';
    }
  }

  /// Retorna o label do botão principal da etapa atual
  String _getStepButtonLabel() {
    switch (currentStep) {
      case 0:
        return AppLocalizations.of(context)!.sendCodeButtonLabel;
      case 1:
        return AppLocalizations.of(context)!.verifyCodeButtonLabel;
      case 2:
        return AppLocalizations.of(context)!.resetPasswordButtonLabel;
      default:
        return '';
    }
  }

  /// Retorna a ação do botão principal da etapa atual
  VoidCallback _getStepAction() {
    switch (currentStep) {
      case 0:
        return _sendRecoveryCode;
      case 1:
        return _verifyCode;
      case 2:
        return _resetPassword;
      default:
        return () {};
    }
  }
}
