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
/// - ciclo de vida: expiração automática (1 dia) e cooldown (15 dias) após dispensa
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
  static const Duration _cooldownDuration = Duration(days: 15);

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
  /// - Em produção: cooldown de [_cooldownDuration] (15 dias).
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

    // Produção: ciclo de vida completo (expiração + cooldown)
    final now = DateTime.now();
    final visible = <Insight>[];

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
        // Insight foi dispensado (manualmente ou auto-expirado)
        final dismissed = DateTime.fromMillisecondsSinceEpoch(dismissedMs);
        if (now.difference(dismissed) >= _cooldownDuration) {
          // Cooldown encerrou: limpa e reapresenta
          await _preferencesService.removeDismissed(userId, insight.type);
          await _preferencesService.saveShownTimestamp(
            userId,
            insight.type,
            now.millisecondsSinceEpoch,
          );
          visible.add(insight);
          _saveToHistory(userId, insight);
        }
        // Else: ainda em cooldown → não exibe
      } else {
        // Nunca foi dispensado
        final shownMs = await _preferencesService.loadShownTimestamp(
          userId,
          insight.type,
        );
        if (shownMs == null) {
          // Primeira exibição: registra timestamp
          await _preferencesService.saveShownTimestamp(
            userId,
            insight.type,
            now.millisecondsSinceEpoch,
          );
          visible.add(insight);
          _saveToHistory(userId, insight);
        } else {
          final shownAt = DateTime.fromMillisecondsSinceEpoch(shownMs);
          if (now.difference(shownAt) < _visibilityDuration) {
            // Ainda dentro do período de visibilidade
            visible.add(insight);
          } else {
            // Auto-expirou: marca como dispensado para iniciar o cooldown
            await _preferencesService.saveDismissedTimestamp(
              userId,
              insight.type,
              shownAt.add(_visibilityDuration).millisecondsSinceEpoch,
            );
            await _preferencesService.removeShown(userId, insight.type);
            // Não adiciona à lista visível
          }
        }
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
