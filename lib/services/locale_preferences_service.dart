import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferencesService {
  static const String _prefsKey = 'app_locale_selection';

  Future<String?> loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  Future<void> saveSelection(String selection) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, selection);
  }
}
