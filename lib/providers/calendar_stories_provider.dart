import 'package:flutter/material.dart';

import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../repositories/historia_repository.dart';

class CalendarStoriesProvider with ChangeNotifier {
  final HistoriaRepository _repository;
  final AuthProvider _authProvider;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Map<DateTime, List<Historia>> _historiasMap = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Historia> _selectedDayHistorias = [];
  String? _errorMessage;

  CalendarStoriesProvider({
    required HistoriaRepository repository,
    required AuthProvider authProvider,
  }) : _repository = repository,
       _authProvider = authProvider;

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  List<Historia> get selectedDayHistorias =>
      List.unmodifiable(_selectedDayHistorias);
  String? get errorMessage => _errorMessage;

  DateTime _normalizeDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> loadHistorias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authProvider.user?.id;
      if (userId == null) {
        _historiasMap.clear();
        _selectedDayHistorias = [];
        return;
      }

      final historias = await _repository.fetchUserStories(userId: userId);

      _historiasMap.clear();
      for (final historia in historias) {
        final date = _normalizeDay(historia.data);
        _historiasMap.putIfAbsent(date, () => []).add(historia);
      }

      for (final value in _historiasMap.values) {
        value.sort((a, b) => b.data.compareTo(a.data));
      }

      _selectDay(_selectedDay);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDay(DateTime day) {
    _selectedDay = _normalizeDay(day);
    _focusedDay = day;
    _selectDay(_selectedDay);
    notifyListeners();
  }

  void setFocusedDay(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void _selectDay(DateTime day) {
    final date = _normalizeDay(day);
    _selectedDayHistorias = List.unmodifiable(_historiasMap[date] ?? []);
  }

  List<Historia> getHistoriasForDay(DateTime day) {
    return List.unmodifiable(_historiasMap[_normalizeDay(day)] ?? []);
  }

  Future<void> deleteHistoria(Historia historia) async {
    await _repository.deleteHistoria(historia);
    await loadHistorias();
  }
}
