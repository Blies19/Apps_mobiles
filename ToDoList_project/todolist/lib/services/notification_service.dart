import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initialize() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Canal para notificaciones de tareas',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );

    // 🔥 Pedir permisos al usuario apenas inicialice
    await requestPermission();
  }

  static Future<void> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Pide permiso mostrando un diálogo
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
