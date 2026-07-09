import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/pin_service.dart';

class PinProvider extends ChangeNotifier {
  final PinService _pinService = PinService();
  final BiometricService _biometricService = BiometricService();

  bool _isAuthenticated = false;
  bool _isPinEnabled = false;
  bool _isBiometricEnabled = false;
  bool _shouldShowPinScreen = false;
  bool _isUserLoggedIn = false;

  /// Controla se o overlay deve mostrar a tela de recuperação de PIN
  bool _showPinRecovery = false;

  /// Controla se o overlay deve mostrar a tela de recuperação de senha
  bool _showPasswordRecovery = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isPinEnabled => _isPinEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get shouldShowPinScreen => _shouldShowPinScreen;
  bool get showPinRecovery => _showPinRecovery;
  bool get showPasswordRecovery => _showPasswordRecovery;

  /// Ativa o modo de recuperação de PIN no overlay
  void startPinRecovery() {
    _showPinRecovery = true;
    notifyListeners();
  }

  /// Desativa o modo de recuperação de PIN no overlay
  void stopPinRecovery() {
    _showPinRecovery = false;
    notifyListeners();
  }

  /// Ativa o modo de recuperação de senha no overlay
  void startPasswordRecovery() {
    _showPasswordRecovery = true;
    notifyListeners();
  }

  /// Desativa o modo de recuperação de senha no overlay
  void stopPasswordRecovery() {
    _showPasswordRecovery = false;
    notifyListeners();
  }

  /// Retorna true se qualquer método de bloqueio está habilitado (PIN ou Biometria)
  bool get isLockEnabled => _isPinEnabled || _isBiometricEnabled;

  /// Flag para evitar loop de bloqueio durante autenticação biométrica
  /// Campo público pois é apenas controle interno/externo sem notificação de listeners
  bool isAuthenticatingWithBiometrics = false;

  /// Flag para evitar bloqueio quando o usuário está selecionando mídia externa
  /// (galeria, câmera, file picker, etc.)
  /// Quando o app vai para background para abrir a galeria/câmera, não deve bloquear
  bool isPickingExternalMedia = false;

  /// Flag para indicar que o usuário está no fluxo de anexar mídia (imagem, áudio, vídeo)
  /// Ativa uma tolerância de 30 segundos no bloqueio em segundo plano.
  bool _isAttachingMedia = false;

  bool get isAttachingMedia => _isAttachingMedia;

  set isAttachingMedia(bool value) {
    _isAttachingMedia = value;
    notifyListeners();
  }

  // Setters públicos para controle direto (usado por biometria)
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  set shouldShowPinScreen(bool value) {
    _shouldShowPinScreen = value;
    notifyListeners();
  }

  /// Método público para autenticação por biometria
  void authenticateWithBiometric() {
    _isAuthenticated = true;
    _shouldShowPinScreen = false;
    // Não resetamos a flag aqui. Deixamos o main.dart resetar quando consumir o evento
    // ou o LockScreen resetar em caso de erro.
    notifyListeners();
  }

  /// Inicializa o provider verificando se o PIN ou biometria estão habilitados
  /// Requer que o status de login do usuário seja informado
  Future<void> initialize({bool isUserLoggedIn = false}) async {
    _isUserLoggedIn = isUserLoggedIn;
    _isPinEnabled = await _pinService.isPinEnabled();
    _isBiometricEnabled = await _biometricService.isBiometricEnabled();

    debugPrint(
      'PinProvider.initialize: isUserLoggedIn=$_isUserLoggedIn, isPinEnabled=$_isPinEnabled, isBiometricEnabled=$_isBiometricEnabled',
    );

    // Mostra tela de bloqueio se o usuário estiver logado E algum método de bloqueio estiver habilitado
    if (_isUserLoggedIn && isLockEnabled) {
      _isAuthenticated = false;
      _shouldShowPinScreen = true;
      debugPrint('PinProvider.initialize: shouldShowPinScreen=true');
    } else {
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
      debugPrint('PinProvider.initialize: shouldShowPinScreen=false');
    }

    notifyListeners();
  }

  /// Habilita o PIN com o código fornecido
  Future<bool> enablePin(String pin) async {
    try {
      await _pinService.savePin(pin);
      _isPinEnabled = true;
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Desabilita o PIN
  Future<bool> disablePin(String currentPin) async {
    try {
      final isValid = await _pinService.verifyPin(currentPin);
      if (!isValid) return false;

      await _pinService.removePin();
      _isPinEnabled = false;
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Autentica com o PIN
  Future<bool> authenticate(String pin) async {
    try {
      final isValid = await _pinService.verifyPin(pin);
      if (isValid) {
        _isAuthenticated = true;
        _shouldShowPinScreen = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Força a exibição da tela de bloqueio (quando o app volta do background)
  void requireAuthentication({bool force = false}) {
    if (!force) {
      // Não bloqueia se está selecionando mídia externa (galeria, câmera, file picker)
      if (isPickingExternalMedia) {
        debugPrint(
          'PinProvider.requireAuthentication: Ignorado - isPickingExternalMedia=true',
        );
        return;
      }

      // Não bloqueia se está anexando mídia (imagem, áudio, vídeo)
      if (isAttachingMedia) {
        debugPrint(
          'PinProvider.requireAuthentication: Ignorado - isAttachingMedia=true',
        );
        return;
      }
    }

    // Não bloqueia se está autenticando com biometria
    if (isAuthenticatingWithBiometrics && !force) {
      debugPrint(
        'PinProvider.requireAuthentication: Ignorado - isAuthenticatingWithBiometrics=true',
      );
      return;
    }

    // Exige autenticação se o usuário estiver logado E algum método de bloqueio estiver habilitado
    if (_isUserLoggedIn && isLockEnabled) {
      _isAuthenticated = false;
      _shouldShowPinScreen = true;
      notifyListeners();
    }
  }

  /// Verifica se o PIN está habilitado
  Future<bool> checkPinEnabled() async {
    _isPinEnabled = await _pinService.isPinEnabled();
    _isBiometricEnabled = await _biometricService.isBiometricEnabled();
    notifyListeners();
    return _isPinEnabled;
  }

  /// Atualiza o status de biometria
  Future<void> refreshBiometricStatus() async {
    _isBiometricEnabled = await _biometricService.isBiometricEnabled();
    notifyListeners();
  }

  /// Altera o PIN
  Future<bool> changePin(String currentPin, String newPin) async {
    try {
      final isValid = await _pinService.verifyPin(currentPin);
      if (!isValid) return false;

      await _pinService.savePin(newPin);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Atualiza o status de login do usuário
  /// Deve ser chamado quando o usuário faz login ou logout
  /// [isLoggedIn] - se o usuário está logado
  /// [skipPinCheck] - se true, não pede PIN imediatamente (útil após login manual)
  void updateUserLoginStatus(bool isLoggedIn, {bool skipPinCheck = false}) {
    _isUserLoggedIn = isLoggedIn;

    // Se o usuário fez logout, limpa a autenticação do PIN
    if (!isLoggedIn) {
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
    } else if (isLockEnabled && !skipPinCheck) {
      // Se o usuário fez login e algum bloqueio está habilitado, requer autenticação
      // (mas não imediatamente após login manual)
      _isAuthenticated = false;
      _shouldShowPinScreen = true;
    } else {
      // Login manual ou nenhum bloqueio habilitado - usuário já está autenticado
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
    }

    notifyListeners();
  }

  /// Atualiza o status de PIN habilitado (útil após recuperação de PIN)
  void updatePinEnabled(bool enabled) {
    _isPinEnabled = enabled;
    notifyListeners();
  }
}
