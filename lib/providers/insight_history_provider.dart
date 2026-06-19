import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../services/insight_history_service.dart';

/// Filtro de tier para o histórico.
enum HistoryTierFilter { all, freeOnly, premiumOnly }

/// Grupo mensal de entradas do histórico, usado para exibição agrupada.
class InsightHistoryGroup {
  /// Rótulo do mês/ano (ex.: "Março 2026").
  final String label;

  /// Entradas pertencentes a este mês.
  final List<InsightHistoryEntry> entries;

  const InsightHistoryGroup({required this.label, required this.entries});
}

/// Provider de histórico de insights.
///
/// Carregado sob demanda (lazy) — não afeta a inicialização do app.
class InsightHistoryProvider with ChangeNotifier {
  final InsightHistoryService _service;

  InsightHistoryProvider(this._service);

  List<InsightHistoryEntry> _allEntries = [];
  bool _isLoading = false;
  String? _loadedUserId;
  HistoryTierFilter _filter = HistoryTierFilter.all;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  HistoryTierFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  /// Entradas filtradas (tier + busca textual).
  List<InsightHistoryEntry> get entries => _buildFiltered();

  /// Entradas agrupadas por mês.
  List<InsightHistoryGroup> get groups => _buildGroups(_buildFiltered());

  // ---------------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------------

  Future<void> load(String userId, {int? limitDays}) async {
    if (_isLoading) return;
    _isLoading = true;
    _loadedUserId = userId;
    notifyListeners();

    try {
      _allEntries = await _service.getHistory(userId, limitDays: limitDays);
    } catch (e) {
      // Histórico não crítico — falha silenciosa
      _allEntries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_loadedUserId == null) return;
    _allEntries = [];
    await load(_loadedUserId!);
  }

  set filter(HistoryTierFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  set searchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> clearHistory(String userId) async {
    await _service.clearHistory(userId);
    _allEntries = [];
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<InsightHistoryEntry> _buildFiltered() {
    var result = _allEntries;

    // Filtro de tier
    switch (_filter) {
      case HistoryTierFilter.freeOnly:
        result = result.where((e) => !e.isPremium).toList();
        break;
      case HistoryTierFilter.premiumOnly:
        result = result.where((e) => e.isPremium).toList();
        break;
      case HistoryTierFilter.all:
        break;
    }

    // Filtro de busca textual (título ou descrição)
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  List<InsightHistoryGroup> _buildGroups(List<InsightHistoryEntry> entries) {
    if (entries.isEmpty) return [];

    // Agrupa por ano-mês
    final map = <String, List<InsightHistoryEntry>>{};
    for (final entry in entries) {
      final key =
          '${entry.seenAt.year}-${entry.seenAt.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(entry);
    }

    // Ordena chaves da mais recente para a mais antiga
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));

    return keys.map((key) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return InsightHistoryGroup(
        label: _monthYearLabel(month, year),
        entries: map[key]!,
      );
    }).toList();
  }

  String _monthYearLabel(int month, int year) {
    final date = DateTime(year, month);
    final currentYear = DateTime.now().year;

    // Obtém o nome do mês localizado e garante a primeira letra maiúscula
    String monthName = DateFormat.MMMM().format(date);
    if (monthName.isNotEmpty) {
      monthName = '${monthName[0].toUpperCase()}${monthName.substring(1)}';
    }

    return currentYear == year ? monthName : '$monthName $year';
  }
}
