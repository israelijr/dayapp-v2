import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço para armazenamento seguro de dados sensíveis.
/// Usa flutter_secure_storage (Keystore no Android, Keychain no iOS).
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Chaves para armazenamento
  static const String _biometricEmailKey = 'biometric_email';
  static const String _biometricPasswordKey = 'biometric_password';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinKey = 'user_pin';
  static const String _pinSaltKey = 'pin_salt';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _recoveryEmailKey = 'recovery_email';

  // ==================== Utilitários de Criptografia ====================

  /// Gera um salt aleatório de 32 bytes (256 bits)
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  /// Gera hash SHA-256 com salt
  /// Formato: salt$hash
  String hashWithSalt(String value, String salt) {
    final saltedValue = '$salt:$value';
    final bytes = utf8.encode(saltedValue);
    final digest = sha256.convert(bytes);
    return '$salt\$$digest';
  }

  /// Verifica se um valor corresponde ao hash com salt
  bool verifyHash(String value, String storedHash) {
    if (!storedHash.contains('\$')) {
      // Hash antigo sem salt - verifica de forma legada
      final legacyHash = sha256.convert(utf8.encode(value)).toString();
      return legacyHash == storedHash;
    }

    final parts = storedHash.split('\$');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final expectedHash = hashWithSalt(value, salt);
    return expectedHash == storedHash;
  }

  /// Gera hash para senha (mais iterações para maior segurança)
  String hashPassword(String password, String salt) {
    // PBKDF2-like: múltiplas iterações de SHA-256
    var current = '$salt:$password';
    for (int i = 0; i < 10000; i++) {
      current = sha256.convert(utf8.encode(current)).toString();
    }
    return '$salt\$$current';
  }

  /// Verifica senha com o hash armazenado
  bool verifyPassword(String password, String storedHash) {
    if (!storedHash.contains('\$')) {
      // Hash antigo sem salt - verifica de forma legada (texto plano!)
      return password == storedHash;
    }

    final parts = storedHash.split('\$');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final expectedHash = hashPassword(password, salt);
    return expectedHash == storedHash;
  }

  // ==================== Biometria ====================

  /// Salva credenciais para login biométrico de forma segura
  Future<void> saveBiometricCredentials(String email, String password) async {
    await _storage.write(key: _biometricEmailKey, value: email);
    await _storage.write(key: _biometricPasswordKey, value: password);
    await _storage.write(key: _biometricEnabledKey, value: 'true');
  }

  /// Obtém credenciais salvas para login biométrico
  Future<Map<String, String>?> getBiometricCredentials() async {
    final email = await _storage.read(key: _biometricEmailKey);
    final password = await _storage.read(key: _biometricPasswordKey);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Verifica se biometria está habilitada
  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Remove credenciais biométricas
  Future<void> removeBiometricCredentials() async {
    await _storage.delete(key: _biometricEmailKey);
    await _storage.delete(key: _biometricPasswordKey);
    await _storage.delete(key: _biometricEnabledKey);
  }

  // ==================== PIN ====================

  /// Salva PIN com hash e salt
  Future<void> savePin(String pin) async {
    final salt = generateSalt();
    final hashedPin = hashWithSalt(pin, salt);
    await _storage.write(key: _pinKey, value: hashedPin);
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }

  /// Verifica se o PIN está correto
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    return verifyHash(pin, storedHash);
  }

  /// Verifica se existe PIN salvo
  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  /// Verifica se PIN está habilitado
  Future<bool> isPinEnabled() async {
    final enabled = await _storage.read(key: _pinEnabledKey);
    return enabled == 'true';
  }

  /// Habilita/desabilita PIN
  Future<void> setPinEnabled(bool enabled) async {
    await _storage.write(key: _pinEnabledKey, value: enabled.toString());
  }

  /// Remove PIN
  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.write(key: _pinEnabledKey, value: 'false');
  }

  // ==================== E-mail de Recuperação ====================

  /// Salva e-mail de recuperação (global, para compatibilidade)
  Future<void> saveRecoveryEmail(String email) async {
    await _storage.write(key: _recoveryEmailKey, value: email);
  }

  /// Obtém e-mail de recuperação (global)
  Future<String?> getRecoveryEmail() async {
    return await _storage.read(key: _recoveryEmailKey);
  }

  /// Remove e-mail de recuperação (global)
  Future<void> removeRecoveryEmail() async {
    await _storage.delete(key: _recoveryEmailKey);
  }

  /// Salva e-mail de recuperação exclusivo do usuário identificado por [userId]
  Future<void> saveRecoveryEmailForUser(String userId, String email) async {
    await _storage.write(key: '${_recoveryEmailKey}_$userId', value: email);
  }

  /// Obtém e-mail de recuperação exclusivo do usuário identificado por [userId]
  Future<String?> getRecoveryEmailForUser(String userId) async {
    return await _storage.read(key: '${_recoveryEmailKey}_$userId');
  }

  /// Remove e-mail de recuperação exclusivo do usuário identificado por [userId]
  Future<void> removeRecoveryEmailForUser(String userId) async {
    await _storage.delete(key: '${_recoveryEmailKey}_$userId');
  }

  // ==================== Chave de Backup Automático ====================

  static const String _autoBackupKeyKey = '_auto_backup_key';

  /// Retorna a chave de criptografia dos backups automáticos, criando-a
  /// na primeira chamada. A chave é gerada aleatoriamente (256 bits),
  /// armazenada no Keystore do Android e nunca fica exposta fora do dispositivo.
  /// É deletada junto com o app no uninstall, o que é intencional: os arquivos
  /// de backup automático também são deletados no uninstall.
  Future<String> getOrCreateAutoBackupKey() async {
    final existing = await _storage.read(key: _autoBackupKeyKey);
    if (existing != null) return existing;

    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64.encode(keyBytes);
    await _storage.write(key: _autoBackupKeyKey, value: key);
    return key;
  }

  // ==================== Métodos Genéricos ====================

  /// Lê um valor associado à chave.
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Escreve um valor associado à chave.
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Deleta o valor associado à chave.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // ==================== Migração ====================

  /// Migra dados do SharedPreferences para SecureStorage
  /// Chamado uma vez durante a inicialização do app
  Future<void> migrateFromSharedPreferences() async {
    // A migração será feita nos serviços individuais que precisam
    // Este método pode ser usado para lógica de migração centralizada
  }

  /// Limpa todos os dados seguros (usado em logout completo)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
