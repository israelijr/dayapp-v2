import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

/// Serviço para gerenciamento de PIN de desbloqueio.
/// O PIN é armazenado de forma segura com hash e salt.
class PinService {
  static final PinService _instance = PinService._internal();
  factory PinService() => _instance;
  PinService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();

  // Chaves legadas para migração
  static const String _legacyPinKey = 'user_pin';
  static const String _legacyPinEnabledKey = 'pin_enabled';

  /// Verifica se o PIN está habilitado
  /// Inclui migração automática de dados legados
  Future<bool> isPinEnabled() async {
    // Primeiro verifica no armazenamento seguro
    final secureEnabled = await _secureStorage.isPinEnabled();
    if (secureEnabled) return true;

    // Verifica se há dados legados para migrar
    final prefs = await SharedPreferences.getInstance();
    final legacyEnabled = prefs.getBool(_legacyPinEnabledKey) ?? false;

    return legacyEnabled;
  }

  /// Habilita/desabilita o PIN
  Future<void> setPinEnabled(bool enabled) async {
    await _secureStorage.setPinEnabled(enabled);
  }

  /// Salva um novo PIN (com hash e salt seguro)
  Future<void> savePin(String pin) async {
    if (pin.length < 4 || pin.length > 8) {
      throw ArgumentError('PIN deve ter entre 4 e 8 dígitos');
    }

    // Verifica se contém apenas números
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError('PIN deve conter apenas números');
    }

    await _secureStorage.savePin(pin);

    // Remove dados legados se existirem
    await _removeLegacyData();
  }

  /// Verifica se o PIN está correto
  /// Suporta migração de PINs antigos (sem salt)
  Future<bool> verifyPin(String pin) async {
    // Primeiro tenta verificar no armazenamento seguro
    final secureVerify = await _secureStorage.verifyPin(pin);
    if (secureVerify) return true;

    // Verifica se há PIN legado para migrar
    final prefs = await SharedPreferences.getInstance();
    final legacyPin = prefs.getString(_legacyPinKey);

    if (legacyPin != null) {
      // Verifica usando o método antigo (suporta hash sem salt)
      if (_secureStorage.verifyHash(pin, legacyPin)) {
        // Migra para armazenamento seguro com novo salt
        await _secureStorage.savePin(pin);
        await _removeLegacyData();
        return true;
      }
    }

    return false;
  }

  /// Remove o PIN e desabilita a funcionalidade
  Future<void> removePin() async {
    await _secureStorage.removePin();
    await _removeLegacyData();
  }

  /// Verifica se existe um PIN salvo
  Future<bool> hasPin() async {
    // Verifica armazenamento seguro
    final secureHasPin = await _secureStorage.hasPin();
    if (secureHasPin) return true;

    // Verifica dados legados
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_legacyPinKey) != null;
  }

  /// Remove dados legados do SharedPreferences
  Future<void> _removeLegacyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyPinKey);
    await prefs.remove(_legacyPinEnabledKey);
  }
}
