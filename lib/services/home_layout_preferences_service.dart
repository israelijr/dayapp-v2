import 'package:shared_preferences/shared_preferences.dart';

class HomeLayoutPreferencesService {
  static const String _prefKeyIsCardView = 'home_isCardView';

  Future<bool?> loadIsCardView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyIsCardView);
  }

  Future<void> saveIsCardView(bool isCardView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsCardView, isCardView);
  }
}
