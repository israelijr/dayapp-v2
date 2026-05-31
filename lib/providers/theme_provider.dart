import 'package:flutter/material.dart';

import '../services/theme_preferences_service.dart';
import '../theme/custom_color_schemes.dart';

class ThemeProvider with ChangeNotifier {
  final ThemePreferencesService _preferencesService = ThemePreferencesService();
  ThemeMode _themeMode = ThemeMode.light;
  String? _selectedSchemeKey;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  String? get selectedSchemeKey => _selectedSchemeKey;
  bool get isLoaded => _isLoaded;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final themeIndex = await _preferencesService.loadThemeModeIndex();
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.light;
      await _preferencesService.saveThemeModeIndex(_themeMode.index);
    }

    final storedSchemeKey = await _preferencesService.loadSchemeKey();
    _selectedSchemeKey = CustomColorSchemes.normalizeFamilyKey(storedSchemeKey);
    if (storedSchemeKey != _selectedSchemeKey) {
      await _preferencesService.saveSchemeKey(_selectedSchemeKey);
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    await _preferencesService.saveThemeModeIndex(mode.index);
  }

  /// Define o esquema customizado pelo nome (chave do map em CustomColorSchemes)
  Future<void> setSelectedSchemeKey(String? key) async {
    _selectedSchemeKey = CustomColorSchemes.normalizeFamilyKey(key);
    notifyListeners();

    await _preferencesService.saveSchemeKey(_selectedSchemeKey);
  }

  Future<void> waitForLoad() async {
    while (!_isLoaded) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}
