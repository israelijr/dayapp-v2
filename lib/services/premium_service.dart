import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável pelo estado Premium do usuário.
///
/// Arquitetura em camadas:
///   UI → PremiumProvider → PremiumService → (cache local ← futuro: Play Store)
///
/// Hoje (fase 1) o plano é controlado localmente via SharedPreferences.
/// Quando a Play Store for integrada, apenas este serviço será alterado —
/// os providers e widgets permanecem intocados.
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  /// Chave usada no SharedPreferences para persistir o estado premium.
  static const String _keyIsPremium = 'premium_is_active';

  /// Fonte que ativou o premium (útil para auditoria e debug).
  static const String _keyPremiumSource = 'premium_source';

  /// Data de ativação do premium (ISO 8601).
  static const String _keyPremiumActivatedAt = 'premium_activated_at';

  // -------------------------------------------------------------------------
  // Leitura
  // -------------------------------------------------------------------------

  /// Retorna [true] se o usuário tem acesso Premium.
  ///
  /// Em debug (`kDebugMode`) o override manual da tela de debug
  /// tem precedência sobre o valor gravado pelo billing.
  ///
  /// TODO(billing): trocar `_internalTestingPhase` para false ao integrar
  /// o in_app_purchase e publicar para produção paga.
  static const bool _internalTestingPhase = true;

  Future<bool> isPremium() async {
    if (_internalTestingPhase) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  /// Retorna a fonte que ativou o premium (ex.: 'debug', 'play_store').
  Future<String?> getPremiumSource() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPremiumSource);
  }

  /// Retorna a data de ativação do premium, ou null se nunca ativado.
  Future<DateTime?> getPremiumActivatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPremiumActivatedAt);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // -------------------------------------------------------------------------
  // Escrita
  // -------------------------------------------------------------------------

  /// Ativa o plano Premium, registrando a fonte e a data.
  ///
  /// [source] identifica a origem: 'play_store', 'debug', 'promo', etc.
  Future<void> activate({String source = 'play_store'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
    await prefs.setString(_keyPremiumSource, source);
    await prefs.setString(
      _keyPremiumActivatedAt,
      DateTime.now().toIso8601String(),
    );
    debugPrint('PremiumService: Premium ativado via "$source"');
  }

  /// Desativa o plano Premium (expirou, reembolso, cancelamento, etc.).
  Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, false);
    await prefs.remove(_keyPremiumSource);
    await prefs.remove(_keyPremiumActivatedAt);
    debugPrint('PremiumService: Premium desativado');
  }

  // -------------------------------------------------------------------------
  // Métodos exclusivos para modo debug
  // -------------------------------------------------------------------------

  /// Força ativação do premium apenas disponível em modo debug.
  ///
  /// Este método NÃO deve ser chamado em código de produção.
  /// Use a tela de debug para acionar manualmente.
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
