import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

import 'adhan_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  
  // Reference to adhan service
  final AdhanService _adhanService = AdhanService();

  Future<void> init() async {
    print('[NotificationService] Initializing...');
    
    // Skip platform-specific operations if running on web
    if (kIsWeb) {
      print('[NotificationService] Running on web, skipping platform-specific operations');
      return;
    }

    // Initialize adhan service
    await _adhanService.init();

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

    // ✅ Initialize plugin with callback for notification selection
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
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

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final String? prayerName = response.payload;
    print('[NotificationService] Notification tapped: $prayerName');
  }

  /// Schedules a notification at [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool repeatDaily = true,
    String? prayerName,
  }) async {
    // Skip if running on web
    if (kIsWeb) return;
    
    print('[NotificationService] Scheduling notification: $title at $scheduledDate, prayer: $prayerName');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
      payload: prayerName,
    );
    
    // Set up a listener for actual notification trigger time
    final now = DateTime.now();
    final difference = scheduledDate.difference(now).inMilliseconds;
    
    if (difference > 0 && prayerName != null) {
      // Add a slight delay to ensure notification appears first
      Future.delayed(Duration(milliseconds: difference), () {
        // Play adhan when notification time is reached
        _adhanService.playAdhan(prayerName);
      });
    }
  }

  /// Sends a test notification after 5 seconds
  Future<void> sendTestNotification() async {
    // Skip if running on web
    if (kIsWeb) return;
    
    // Play adhan sound immediately for testing
    _adhanService.playAdhan('TEST');
    
    final testTime = DateTime.now().add(const Duration(seconds: 5));
    await scheduleNotification(
      id: 999,
      title: 'Test Prayer Notification',
      body: 'It is time for test prayer!',
      scheduledDate: testTime,
      repeatDaily: false,
      prayerName: 'TEST',
    );
  }

  Future<void> cancelAllNotifications() async {
    // Skip if running on web
    if (kIsWeb) return;
    
    await flutterLocalNotificationsPlugin.cancelAll();
  }
  
  // Toggle general notifications
  Future<void> toggleNotifications(bool enabled) async {
    if (kIsWeb) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', enabled);
    
    if (!enabled) {
      // Cancel all notifications if they're disabled
      await cancelAllNotifications();
    }
    
    print('[NotificationService] Notifications ${enabled ? 'enabled' : 'disabled'}');
  }
  
  // Toggle adhan on/off
  Future<void> toggleAdhan(bool enabled) async {
    await _adhanService.setEnabled(enabled);
  }
  
  // Add new method for settings page
  Future<void> setAdhanEnabled(bool enabled) async {
    await _adhanService.setEnabled(enabled);
  }
  
  // Set adhan volume
  Future<void> setAdhanVolume(double volume) async {
    await _adhanService.setVolume(volume);
  }
  
  // Get adhan settings
  bool get isAdhanEnabled => _adhanService.isEnabled;
  double get adhanVolume => _adhanService.volume;
}