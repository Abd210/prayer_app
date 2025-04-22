import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    print('[NotificationService] Initializing...');

    // ✅ Create Android channel before initializing
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_channel',
      'Prayer Notifications',
      description: 'Notifications for prayer times',
      importance: Importance.max,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
    print('[NotificationService] Android channel created');

    // ✅ Initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // ✅ Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print('[NotificationService] Plugin initialized');

    // ✅ Initialize time zone database
    tz.initializeTimeZones();

    // ✅ Request permissions
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    if (Platform.isAndroid) {
      await androidPlugin?.requestNotificationsPermission();
    }

    print('[NotificationService] Permissions requested');
  }

  /// Schedules a notification at [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool repeatDaily = true,
  }) async {
    print('[NotificationService] Scheduling notification: $title at $scheduledDate');

    await flutterLocalNotificationsPlugin.zonedSchedule(
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
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }

  /// Sends a test notification after 5 seconds
  Future<void> sendTestNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 5));
    await scheduleNotification(
      id: 999,
      title: 'Test Prayer Notification',
      body: 'It is time for test prayer!',
      scheduledDate: testTime,
      repeatDaily: false,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}