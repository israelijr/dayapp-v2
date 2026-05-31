import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/insight.dart';

class InsightPreferencesService {
  static const String _shownAtPrefix = 'insight_shown_';
  static const String _dismissedAtPrefix = 'insight_dismissed_';
  static const String _devDismissedPrefix = 'insight_dev_dismissed_';
  static const String _cacheKey = 'insight_cache';
  static const String _cacheTimestampKey = 'insight_cache_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

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

  String _cacheKeyFor(String userId) => '${_cacheKey}_$userId';
  String _timestampKeyFor(String userId) => '${_cacheTimestampKey}_$userId';

  Future<List<Insight>?> loadCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final timestampMs = prefs.getInt(_timestampKeyFor(userId));
    if (timestampMs == null) return null;

    final saved = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    if (DateTime.now().difference(saved) >= _cacheDuration) return null;

    final json = prefs.getString(_cacheKeyFor(userId));
    if (json == null || json.isEmpty) return null;

    try {
      return Insight.decodeList(json);
    } catch (e) {
      debugPrint(
        'InsightPreferencesService: cache corrompido para userId=$userId: $e',
      );
      await prefs.remove(_cacheKeyFor(userId));
      await prefs.remove(_timestampKeyFor(userId));
      return null;
    }
  }

  Future<void> saveCache(String userId, List<Insight> insights) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyFor(userId), Insight.encodeList(insights));
    await prefs.setInt(
      _timestampKeyFor(userId),
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
