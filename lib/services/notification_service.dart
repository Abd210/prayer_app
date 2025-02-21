import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Configure platform-specific initialization settings.
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

    // Initialize the plugin.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Initialize time zone database.
    tz.initializeTimeZones();

    // Request permissions for iOS.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request notifications permission for Android (API 33+).
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedules a notification at [scheduledDate].  
  /// If [repeatDaily] is true (default) then the notification is set to recur daily.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool repeatDaily = true,
  }) async {
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
      // In v18 the androidAllowWhileIdle flag has been replaced by androidScheduleMode.
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Only use matchDateTimeComponents if you want a daily recurring notification.
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }

  /// Helper method to send a test notification after 5 seconds.
  Future<void> sendTestNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 5));
    await scheduleNotification(
      id: 999,
      title: 'Test Prayer Notification',
      body: 'It is time for test prayer!',
      scheduledDate: testTime,
      repeatDaily: false, // test should trigger only once
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
