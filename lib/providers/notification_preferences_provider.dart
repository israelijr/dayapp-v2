import 'package:flutter/material.dart';

import '../services/engagement_service.dart';
import '../services/notification_preferences_service.dart';

class NotificationPreferencesProvider with ChangeNotifier {
  final NotificationPreferencesService _preferencesService =
      NotificationPreferencesService();
  final EngagementService _engagementService = EngagementService();

  bool notificationEnabled =
      NotificationPreferencesService.defaultAdvanceMinutes !=
      0; // valor temporário até carregar
  int notificationAdvance =
      NotificationPreferencesService.defaultAdvanceMinutes;
  bool engagementNotificationsEnabled = true;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    notificationEnabled = await _preferencesService.isNotificationEnabled();
    notificationAdvance = await _preferencesService
        .getDefaultNotificationAdvance();
    engagementNotificationsEnabled = await _engagementService.isEnabled();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await _preferencesService.setNotificationEnabled(enabled);
    notificationEnabled = enabled;
    notifyListeners();
  }

  Future<void> setNotificationAdvance(int minutes) async {
    await _preferencesService.setDefaultNotificationAdvance(minutes);
    notificationAdvance = minutes;
    notifyListeners();
  }

  Future<void> setEngagementNotificationsEnabled(bool enabled) async {
    await _engagementService.setEnabled(enabled);
    engagementNotificationsEnabled = enabled;
    notifyListeners();
  }
}
