import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(Function(String?) onSelectNotification) async {
    // Inicializa timezones
    tz.initializeTimeZones();

    // Obtém o timezone local do dispositivo do usuário
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneInfo.identifier);
      tz.setLocalLocation(location);
    } catch (e) {
      // Fallback para UTC se não conseguir obter o timezone
      // Isso evita crashes em dispositivos com configurações incomuns
      debugPrint('NotificationService: erro ao configurar timezone local: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onSelectNotification(response.payload);
      },
    );

    // Solicitar permissões
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final darwinImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Solicita permissão de notificações
      await androidImplementation.requestNotificationsPermission();
    }

    if (darwinImplementation != null) {
      // Solicita permissões em iOS/macOS para exibir alertas e sons
      await darwinImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'historia_channel',
        'Histórias',
        channelDescription: 'Notificações para histórias',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    if (!kIsWeb && Platform.isWindows) {
      // Para Windows, notificações agendadas podem não ser suportadas
      // Vamos mostrar uma notificação imediata para teste

      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } else {
      // Para outras plataformas, usar zonedSchedule
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );

        // Lista notificações pendentes para debug
        await listPendingNotifications();
      } catch (e) {
        // Erro ao agendar notificação - mantém execução sem quebrar a UI
        debugPrint('NotificationService: erro ao agendar notificação: $e');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  /// Lista todas as notificações pendentes
  Future<List<PendingNotificationRequest>> listPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'historia_channel',
        'Histórias',
        channelDescription: 'Notificações para histórias',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Agenda uma notificação de engajamento para convidar o usuário a usar o app
  ///
  /// Usa um canal específico para notificações de engajamento
  Future<void> scheduleEngagementNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reflection_reminders_channel',
        'Lembretes de Reflexão',
        channelDescription: 'Lembretes carinhosos para registrar suas memórias',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    if (!kIsWeb && Platform.isWindows) {
      // Para Windows, notificações agendadas podem não ser suportadas
      // Ignora silenciosamente
      return;
    }

    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      // Erro ao agendar notificação de engajamento - mantém execução
      debugPrint(
        'NotificationService: erro ao agendar notificação de engajamento: $e',
      );
    }
  }

  /// Retorna o payload de notificação que iniciou o app (cold start).
  /// Deve ser chamado uma única vez durante a inicialização.
  Future<String?> getPendingLaunchPayload() async {
    try {
      final details = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        return details.notificationResponse?.payload;
      }
    } catch (e) {
      // Plataforma pode não suportar este recurso.
      debugPrint('NotificationService: erro ao ler payload de lançamento: $e');
    }
    return null;
  }
}
