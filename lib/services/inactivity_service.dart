import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Serviço para gerenciar o bloqueio quando o app volta do segundo plano
class InactivityService {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  static const String _backgroundLockTimeoutKey =
      'background_lock_timeout_seconds';

  /// Valor especial que significa "nunca bloquear"
  static const int neverLockValue = -1;

  /// Tempo padrão de bloqueio em segundo plano
  /// -1 significa nunca bloquear (padrão)
  static const int defaultBackgroundTimeoutSeconds = neverLockValue;

  /// Cache em memória do timeout para exibição instantânea na UI
  int? _cachedTimeout;

  /// Retorna o valor em cache se disponível (síncrono)
  int? get cachedTimeout => _cachedTimeout;

  /// Obtém o tempo de bloqueio em segundo plano configurado (em segundos)
  Future<int> getBackgroundLockTimeout() async {
    if (_cachedTimeout != null) return _cachedTimeout!;
    final prefs = await SharedPreferences.getInstance();
    _cachedTimeout =
        prefs.getInt(_backgroundLockTimeoutKey) ??
        defaultBackgroundTimeoutSeconds;
    return _cachedTimeout!;
  }

  /// Define o tempo de bloqueio em segundo plano (em segundos)
  Future<void> setBackgroundLockTimeout(int seconds) async {
    _cachedTimeout = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_backgroundLockTimeoutKey, seconds);
  }

  /// Opções rápidas de tempo de bloqueio em segundo plano (em segundos)
  static const List<int> backgroundTimeoutOptions = [
    -1, // Nunca bloquear (padrão)
    0, // Imediato
    15, // 15 segundos
    30, // 30 segundos
    60, // 1 minuto
    300, // 5 minutos
    600, // 10 minutos
    1800, // 30 minutos
    3600, // 1 hora
  ];

  /// Retorna o texto descritivo para opções de bloqueio em segundo plano
  static String getBackgroundTimeoutLabel(int seconds, AppLocalizations loc) {
    if (seconds == neverLockValue) return loc.backgroundLockNever;
    if (seconds == 0) return loc.backgroundLockImmediately;
    if (seconds < 60) return loc.backgroundLockSeconds(seconds);
    if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return minutes == 1
            ? loc.backgroundLockOneMinute
            : loc.backgroundLockMinutes(minutes);
      }
      return '$minutes min $remainingSeconds seg';
    }
    final hours = seconds ~/ 3600;
    final remainingMinutes = (seconds % 3600) ~/ 60;
    if (remainingMinutes == 0) {
      return hours == 1
          ? loc.backgroundLockOneHour
          : loc.backgroundLockHours(hours);
    }
    return '$hours h $remainingMinutes min';
  }
}
