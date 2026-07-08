import 'package:flutter/foundation.dart';

import '../models/insight.dart';
import '../services/insight_history_service.dart';
import '../services/insight_preferences_service.dart';
import '../services/insight_service.dart';

/// Filtro de tier para exibição dos insights (disponível em modo de desenvolvimento).
enum InsightTierFilter {
  all,
  freeOnly,
  premiumOnly;

  String get label {
    switch (this) {
      case InsightTierFilter.all:
        return 'Todos';
      case InsightTierFilter.freeOnly:
        return 'Free';
      case InsightTierFilter.premiumOnly:
        return 'Premium';
    }
  }
}

/// Provider que expõe os insights gerados para a Home.
///
/// Gerencia:
/// - carregamento e cache de insights
/// - ciclo de vida: expiração automática (1 dia) e cooldown (7 dias) após dispensa
/// - dispensa manual pelo usuário
/// - modo desenvolvimento (devMode via kDebugMode):
///   - dispensa por dia: insights dispensados reaparecem no dia seguinte
///   - filtro de tier: exibe apenas Free, apenas Premium ou todos
class InsightProvider with ChangeNotifier {
  final InsightService _service = InsightService();
  final InsightHistoryService _historyService = InsightHistoryService();
  final InsightPreferencesService _preferencesService =
      InsightPreferencesService();

  /// Insights após filtro de ciclo de vida, antes do filtro de tier.
  List<Insight> _lifecycleFiltered = [];
  bool _isLoading = false;
  String? _lastUserId;

  /// Filtro de tier ativo (apenas relevante em devMode).
  InsightTierFilter _tierFilter = InsightTierFilter.all;

  /// Duração que um insight permanece visível antes de desaparecer automaticamente.
  static const Duration _visibilityDuration = Duration(days: 1);

  /// Período de cooldown após dispensa para o insight reaparecer.
  static const Duration _cooldownDuration = Duration(days: 7);

  /// Em modo debug (kDebugMode), aplica regras simplificadas de ciclo de vida.
  bool get devMode => kDebugMode;

  /// Lista de insights disponíveis (filtrados por ciclo de vida e, em dev, por tier).
  List<Insight> get insights {
    final result = devMode
        ? _applyTierFilter(_lifecycleFiltered)
        : _lifecycleFiltered;
    return List.unmodifiable(result);
  }

  /// Indica se há um carregamento em andamento.
  bool get isLoading => _isLoading;

  /// Filtro de tier atual (somente relevante em devMode).
  InsightTierFilter get tierFilter => _tierFilter;

