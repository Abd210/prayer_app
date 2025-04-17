// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton wrapper around `flutter_local_notifications`.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /* ────────────────────────────────────────────────────────────────
     INITIALISATION
     ──────────────────────────────────────────────────────────────── */
  Future<void> init() async {
    // ---------- platform‑specific settings ----------
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);
    tz.initializeTimeZones();

    /* ── Permissions ── */
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Notification permission (POST_NOTIFICATIONS) – Android 13+
    await android?.requestNotificationsPermission();

    // Exact‑alarm permission – Android 12+
    if (android != null &&
        !(await android.canScheduleExactNotifications() ?? false)) {
      final granted = await android.requestExactAlarmsPermission();

      if (granted != true) {
        // TODO: optionally import `permission_handler` and call
        //       `openAppSettings()` so the user can enable “Alarms & reminders”.
        //
        // For now we just log – your UI can show a snackbar/dialog.
        // debugPrint('Exact‑alarm permission still denied');
      }
    }

    // iOS runtime permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /* ────────────────────────────────────────────────────────────────
     PUBLIC API
     ──────────────────────────────────────────────────────────────── */
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool repeatDaily = true,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
      repeatDaily ? DateTimeComponents.time : null,
    );
  }

  /// One‑off test after five seconds.
  Future<void> sendTestNotification() async {
    await scheduleNotification(
      id: 999,
      title: 'Test Prayer Notification',
      body: 'It is time for the test prayer!',
      scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
      repeatDaily: false,
    );
  }

  Future<void> cancelAllNotifications() async => _plugin.cancelAll();
}
