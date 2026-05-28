import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesService {
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyDefaultAdvanceMinutes = 'notification_advance_minutes';

  // Opções de antecedência em minutos
  static const List<int> advanceOptions = [
    30, // 30 minutos
    60, // 1 hora
    180, // 3 horas
    1440, // 1 dia (24 horas)
    10080, // 1 semana (7 dias)
  ];

  // Antecedência padrão: 1 hora antes
  static const int defaultAdvanceMinutes = 60;

  /// Verifica se as notificações estão habilitadas
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationEnabled) ?? true; // Habilitado por padrão
  }

  /// Habilita ou desabilita as notificações
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationEnabled, enabled);
  }

  /// Retorna o tempo de antecedência padrão em minutos
  Future<int> getDefaultNotificationAdvance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDefaultAdvanceMinutes) ?? defaultAdvanceMinutes;
  }

  /// Define o tempo de antecedência padrão em minutos
  Future<void> setDefaultNotificationAdvance(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultAdvanceMinutes, minutes);
  }

  /// Retorna o label de uma opção de antecedência
  static String getAdvanceLabel(int minutes) {
    switch (minutes) {
      case 30:
        return '30 minutos antes';
      case 60:
        return '1 hora antes';
      case 180:
        return '3 horas antes';
      case 1440:
        return '1 dia antes';
      case 10080:
        return '1 semana antes';
      default:
        return '$minutes minutos antes';
    }
  }

  /// Converte minutos para Duration
  static Duration minutesToDuration(int minutes) {
    return Duration(minutes: minutes);
  }
}
