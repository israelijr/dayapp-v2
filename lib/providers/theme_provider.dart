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
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      // Se não há prefs, define como light e salva
      _themeMode = ThemeMode.light;
      await prefs.setInt(_themeKey, _themeMode.index);
    }
    // Carrega o esquema customizado, se houver
    final storedSchemeKey = prefs.getString(_schemeKey);
    _selectedSchemeKey = CustomColorSchemes.normalizeFamilyKey(storedSchemeKey);
    if (storedSchemeKey != _selectedSchemeKey) {
      if (_selectedSchemeKey == null) {
        await prefs.remove(_schemeKey);
      } else {
        await prefs.setString(_schemeKey, _selectedSchemeKey!);
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Define o esquema customizado pelo nome (chave do map em CustomColorSchemes)
  Future<void> setSelectedSchemeKey(String? key) async {
    _selectedSchemeKey = CustomColorSchemes.normalizeFamilyKey(key);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (_selectedSchemeKey == null) {
      await prefs.remove(_schemeKey);
    } else {
      await prefs.setString(_schemeKey, _selectedSchemeKey!);
    }
  }

  Future<void> waitForLoad() async {
    while (!_isLoaded) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}
