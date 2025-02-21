import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Headless callback to handle notification actions when the app is terminated.
/// This must be a top-level function and annotated for entry point.
@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse notificationResponse) async {
  // Handle the background notification tap if needed.
  print('Headless notification tapped: ${notificationResponse.payload}');
}

class NotificationService {
  // Singleton instance for ease of use
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data for scheduling notifications
    tz.initializeTimeZones();

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combined initialization settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin with support for background callbacks
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped with payload: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    print("Notification plugin initialized");

    // Request permissions on both platforms
    await _requestPermissions();

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      print("iOS permissions requested");
    } else if (Platform.isAndroid) {
      // For Android 13+ using permission_handler to request POST_NOTIFICATIONS permission
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
        print("Android notification permission requested");
      } else {
        print("Android notification permission already granted");
      }
      // Note: SCHEDULE_EXACT_ALARM must be declared in the manifest.
      // On some devices, the user must manually enable exact alarms in settings.
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_channel', // Channel ID must match the one used in scheduleNotification
      'Prayer Notifications',
      description: 'This channel is used for prayer time notifications.',
      importance: Importance.max,
    );
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
    print("Notification channel created");
  }

  /// Schedules a notification at the given [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print("Scheduling notification (id: $id) at $scheduledDate");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel', // Must match the channel ID created above
          'Prayer Notifications',
          channelDescription: 'This channel is used for prayer time notifications.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Use exact scheduling even while idle (works with Doze mode)
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("Notification scheduled successfully");
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("All notifications cancelled");
  }

  /// Sends a test notification scheduled for 5 seconds from now.
  Future<void> sendTestNotification() async {
    final DateTime scheduledTime = DateTime.now().add(const Duration(seconds: 5));
    print("Sending test notification for $scheduledTime");
    await scheduleNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification.',
      scheduledDate: scheduledTime,
    );
  }
}
