import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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

    // Read allowAdhanSound from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final allowAdhanSound = prefs.getBool('allowAdhanSound') ?? true;

    // Ensure the scheduled time is in the future
    if (scheduledDate.isBefore(DateTime.now())) {
      print('[NotificationService] Skipping notification in the past: $scheduledDate');
      return;
    }

    try {
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
            playSound: allowAdhanSound,
            enableVibration: true,
            enableLights: true,
            color: const Color(0xFF16423C), // App primary color
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            // Ensure notification shows even when app is killed
            ongoing: false,
            autoCancel: true,
            // Make notification persistent
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: allowAdhanSound,
            sound: 'adhan_normal.mp3',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
        payload: prayerName,
      );

      print('[NotificationService] Successfully scheduled notification ID: $id for $scheduledDate');
      
      // For debugging: log all pending notifications
      final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('[NotificationService] Total pending notifications: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        print('[NotificationService] Pending: ID ${notification.id} - ${notification.title}');
      }

    } catch (e) {
      print('[NotificationService] Error scheduling notification: $e');
    }
  }

  /// Sends a test notification after 5 seconds
  Future<void> sendTestNotification() async {
    // Skip if running on web
    if (kIsWeb) return;

    // Read allowAdhanSound from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final allowAdhanSound = prefs.getBool('allowAdhanSound') ?? true;

    // Play adhan sound immediately for testing if allowed
    if (allowAdhanSound) {
      _adhanService.playAdhan('TEST');
    }

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
  
  /// Reschedule all notifications when app starts (in case app was force-closed)
  Future<void> rescheduleNotificationsOnStartup() async {
    if (kIsWeb) return;
    
    print('[NotificationService] Rescheduling notifications on startup...');
    
    try {
      // Check if notifications are enabled
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('enableNotifications') ?? true;
      
      if (!notificationsEnabled) {
        print('[NotificationService] Notifications disabled, skipping reschedule');
        return;
      }
      
      // Cancel any existing notifications first
      await cancelAllNotifications();
      
      // Get current pending notifications for debugging
      final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('[NotificationService] Found ${pendingNotifications.length} existing pending notifications');
      
      // The actual rescheduling will be done by the prayer times page
      // when it calls _scheduleToday() which will then call this service
      
    } catch (e) {
      print('[NotificationService] Error during startup reschedule: $e');
    }
  }
  
  /// Check if notifications are working properly
  Future<bool> checkNotificationPermissions() async {
    if (kIsWeb) return false;
    
    try {
      if (Platform.isAndroid) {
        final androidPlugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.areNotificationsEnabled() ?? false;
        print('[NotificationService] Android notifications enabled: $granted');
        return granted;
      } else if (Platform.isIOS) {
        final iosPlugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
        print('[NotificationService] iOS notifications granted: $granted');
        return granted;
      }
    } catch (e) {
      print('[NotificationService] Error checking permissions: $e');
    }
    
    return false;
  }
}