import 'package:flutter/material.dart';

import '../services/home_layout_preferences_service.dart';

class HomeLayoutProvider with ChangeNotifier {
  final HomeLayoutPreferencesService _preferencesService =
      HomeLayoutPreferencesService();

  bool _isCardView = true;
  bool get isCardView => _isCardView;

  bool _isGroupsCardView = true;
  bool get isGroupsCardView => _isGroupsCardView;

  HomeLayoutProvider() {
    _loadLayoutPreference();
  }

  Future<void> _loadLayoutPreference() async {
    try {
      final value = await _preferencesService.loadIsCardView();
      if (value != null) {
        _isCardView = value;
      }

      final groupsValue = await _preferencesService.loadIsGroupsCardView();
      if (groupsValue != null) {
        _isGroupsCardView = groupsValue;
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

  Future<void> toggleGroupsCardView() async {
    _isGroupsCardView = !_isGroupsCardView;
    notifyListeners();

    try {
      await _preferencesService.saveIsGroupsCardView(_isGroupsCardView);
    } catch (_) {
      // Falha de persistência não deve quebrar a interface.
    }
  }
}
