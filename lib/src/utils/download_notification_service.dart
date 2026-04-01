import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class DownloadNotificationService {
  static bool _initialized = false;

  /// Call once in main() before runApp()
  static Future<void> init({
    String channelName = 'Downloads',
    String channelDescription = 'Download progress notifications',
    Color progressColor = const Color(0xFF2196F3),
    Color ledColor = const Color(0xFF2196F3),
  }) async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'download_channel',
          channelName: channelName,
          channelDescription: channelDescription,
          defaultColor: progressColor,
          ledColor: ledColor,
          importance: NotificationImportance.Low,
          channelShowBadge: true,
          playSound: false,
          enableVibration: false,
        ),
      ],
    );

    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    return AwesomeNotifications()
        .requestPermissionToSendNotifications();
  }

  static Future<void> showProgress({
    required int id,
    required String title,
    required int progress,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'download_channel',
        title: title,
        body: 'Downloading... $progress%',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progress.toDouble(),
        locked: true,
        autoDismissible: false,
      ),
    );
  }

  static Future<void> complete({
    required int id,
    required String title,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'download_channel',
        title: title,
        body: 'Download completed ✓',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: true,
        locked: false,
      ),
    );
  }

  static Future<void> showError({
    required int id,
    required String title,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'download_channel',
        title: title,
        body: 'Download failed ✗',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: true,
        locked: false,
      ),
    );
  }

  static Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications()
        .cancelNotificationsByChannelKey('download_channel');
  }
}