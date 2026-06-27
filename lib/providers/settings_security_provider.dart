import 'package:flutter/foundation.dart';

import '../services/biometric_service.dart';
import '../services/inactivity_service.dart';
import '../services/pin_recovery_service.dart';
import 'pin_provider.dart';

class SettingsSecurityProvider with ChangeNotifier {
  SettingsSecurityProvider({
    required PinProvider pinProvider,
    required String? userId,
    BiometricService? biometricService,
    InactivityService? inactivityService,
    PinRecoveryService? recoveryService,
  }) : _pinProvider = pinProvider,
       _userId = userId,
       _biometricService = biometricService ?? BiometricService(),
       _inactivityService = inactivityService ?? InactivityService(),
       _recoveryService = recoveryService ?? PinRecoveryService() {
    _pinEnabled = _pinProvider.isPinEnabled;
    _biometricEnabled = _pinProvider.isBiometricEnabled;
    _biometricAvailable = _biometricService.cachedAvailable ?? false;
    _backgroundLockTimeout =
        _inactivityService.cachedTimeout ??
        InactivityService.defaultBackgroundTimeoutSeconds;
  }

  final PinProvider _pinProvider;
  final String? _userId;
  final BiometricService _biometricService;
  final InactivityService _inactivityService;
  final PinRecoveryService _recoveryService;

  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  int _backgroundLockTimeout =
      InactivityService.defaultBackgroundTimeoutSeconds;
  bool _isLoading = false;
  Object? _loadError;

  bool get biometricAvailable => _biometricAvailable;
  bool get biometricEnabled => _biometricEnabled;
  bool get pinEnabled => _pinEnabled;
  int get backgroundLockTimeout => _backgroundLockTimeout;
  bool get isLoading => _isLoading;
  Object? get loadError => _loadError;

  Future<void> load() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object?>([
        _biometricService.isBiometricAvailable(),
        _biometricService.isBiometricEnabled(),
        _pinProvider.checkPinEnabled(),
        _inactivityService.getBackgroundLockTimeout(),
      ]);

      _biometricAvailable = results[0] as bool;
      _biometricEnabled = results[1] as bool;
      _pinEnabled = results[2] as bool;
      _backgroundLockTimeout = results[3] as int;
    } catch (error) {
      _loadError = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> disablePin(String pin) async {
    final success = await _pinProvider.disablePin(pin);
    await refreshPinStatus();
    return success;
  }

  Future<void> refreshPinStatus() async {
    _pinEnabled = await _pinProvider.checkPinEnabled();
    _biometricEnabled = _pinProvider.isBiometricEnabled;
    notifyListeners();
  }

  Future<bool> enableBiometric({
    required String email,
    required String password,
    required String reason,
  }) async {
    final authenticated = await _biometricService.authenticate(reason: reason);
    if (!authenticated) return false;

    await _biometricService.enableBiometric(email, password);
    await refreshBiometricStatus();
    return true;
  }

  Future<void> disableBiometric() async {
    await _biometricService.disableBiometric();
    await refreshBiometricStatus();
  }

  Future<void> refreshBiometricStatus() async {
    _biometricAvailable = await _biometricService.isBiometricAvailable();
    _biometricEnabled = await _biometricService.isBiometricEnabled();
    await _pinProvider.refreshBiometricStatus();
    notifyListeners();
  }

  Future<void> setBackgroundLockTimeout(int seconds) async {
    await _inactivityService.setBackgroundLockTimeout(seconds);
    _backgroundLockTimeout = await _inactivityService
        .getBackgroundLockTimeout();
    notifyListeners();
  }
}
