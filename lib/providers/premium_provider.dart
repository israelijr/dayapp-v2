import 'package:flutter/foundation.dart';

import '../services/premium_service.dart';

/// Provider reativo que expõe o estado Premium para a UI.
///
/// As **regras de negócio** ficam aqui como getters nomeados.
/// A UI nunca consulta `isPremium` diretamente — ela usa o getter
/// do recurso específico (ex.: `canUseAutomaticBackup`).
///
/// Isso garante que mover um recurso de Free para Premium (ou vice-versa)
/// é uma mudança de uma linha só, sem tocar em nenhuma tela.
///
/// Exemplo de uso:
/// ```dart
/// final premium = context.watch<PremiumProvider>();
/// if (!premium.canUseAutomaticBackup) {
///   return const PaywallBanner(feature: 'automaticBackup');
/// }
/// ```
class PremiumProvider with ChangeNotifier {
  final PremiumService _service = PremiumService();

  bool _isPremium = false;
  bool _isLoaded = false;
  String? _premiumSource;

  /// [true] após [load()] completar, útil para evitar flash de UI.
  bool get isLoaded => _isLoaded;

  /// Estado bruto do plano. Prefira usar os getters de feature abaixo.
  bool get isPremium => _isPremium;

  /// Fonte que ativou o premium ('debug', 'play_store', etc.).
  String? get premiumSource => _premiumSource;

  // ---------------------------------------------------------------------------
  // Regras de negócio por feature
  //
  // Adicione um getter por feature. Para mover para Premium, apenas
  // troque `true` por `_isPremium`.
  // ---------------------------------------------------------------------------

  /// Backup automático no logout com destino persistente.
  bool get canUseAutomaticBackup => _isPremium;

  /// Libera leituras e métricas mais profundas dos dados do usuário.
  bool get canViewAdvancedInsights => _isPremium;

  /// Libera temas extras além do conjunto padrão gratuito.
  bool get canUsePremiumThemes => _isPremium;

  /// Libera a experiência de capítulos e sugestões automáticas.
  bool get canUseChapters => _isPremium;

  /// Libera o compartilhamento de histórias como imagem.
  bool get canShareStory => _isPremium;

  /// Libera o compartilhamento/exportação de capítulos (PDF/HTML).
  bool get canShareChapter => _isPremium;

  /// Libera a sugestão automática de capítulos.
  bool get canUseAutoChapterSuggestion => _isPremium;

  /// Libera o resumo mensal nos insights.
  bool get canViewMonthlyInsight => _isPremium;

  /// Libera o gráfico de humor de 7 dias nos insights.
  bool get canView7DayMoodInsight => _isPremium;

  // Futuras features — adicione aqui conforme surgir necessidade:
  // bool get canUseCloudSync       => _isPremium;
  // bool get canUseAiAssistance    => _isPremium;
  // bool get canUnlockStoryPacks   => _isPremium;

  // ---------------------------------------------------------------------------
  // Inicialização
  // ---------------------------------------------------------------------------

  /// Carrega o estado Premium do armazenamento.
  /// Deve ser chamado no startup do app (antes de mostrar a UI).
  Future<void> load() async {
    _isPremium = await _service.isPremium();
    _premiumSource = await _service.getPremiumSource();
    _isLoaded = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Métodos de mutação (chamados pelo billing ou pela tela de debug)
  // ---------------------------------------------------------------------------

  /// Ativa o Premium e notifica a UI.
  Future<void> activate({String source = 'play_store'}) async {
    await _service.activate(source: source);
    _isPremium = true;
    _premiumSource = source;
    notifyListeners();
  }

  /// Desativa o Premium e notifica a UI.
  Future<void> deactivate() async {
    await _service.deactivate();
    _isPremium = false;
    _premiumSource = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Debug
  // ---------------------------------------------------------------------------

  /// Alterna entre Free e Premium. Uso exclusivo da tela de debug.
  Future<void> debugToggle() async {
    assert(kDebugMode, 'debugToggle só pode ser chamado em kDebugMode');
    if (_isPremium) {
      await deactivate();
    } else {
      await activate(source: 'debug');
    }
  }
}
