import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

import 'adhan_service.dart';
import 'azkar_reminder_service.dart';
import '../models/prayer_adjustments.dart';

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
      
      // Check if we need to reschedule (compare with last reschedule date)
      final lastRescheduleDate = prefs.getString('lastNotificationRescheduleDate');
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      // Always reschedule if:
      // 1. No last reschedule date (first time)
      // 2. Last reschedule was not today
      // 3. No pending notifications exist
      bool shouldReschedule = lastRescheduleDate != today;
      
      if (!shouldReschedule) {
        print('[NotificationService] Already rescheduled today, checking if notifications exist...');
        
        // Check if we have any pending notifications
        final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        if (pendingNotifications.isNotEmpty) {
          print('[NotificationService] Found ${pendingNotifications.length} existing notifications, skipping reschedule');
          return;
        } else {
          print('[NotificationService] No pending notifications found, rescheduling...');
          shouldReschedule = true;
        }
      }
      
      if (shouldReschedule) {
        // Cancel any existing notifications first
        await cancelAllNotifications();
        
        // Actually reschedule notifications by getting current prayer times
        await _reschedulePrayerNotifications();
        
        // Reschedule Azkar reminders
        await AzkarReminderService().scheduleAzkarReminders();
        
        // Save the reschedule date
        await prefs.setString('lastNotificationRescheduleDate', today);
        
        print('[NotificationService] Successfully rescheduled notifications for $today');
      }
      
    } catch (e) {
      print('[NotificationService] Error during startup reschedule: $e');
    }
  }
  
  /// Force reschedule notifications (called from settings or when needed)
  Future<void> forceRescheduleNotifications() async {
    if (kIsWeb) return;
    
    print('[NotificationService] Force rescheduling notifications...');
    
    try {
      // Cancel any existing notifications first
      await cancelAllNotifications();
      
      // Actually reschedule notifications by getting current prayer times
      await _reschedulePrayerNotifications();
      
      // Reschedule Azkar reminders
      await AzkarReminderService().scheduleAzkarReminders();
      
      // Save the reschedule date
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('lastNotificationRescheduleDate', today);
      
      print('[NotificationService] Successfully force rescheduled notifications');
      
    } catch (e) {
      print('[NotificationService] Error during force reschedule: $e');
    }
  }
  
  /// Reschedule prayer notifications based on current location and settings
  Future<void> _reschedulePrayerNotifications() async {
    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        print('[NotificationService] Could not get location for rescheduling');
        return;
      }
      
      final l10n = await _getLocalizations();
      final now = DateTime.now();
      
      // Schedule notifications for the next 30 days
      const daysToSchedule = 30;
      
      for (int dayOffset = 0; dayOffset < daysToSchedule; dayOffset++) {
        final targetDate = now.add(Duration(days: dayOffset));
        
        // Get prayer times for the target date
        final prayerTimes = await _getPrayerTimesForDate(position, targetDate);
        if (prayerTimes == null) {
          print('[NotificationService] Could not get prayer times for ${targetDate.toIso8601String()}');
          continue;
        }
        
        const ids = {
          Prayer.fajr: 0,
          Prayer.dhuhr: 1,
          Prayer.asr: 2,
          Prayer.maghrib: 3,
          Prayer.isha: 4,
        };

        final times = {
          Prayer.fajr: prayerTimes.fajr,
          Prayer.dhuhr: prayerTimes.dhuhr,
          Prayer.asr: prayerTimes.asr,
          Prayer.maghrib: prayerTimes.maghrib,
          Prayer.isha: prayerTimes.isha,
        };

        for (final e in times.entries) {
          final t = e.value?.toLocal();
          if (t != null && t.isAfter(now)) {
            final prayerName = e.key.name.toUpperCase();
            // Use unique ID for each day to avoid conflicts
            final uniqueId = ids[e.key]! + (dayOffset * 10);
            
            await scheduleNotification(
              id: uniqueId,
              title: l10n.prayerTimeTitle,
              body: l10n.prayerNotificationBody(prayerName, 'Current Location'),
              scheduledDate: t,
              repeatDaily: false, // Don't repeat since we're scheduling multiple days
              prayerName: prayerName,
            );
            print('[NotificationService] Scheduled ${prayerName} notification for ${t.toString()} (day ${dayOffset + 1})');
          }
        }
      }
      
    } catch (e) {
      print('[NotificationService] Error rescheduling prayer notifications: $e');
    }
  }
  
  /// Get prayer times for a specific date
  Future<PrayerTimes?> _getPrayerTimesForDate(Position position, DateTime date) async {
    try {
      // Load prayer settings
      final prefs = await SharedPreferences.getInstance();
      final calculationMethodStr = prefs.getString('calculationMethod') ?? 'moon_sighting_committee';
      final madhabStr = prefs.getString('madhab') ?? 'shafi';
      
      // Parse calculation method
      final calculationMethod = CalculationMethod.values.firstWhere(
        (m) => m.name == calculationMethodStr,
        orElse: () => CalculationMethod.moon_sighting_committee,
      );
      
      // Parse madhab
      final madhab = madhabStr == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
      
      // Get prayer parameters
      final params = calculationMethod.getParameters();
      params.madhab = madhab;
      
      // Add adjustments if any
      final fajrAdjustment = prefs.getInt('fajrAdjustment') ?? 0;
      final dhuhrAdjustment = prefs.getInt('dhuhrAdjustment') ?? 0;
      final asrAdjustment = prefs.getInt('asrAdjustment') ?? 0;
      final maghribAdjustment = prefs.getInt('maghribAdjustment') ?? 0;
      final ishaAdjustment = prefs.getInt('ishaAdjustment') ?? 0;
      
      if (fajrAdjustment != 0 || dhuhrAdjustment != 0 || asrAdjustment != 0 || 
          maghribAdjustment != 0 || ishaAdjustment != 0) {
        params.adjustments = PrayerAdjustments(
          fajr: fajrAdjustment,
          dhuhr: dhuhrAdjustment,
          asr: asrAdjustment,
          maghrib: maghribAdjustment,
          isha: ishaAdjustment,
        );
      }
      
      // Calculate prayer times for the specific date
      final coordinates = Coordinates(position.latitude, position.longitude);
      final dateComponents = DateComponents.from(date);
      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);
      
      return prayerTimes;
      
    } catch (e) {
      print('[NotificationService] Error getting prayer times for date ${date.toIso8601String()}: $e');
      return null;
    }
  }
  
  /// Get current location for rescheduling
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if we have location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('[NotificationService] Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('[NotificationService] Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[NotificationService] Location permissions are permanently denied');
        return null;
      }

      // Try to get last known position first (faster)
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        print('[NotificationService] Using last known position');
        return position;
      }

      // If no last known position, get current position
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      print('[NotificationService] Got current position');
      return position;
    } catch (e) {
      print('[NotificationService] Error getting location: $e');
      return null;
    }
  }
  
  /// Get localizations for notification text
  Future<dynamic> _getLocalizations() async {
    try {
      // For now, return a simple object with the required methods
      // This is a temporary solution until we can properly handle the localization
      return _SimpleLocalizations();
    } catch (e) {
      print('[NotificationService] Error getting localizations: $e');
      return _SimpleLocalizations();
    }
  }

  /// Check if notifications are working properly
  Future<bool> checkNotificationPermissions() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final androidPlugin = this.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.areNotificationsEnabled() ?? false;
        print('[NotificationService] Android notifications enabled: $granted');
        return granted;
      } else if (Platform.isIOS) {
        final iosPlugin = this.flutterLocalNotificationsPlugin
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

  /// Get notification status information
  Future<Map<String, dynamic>> getNotificationStatus() async {
    if (kIsWeb) {
      return {
        'enabled': false,
        'pendingCount': 0,
        'lastRescheduleDate': null,
        'permissionsGranted': false,
        'platform': 'web',
        'daysScheduled': 0,
      };
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('enableNotifications') ?? true;
      final lastRescheduleDate = prefs.getString('lastNotificationRescheduleDate');
      final pendingNotifications = await this.flutterLocalNotificationsPlugin.pendingNotificationRequests();
      final permissionsGranted = await checkNotificationPermissions();
      
      // Calculate how many days ahead notifications are scheduled
      final daysScheduled = await _getDaysScheduled(pendingNotifications);
      
      return {
        'enabled': notificationsEnabled,
        'pendingCount': pendingNotifications.length,
        'lastRescheduleDate': lastRescheduleDate,
        'permissionsGranted': permissionsGranted,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'daysScheduled': daysScheduled,
        'pendingNotifications': pendingNotifications.map((n) => {
          'id': n.id,
          'title': n.title,
          'body': n.body,
        }).toList(),
      };
    } catch (e) {
      print('[NotificationService] Error getting notification status: $e');
      return {
        'enabled': false,
        'pendingCount': 0,
        'lastRescheduleDate': null,
        'permissionsGranted': false,
        'platform': 'unknown',
        'daysScheduled': 0,
        'error': e.toString(),
      };
    }
  }
  
  /// Calculate how many days ahead notifications are scheduled
  Future<int> _getDaysScheduled(List<PendingNotificationRequest> pendingNotifications) async {
    if (pendingNotifications.isEmpty) return 0;
    
    try {
      // Get the latest scheduled notification time
      DateTime? latestTime;
      
      for (final notification in pendingNotifications) {
        // For now, we'll estimate based on notification IDs
        // Prayer notifications: IDs 0-4 for today, 10-14 for tomorrow, etc.
        // Azkar reminders: IDs 1001-1002 for today, 1011-1012 for tomorrow, etc.
        
        if (notification.id < 1000) {
          // Prayer notification
          final dayOffset = (notification.id / 10).floor();
          final estimatedTime = DateTime.now().add(Duration(days: dayOffset));
          if (latestTime == null || estimatedTime.isAfter(latestTime)) {
            latestTime = estimatedTime;
          }
        } else if (notification.id >= 1000 && notification.id < 2000) {
          // Azkar reminder
          final dayOffset = ((notification.id - 1000) / 10).floor();
          final estimatedTime = DateTime.now().add(Duration(days: dayOffset));
          if (latestTime == null || estimatedTime.isAfter(latestTime)) {
            latestTime = estimatedTime;
          }
        }
      }
      
      if (latestTime != null) {
        final daysDiff = latestTime.difference(DateTime.now()).inDays;
        return daysDiff > 0 ? daysDiff : 0;
      }
      
      return 0;
    } catch (e) {
      print('[NotificationService] Error calculating days scheduled: $e');
      return 0;
    }
  }
}

/// Simple localizations class for notification text
class _SimpleLocalizations {
  String get prayerTimeTitle => 'Prayer Time';
  String prayerNotificationBody(String prayerName, String location) => 'It is time for $prayerName prayer in $location';
}