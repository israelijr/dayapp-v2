import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

/// Serviço responsável pelo estado Premium do usuário.
///
/// Arquitetura em camadas:
///   UI → PremiumProvider → PremiumService → (cache local ← futuro: Play Store)
///
/// Implementação Segura: utiliza SecureStorage para evitar manipulação de arquivos.
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final SecureStorageService _storage = SecureStorageService();

  /// Chave usada no SecureStorage para persistir o estado premium.
  static const String _keyIsPremium = 'premium_is_active';

  /// Fonte que ativou o premium (útil para auditoria e debug).
  static const String _keyPremiumSource = 'premium_source';

  /// Data de ativação do premium (ISO 8601).
  static const String _keyPremiumActivatedAt = 'premium_activated_at';

  // -------------------------------------------------------------------------
  // Leitura
  // -------------------------------------------------------------------------

  Future<bool> isPremium() async {
    final raw = await _storage.read(_keyIsPremium);
    return raw == 'true';
  }

  /// Retorna a fonte que ativou o premium (ex.: 'debug', 'play_store').
  Future<String?> getPremiumSource() async {
    return await _storage.read(_keyPremiumSource);
  }

  /// Retorna a data de ativação do premium, ou null se nunca ativado.
  Future<DateTime?> getPremiumActivatedAt() async {
    final raw = await _storage.read(_keyPremiumActivatedAt);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // -------------------------------------------------------------------------
  // Escrita
  // -------------------------------------------------------------------------

  /// Ativa o plano Premium, registrando a fonte e a data.
  ///
  /// [source] identifica a origem: 'play_store', 'debug', 'promo', etc.
  Future<void> activate({String source = 'play_store'}) async {
    await _storage.write(_keyIsPremium, 'true');
    await _storage.write(_keyPremiumSource, source);
    await _storage.write(
      _keyPremiumActivatedAt,
      DateTime.now().toIso8601String(),
    );
    debugPrint('PremiumService: Premium ativado via "$source"');
  }

  /// Desativa o plano Premium (expirou, reembolso, cancelamento, etc.).
  Future<void> deactivate() async {
    await _storage.write(_keyIsPremium, 'false');
    await _storage.delete(_keyPremiumSource);
    await _storage.delete(_keyPremiumActivatedAt);
    debugPrint('PremiumService: Premium desativado');
  }

  // -------------------------------------------------------------------------
  // Métodos exclusivos para modo debug
  // -------------------------------------------------------------------------

  /// Força ativação do premium apenas disponível em modo debug.
  Future<void> debugActivate() async {
    assert(kDebugMode, 'debugActivate só pode ser chamado em kDebugMode');
    await activate(source: 'debug');
  }

  /// Remove o estado premium apenas disponível em modo debug.
  Future<void> debugDeactivate() async {
    assert(kDebugMode, 'debugDeactivate só pode ser chamado em kDebugMode');
    await deactivate();
  }
}
