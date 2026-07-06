import 'package:shared_preferences/shared_preferences.dart';

class HomeLayoutPreferencesService {
  static const String _prefKeyIsCardView = 'home_isCardView';
  static const String _prefKeyIsGroupsCardView = 'groups_isCardView';

  Future<bool?> loadIsCardView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyIsCardView);
  }

  Future<void> saveIsCardView(bool isCardView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsCardView, isCardView);
  }

  Future<bool?> loadIsGroupsCardView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyIsGroupsCardView);
  }

  Future<void> saveIsGroupsCardView(bool isCardView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsGroupsCardView, isCardView);
  }
}
