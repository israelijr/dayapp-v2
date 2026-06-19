import 'package:flutter/material.dart';

import '../services/home_layout_preferences_service.dart';

class HomeLayoutProvider with ChangeNotifier {
  final HomeLayoutPreferencesService _preferencesService =
      HomeLayoutPreferencesService();

  bool _isCardView = true;
  bool get isCardView => _isCardView;

  HomeLayoutProvider() {
    _loadLayoutPreference();
  }

  Future<void> _loadLayoutPreference() async {
    try {
      final value = await _preferencesService.loadIsCardView();
      if (value != null) {
        _isCardView = value;
      }
    } catch (_) {
      // Não interrompe a UI se a preferência falhar ao carregar.
    }
    notifyListeners();
  }

  Future<void> toggleCardView() async {
    _isCardView = !_isCardView;
    notifyListeners();

    try {
      await _preferencesService.saveIsCardView(_isCardView);
    } catch (_) {
      // Falha de persistência não deve quebrar a interface.
    }
  }
}