  /// Altera o filtro de tier e atualiza a lista exibida imediatamente.
  set tierFilter(InsightTierFilter value) {
    if (_tierFilter == value) return;
    _tierFilter = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // API Pública
  // ---------------------------------------------------------------------------

  /// Carrega os insights para o usuário aplicando as regras de ciclo de vida.
  Future<void> loadInsights(String userId) async {
    if (_isLoading && _lastUserId == userId) return;
    _isLoading = true;
    _lastUserId = userId;
    notifyListeners();

    try {
      final all = await _service.getInsights(userId);
      _lifecycleFiltered = await _applyLifecycle(userId, all);
    } catch (e) {
      // Insights não são críticos — falha silenciosa
      _lifecycleFiltered = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Força recálculo descartando o cache do serviço.
  Future<void> refresh(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final all = await _service.getInsights(userId, forceRefresh: true);
      _lifecycleFiltered = await _applyLifecycle(userId, all);
    } catch (e) {
      _lifecycleFiltered = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Garante que um insight será exibido no próximo carregamento,
  /// removendo qualquer ciclo de vida de dispensas anteriores.
  Future<void> showInsightOnNextLoad(String userId, InsightType type) async {
    await _preferencesService.removeDismissed(userId, type);
    await _preferencesService.removeShown(userId, type);
  }

  /// Dispensa manualmente um insight.
  ///
  /// - Em devMode: persiste a data (YYYY-MM-DD); o insight reaparece no dia seguinte.
  /// - Em produção: cooldown de [_cooldownDuration] (7 dias).
  Future<void> dismissInsight(String userId, InsightType type) async {
    // Remove da lista local imediatamente para feedback instantâneo
    _lifecycleFiltered = _lifecycleFiltered
        .where((i) => i.type != type)
        .toList();
    notifyListeners();

    if (devMode) {
      await _preferencesService.saveDevDismissed(
        userId,
        type,
        _dateString(DateTime.now()),
      );
      return;
    }

    await _preferencesService.saveDismissedTimestamp(
      userId,
      type,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _preferencesService.removeShown(userId, type);
  }

  // ---------------------------------------------------------------------------
  // Lógica de ciclo de vida
  // ---------------------------------------------------------------------------

  Future<List<Insight>> _applyLifecycle(
    String userId,
    List<Insight> allInsights,
  ) async {
    if (devMode) {
      // Dev: oculta apenas os dispensados hoje; no dia seguinte reaparecem
      final today = _dateString(DateTime.now());
      final visible = <Insight>[];

      for (final insight in allInsights) {
        final dismissedDate = await _preferencesService.loadDevDismissed(
          userId,
          insight.type,
        );
        if (dismissedDate == today) {
          continue; // dispensado hoje — não exibir
        }
        if (dismissedDate != null) {
          await _preferencesService.removeDevDismissed(userId, insight.type);
        }
        visible.add(insight);
        _saveToHistory(userId, insight);
      }
      return visible;
    }

    // Produção: ciclo de vida completo (cooldown de 7 dias e distribuição em lotes de 2 insights a cada 3 dias)
    final now = DateTime.now();
    final visible = <Insight>[];

    // 1. Filtrar os insights elegíveis (os que não estão em cooldown e não são o gráfico de humor)
    final List<Insight> elegiveis = [];

    for (final insight in allInsights) {
      if (insight.type == InsightType.energyChart) {
        visible.add(insight);
        continue;
      }

      final dismissedMs = await _preferencesService.loadDismissedTimestamp(
        userId,
        insight.type,
      );

      if (dismissedMs != null) {
        final dismissed = DateTime.fromMillisecondsSinceEpoch(dismissedMs);
        if (now.difference(dismissed) >= _cooldownDuration) {
          // Cooldown acabou: limpa o status de dispensado para torná-lo elegível novamente
          await _preferencesService.removeDismissed(userId, insight.type);
          elegiveis.add(insight);
        }
      } else {
        elegiveis.add(insight);
      }
    }

    // Se não houver outros insights elegíveis, retorna apenas os já adicionados (como o energyChart)
    if (elegiveis.isEmpty) {
      await _preferencesService.removeCycleStart(userId);
      return visible;
    }

    // 2. Gerenciar o início do ciclo
    int? cycleStartMs = await _preferencesService.loadCycleStart(userId);
    if (cycleStartMs == null) {
      cycleStartMs = now.millisecondsSinceEpoch;
      await _preferencesService.saveCycleStart(userId, cycleStartMs);
    }

    var cycleStart = DateTime.fromMillisecondsSinceEpoch(cycleStartMs);
    var difference = now.difference(cycleStart);
    var horasDecorridas = difference.inHours;

    var loteAtual = horasDecorridas ~/ 72;
    var horasNoLote = horasDecorridas % 72;
    var estaNaJanelaDeExibicao = horasNoLote < 24;

    final totalLotes = (elegiveis.length / 2).ceil();

    // Se o lote atual passou de todos os lotes possíveis, reinicia o ciclo
    if (loteAtual >= totalLotes) {
      cycleStartMs = now.millisecondsSinceEpoch;
      await _preferencesService.saveCycleStart(userId, cycleStartMs);
      cycleStart = now;
      horasDecorridas = 0;
      loteAtual = 0;
      horasNoLote = 0;
      estaNaJanelaDeExibicao = true;
    }

    // 3. Processar cada insight elegível conforme o lote
    for (int i = 0; i < elegiveis.length; i++) {
      final insight = elegiveis[i];
      final loteDoInsight = i ~/ 2;

      if (loteDoInsight == loteAtual) {
        if (estaNaJanelaDeExibicao) {
          // Lote atual e ativo: exibe o insight
          final shownMs = await _preferencesService.loadShownTimestamp(
            userId,
            insight.type,
          );
          if (shownMs == null) {
            final loteStart = cycleStart.add(Duration(hours: 72 * loteAtual));
            await _preferencesService.saveShownTimestamp(
              userId,
              insight.type,
              loteStart.millisecondsSinceEpoch,
            );
            _saveToHistory(userId, insight);
          }
          visible.add(insight);
        } else {
          // Lote atual, mas fora da janela de 24h: expira o insight automaticamente e inicia cooldown
          final loteStart = cycleStart.add(Duration(hours: 72 * loteAtual));
          final expiraEm = loteStart.add(const Duration(days: 1));
          await _preferencesService.saveDismissedTimestamp(
            userId,
            insight.type,
            expiraEm.millisecondsSinceEpoch,
          );
          await _preferencesService.removeShown(userId, insight.type);
        }
      } else if (loteDoInsight < loteAtual) {
        // Lote passado que já expirou por completo: garante que entrem em cooldown
        final loteStart = cycleStart.add(Duration(hours: 72 * loteDoInsight));
        final expiraEm = loteStart.add(const Duration(days: 1));
        await _preferencesService.saveDismissedTimestamp(
          userId,
          insight.type,
          expiraEm.millisecondsSinceEpoch,
        );
        await _preferencesService.removeShown(userId, insight.type);
      } else {
        // Lote futuro: permanece na fila silenciosamente
      }
    }

    return visible;
  }

  /// Filtra insights pelo tier selecionado.
  List<Insight> _applyTierFilter(List<Insight> insights) {
    switch (_tierFilter) {
      case InsightTierFilter.freeOnly:
        return insights.where((i) => !i.isPremium).toList();
      case InsightTierFilter.premiumOnly:
        return insights.where((i) => i.isPremium).toList();
      case InsightTierFilter.all:
        return insights;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers de chave para SharedPreferences
  // ---------------------------------------------------------------------------

  /// Formata uma data como string YYYY-MM-DD para comparação de calendário.
  String _dateString(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Grava insight no histórico de forma assíncrona e silenciosa.
  void _saveToHistory(String userId, Insight insight) {
    _historyService.saveInsight(userId, insight, DateTime.now()).catchError((
      _,
    ) {
      // Histórico não é crítico — falha silenciosa
    });
  }

  /// Expõe o serviço de histórico para que o provider de histórico possa
  /// reutilizá-lo sem instanciar uma segunda conexão.
  InsightHistoryService get historyService => _historyService;
}
