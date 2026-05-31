import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _schemeKey = 'custom_scheme_key';

  Future<int?> loadThemeModeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey);
  }

  Future<void> saveThemeModeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, index);
  }

  Future<String?> loadSchemeKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_schemeKey);
  }

  Future<void> saveSchemeKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == null) {
      await prefs.remove(_schemeKey);
    } else {
      await prefs.setString(_schemeKey, key);
    }
  }
}
