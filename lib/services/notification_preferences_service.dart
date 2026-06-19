import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';

class NotificationPreferencesService {
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyDefaultAdvanceMinutes =
      'notification_advance_minutes';

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
    return prefs.getBool(_keyNotificationEnabled) ??
        true; // Habilitado por padrão
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

  /// Retorna o label localizado de uma opção de antecedência.
  static String getLocalizedAdvanceLabel(int minutes, AppLocalizations loc) {
    final languageCode = loc.localeName.split('_').first;
    final labels = switch (languageCode) {
      'en' => const <int, String>{
        30: '30 minutes before',
        60: '1 hour before',
        180: '3 hours before',
        1440: '1 day before',
        10080: '1 week before',
      },
      'es' => const <int, String>{
        30: '30 minutos antes',
        60: '1 hora antes',
        180: '3 horas antes',
        1440: '1 día antes',
        10080: '1 semana antes',
      },
      'fr' => const <int, String>{
        30: '30 minutes avant',
        60: '1 heure avant',
        180: '3 heures avant',
        1440: '1 jour avant',
        10080: '1 semaine avant',
      },
      'it' => const <int, String>{
        30: '30 minuti prima',
        60: '1 ora prima',
        180: '3 ore prima',
        1440: '1 giorno prima',
        10080: '1 settimana prima',
      },
      _ => const <int, String>{
        30: '30 minutos antes',
        60: '1 hora antes',
        180: '3 horas antes',
        1440: '1 dia antes',
        10080: '1 semana antes',
      },
    };

    return labels[minutes] ?? getAdvanceLabel(minutes);
  }

  /// Converte minutos para Duration
  static Duration minutesToDuration(int minutes) {
    return Duration(minutes: minutes);
  }
}
