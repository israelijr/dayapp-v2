import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../services/biometric_service.dart';
import '../services/pin_recovery_service.dart';

/// Tela de bloqueio com autenticação por PIN e biometria
/// Exibida quando o app retorna do background após o tempo de inatividade
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final List<String> _enteredPin = [];
  final BiometricService _biometricService = BiometricService();
  final PinRecoveryService _recoveryService = PinRecoveryService();
  bool _isLoading = false;
  bool _showError = false;
  bool _isBiometricAvailable = false;
  bool _showRecoveryDialog = false;
  final int _maxPinLength = 8; // PIN pode ter de 4 a 8 dígitos

  /// Controla se está mostrando o modo de desbloqueio por senha
  bool _showPasswordMode = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _checkBiometricAndAutoAuthenticate();
    // Pré-preenche o email do usuário logado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _emailController.text = authProvider.user?.email ?? '';
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAndAutoAuthenticate() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    final isAvailable = await _biometricService.isBiometricAvailable();

    if (!mounted) return;

    setState(() {
      _isBiometricAvailable = isEnabled && isAvailable;
    });

    // Se biometria está habilitada e disponível, E não há PIN configurado,
    // inicia autenticação biométrica automaticamente
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    if (_isBiometricAvailable && !pinProvider.isPinEnabled) {
      // Aguarda um frame para garantir que a tela foi renderizada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _authenticateWithBiometric();
        }
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (!mounted) return;

    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    try {
      setState(() => _isLoading = true);

      // Sinaliza que estamos autenticando com biometria para evitar bloqueio por inatividade
      pinProvider.isAuthenticatingWithBiometrics = true;

      final authenticated = await _biometricService.authenticate(
        reason: AppLocalizations.of(context)!.unlockAppReason,
      );

      if (!mounted) return;

      if (authenticated) {
        // Autentica no provider - força autenticação bem-sucedida
        // O método authenticateWithBiometric já reseta a flag isAuthenticatingWithBiometrics
        pinProvider.authenticateWithBiometric();
        // Provider notifica e isso fecha a tela de bloqueio
      } else {
        // Se falhou, reseta a flag
        pinProvider.isAuthenticatingWithBiometrics = false;
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // Se deu erro, reseta a flag
      pinProvider.isAuthenticatingWithBiometrics = false;
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Autentica com a senha da conta do usuário
  Future<void> _authenticateWithPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _passwordError = AppLocalizations.of(context)!.fillEmailAndPassword;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    final isValid = await authProvider.login(email, password);

    if (!mounted) return;

    if (isValid) {
      // Autenticação por senha bem-sucedida — desbloqueia o app
      pinProvider.authenticateWithBiometric();
      _passwordController.clear();
    } else {
      setState(() {
        _passwordError = AppLocalizations.of(context)!.emailOrPasswordIncorrect;
        _isLoading = false;
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < _maxPinLength) {
      setState(() {
        _enteredPin.add(number);
        _showError = false;
      });
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _showError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final pin = _enteredPin.join();
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final isValid = await pinProvider.authenticate(pin);

    if (!mounted) return;

    if (isValid) {
      setState(() => _isLoading = false);
      // A navegação será tratada automaticamente pelo provider
    } else {
      setState(() {
        _showError = true;
        _enteredPin.clear();
        _isLoading = false;
      });

      // Vibra para indicar erro
      // HapticFeedback.vibrate();
    }
  }

  void _showRecoveryOptions() {
    setState(() => _showRecoveryDialog = true);
  }

  Future<void> _sendRecoveryEmail() async {
    final loc = AppLocalizations.of(context)!;
    final email = await _recoveryService.getUserEmail();

    if (email == null || email.isEmpty) {
      if (!mounted) return;
      _showMessage(loc.noEmailRegistered);
      return;
    }

    setState(() => _isLoading = true);

    final success = await _recoveryService.sendRecoveryCode(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Verifica se conseguiu obter o código gerado
      final hasCode = await _recoveryService.hasActiveRecoveryCode();

      if (hasCode) {
        _showMessage(loc.checkEmailOrUseCode(email));
        // Ativa modo de recuperação no overlay (GlobalLockOverlay troca para PinRecoveryScreen)
        if (mounted) {
          Provider.of<PinProvider>(context, listen: false).startPinRecovery();
        }
      } else {
        _showMessage(loc.errorGeneratingCode);
      }
    } else {
      _showMessage(loc.errorSendingCode);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final bool onlyBiometric =
        _isBiometricAvailable && !pinProvider.isPinEnabled;

    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    final double keyboardButtonSize = isSmallScreen ? 60 : 70;
    final double keypadPadding = isSmallScreen ? 4 : 8;

    return PopScope(
      canPop: false, // Impede voltar
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone de biometria (somente biometria se onlyBiometric, sem cadeado)
                      if (onlyBiometric) ...[
                        Icon(
                          Icons.fingerprint,
                          size: isSmallScreen ? 64 : 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 24),
                      ],

                      // Título
                      Text(
                        loc.unlockTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: isSmallScreen ? 20 : null,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),

                      Text(
                        _showPasswordMode
                            ? loc.enterPasswordToContinue
                            : onlyBiometric
                            ? loc.useBiometricsToContinue
                            : loc.enterPinToContinue,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 13 : null,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 40),

                      // Modo de desbloqueio por SENHA
                      if (_showPasswordMode) ...[
                        _buildPasswordForm(),
                        const SizedBox(height: 16),
                        // Botão para voltar ao modo PIN/biometria
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showPasswordMode = false;
                              _passwordError = null;
                              _passwordController.clear();
                            });
                          },
                          icon: const Icon(Icons.pin, size: 18),
                          label: Text(
                            pinProvider.isPinEnabled
                                ? loc.usePin
                                : loc.useBiometrics,
                          ),
                        ),
                      ] else ...[
                        // Mostra PIN apenas se estiver habilitado
                        if (pinProvider.isPinEnabled) ...[
                          // Indicadores de PIN
                          _buildPinIndicators(),

                          if (_showError) ...[
                            SizedBox(height: isSmallScreen ? 8 : 16),
                            Text(
                              loc.pinIncorrect,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          SizedBox(height: isSmallScreen ? 20 : 40),

                          // Teclado numérico
                          _buildNumericKeypad(keyboardButtonSize, keypadPadding),

                          SizedBox(height: isSmallScreen ? 12 : 24),
                        ],

                        // Botão de biometria
                        if (_isBiometricAvailable) ...[
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : _authenticateWithBiometric,
                            icon: const Icon(Icons.fingerprint),
                            label: Text(
                              onlyBiometric
                                  ? loc.unlockWithBiometrics
                                  : loc.useBiometrics,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 16),
                        ],

                        // Botão para usar senha da conta
                        TextButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _showPasswordMode = true;
                                    _showError = false;
                                    _enteredPin.clear();
                                  });
                                },
                          icon: const Icon(Icons.password, size: 18),
                          label: Text(loc.useAccountPassword),
                        ),

                        SizedBox(height: isSmallScreen ? 4 : 8),

                        // Link para recuperação - apenas se PIN estiver habilitado
                        if (pinProvider.isPinEnabled)
                          TextButton(
                            onPressed: _isLoading ? null : _showRecoveryOptions,
                            child: Text(loc.forgotPin),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              // Indicador de carregamento
              if (_isLoading)
                ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.26),
                  child: const Center(child: CircularProgressIndicator()),
                ),

              // Dialog de recuperação
              if (_showRecoveryDialog)
                ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.recoverPinTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.recoverPinDescription,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() => _showRecoveryDialog = false);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() => _showRecoveryDialog = false);
                                    _sendRecoveryEmail();
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.sendCode,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formulário de desbloqueio por senha da conta
  Widget _buildPasswordForm() {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onSubmitted: (_) => _authenticateWithPassword(),
          ),
          if (_passwordError != null) ...[
            const SizedBox(height: 12),
            Text(
              _passwordError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _authenticateWithPassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(AppLocalizations.of(context)!.unlock),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Provider.of<PinProvider>(
                      context,
                      listen: false,
                    ).startPasswordRecovery();
                  },
            child: Text(AppLocalizations.of(context)!.forgotPassword),
          ),
        ],
      ),
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_maxPinLength, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? Theme.of(context).colorScheme.primary
                : const Color(0x00000000),
            border: Border.all(
              color: _showError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumericKeypad(double buttonSize, double padding) {
    return SizedBox(
      width: (buttonSize + padding * 2) * 3 + 20,
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3'], buttonSize, padding),
          _buildKeypadRow(['4', '5', '6'], buttonSize, padding),
          _buildKeypadRow(['7', '8', '9'], buttonSize, padding),
          _buildKeypadRow(['⌫', '0', 'OK'], buttonSize, padding),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers, double buttonSize, double padding) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return SizedBox(width: buttonSize + padding * 2, height: buttonSize + padding * 2);
        }

        return _buildKeypadButton(number, buttonSize, padding);
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String value, double buttonSize, double padding) {
    final isOk = value == 'OK';
    final isBackspace = value == '⌫';
    final isEnabled = !isOk || _enteredPin.length >= 4;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Material(
        color: const Color(0x00000000),
        child: InkWell(
          onTap: _isLoading
              ? null
              : () {
                  if (isBackspace) {
                    _onBackspacePressed();
                  } else if (isOk) {
                    if (_enteredPin.length >= 4) {
                      _verifyPin();
                    }
                  } else {
                    _onNumberPressed(value);
                  }
                },
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOk
                  ? (isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200))
                  : null,
            ),
            child: Center(
              child: _buildKeypadButtonContent(value, isEnabled, buttonSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButtonContent(String value, bool isEnabled, double buttonSize) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    if (value == '⌫') {
      return Icon(
        Icons.backspace_outlined,
        size: buttonSize * 0.4,
        color: primaryColor,
      );
    } else if (value == 'OK') {
      return Text(
        'OK',
        style: TextStyle(
          fontSize: buttonSize * 0.28,
          fontWeight: FontWeight.bold,
          color: isEnabled
              ? Theme.of(context).colorScheme.onPrimary
              : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
        ),
      );
    } else {
      return Text(
        value,
        style: TextStyle(
          fontSize: buttonSize * 0.45,
          fontWeight: FontWeight.w400,
          color: primaryColor,
        ),
      );
    }
  }
}
