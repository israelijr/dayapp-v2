import 'package:shared_preferences/shared_preferences.dart';

import '../models/insight.dart';

class InsightPreferencesService {
  static const String _shownAtPrefix = 'insight_shown_';
  static const String _dismissedAtPrefix = 'insight_dismissed_';
  static const String _devDismissedPrefix = 'insight_dev_dismissed_';

  String _shownKey(String userId, InsightType type) =>
      '$_shownAtPrefix${userId}_${type.value}';

  String _dismissedKey(String userId, InsightType type) =>
      '$_dismissedAtPrefix${userId}_${type.value}';

  String _devDismissedKey(String userId, InsightType type) =>
      '$_devDismissedPrefix${userId}_${type.value}';

  Future<int?> loadShownTimestamp(String userId, InsightType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shownKey(userId, type));
  }

  Future<void> saveShownTimestamp(
    String userId,
    InsightType type,
    int timestamp,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shownKey(userId, type), timestamp);
  }

  Future<void> removeShown(String userId, InsightType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shownKey(userId, type));
  }

  Future<int?> loadDismissedTimestamp(String userId, InsightType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dismissedKey(userId, type));
  }

  Future<void> saveDismissedTimestamp(
    String userId,
    InsightType type,
    int timestamp,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dismissedKey(userId, type), timestamp);
  }

  Future<void> removeDismissed(String userId, InsightType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedKey(userId, type));
  }

  Future<String?> loadDevDismissed(String userId, InsightType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_devDismissedKey(userId, type));
  }

  Future<void> saveDevDismissed(
    String userId,
    InsightType type,
    String date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_devDismissedKey(userId, type), date);
  }

  Future<void> removeDevDismissed(String userId, InsightType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_devDismissedKey(userId, type));
  }
}
