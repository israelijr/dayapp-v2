import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

/// Serviço para gerenciar notificações de engajamento do usuário.
///
/// Envia notificações convidando o usuário a registrar histórias
/// quando ele fica sem usar o app por mais de 2 dias.
class EngagementService {
  static final EngagementService _instance = EngagementService._internal();
  factory EngagementService() => _instance;
  EngagementService._internal();

  // Chaves para SharedPreferences
  static const String _lastAppUsageKey = 'last_app_usage_timestamp';
  static const String _engagementNotificationsEnabledKey =
      'engagement_notifications_enabled';

  // ID fixo para a notificação de engajamento (para poder cancelar/reagendar)
  static const int _engagementNotificationId = 999999;

  // Tempo de inatividade antes de enviar notificação (2 dias)
  static const Duration _inactivityThreshold = Duration(days: 2);

  // Lista de mensagens de engajamento para variar o conteúdo
  static const List<Map<String, String>> _engagementMessages = [
    {
      'title': 'Como foi seu dia? 📝',
      'body': 'Registre suas memórias e sentimentos no DayApp!',
    },
    {
      'title': 'Sentimos sua falta! 💙',
      'body': 'Que tal escrever sobre como você está se sentindo hoje?',
    },
    {
      'title': 'Sua história te espera ✨',
      'body': 'Compartilhe os momentos especiais do seu dia!',
    },
    {
      'title': 'Momento de reflexão 🌟',
      'body': 'Reserve um tempinho para registrar o que aconteceu.',
    },
    {
      'title': 'Não perca suas memórias! 📖',
      'body': 'Escreva hoje e relembre amanhã.',
    },
  ];

  final NotificationService _notificationService = NotificationService();

  /// Verifica se as notificações de engajamento estão habilitadas
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Habilitado por padrão
    return prefs.getBool(_engagementNotificationsEnabledKey) ?? true;
  }

  /// Habilita ou desabilita as notificações de engajamento
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_engagementNotificationsEnabledKey, enabled);

    if (enabled) {
      // Se habilitou, agenda a próxima notificação
      await scheduleEngagementNotification();
    } else {
      // Se desabilitou, cancela qualquer notificação pendente
      await cancelEngagementNotification();
    }
  }

  /// Registra que o app foi usado e reagenda a notificação de engajamento.
  ///
  /// Deve ser chamado sempre que o usuário abre ou interage com o app.
  Future<void> registerAppUsage() async {
    // Não funciona na web
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastAppUsageKey, now);

    // Reagenda a notificação de engajamento para 2 dias a partir de agora
    await scheduleEngagementNotification();
  }

  /// Retorna a data do último uso do app
  Future<DateTime?> getLastAppUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastAppUsageKey);

    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Agenda uma notificação de engajamento para 2 dias após o último uso
  Future<void> scheduleEngagementNotification() async {
    // Não funciona na web
    if (kIsWeb) return;

    // Verifica se as notificações estão habilitadas
    final enabled = await isEnabled();
    if (!enabled) return;

    // Cancela qualquer notificação anterior
    await cancelEngagementNotification();

    // Calcula a data para enviar a notificação (2 dias a partir de agora)
    final scheduledDate = DateTime.now().add(_inactivityThreshold);

    // Escolhe uma mensagem aleatória
    final message = _getRandomMessage();

    // Agenda a notificação
    await _notificationService.scheduleEngagementNotification(
      id: _engagementNotificationId,
      title: message['title']!,
      body: message['body']!,
      scheduledDate: scheduledDate,
      payload: 'engagement',
    );
  }

  /// Cancela a notificação de engajamento pendente
  Future<void> cancelEngagementNotification() async {
    await _notificationService.cancelNotification(_engagementNotificationId);
  }

  /// Retorna uma mensagem aleatória de engajamento
  Map<String, String> _getRandomMessage() {
    final index = DateTime.now().millisecond % _engagementMessages.length;
    return _engagementMessages[index];
  }

  /// Verifica se o usuário está inativo há mais de 2 dias
  Future<bool> isUserInactive() async {
    final lastUsage = await getLastAppUsage();
    if (lastUsage == null) return false;

    final difference = DateTime.now().difference(lastUsage);
    return difference > _inactivityThreshold;
  }
}
