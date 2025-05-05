import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class AzkarReminder {
  final String id;
  final String azkarId;
  final String title;
  final TimeOfDay time;
  final List<int> days; // 0 = Sunday, 1 = Monday, etc.
  final bool isEnabled;

  AzkarReminder({
    required this.id,
    required this.azkarId,
    required this.title,
    required this.time,
    required this.days,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'azkarId': azkarId,
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'days': days,
      'isEnabled': isEnabled,
    };
  }

  factory AzkarReminder.fromJson(Map<String, dynamic> json) {
    return AzkarReminder(
      id: json['id'],
      azkarId: json['azkarId'],
      title: json['title'],
      time: TimeOfDay(
        hour: json['hour'],
        minute: json['minute'],
      ),
      days: List<int>.from(json['days']),
      isEnabled: json['isEnabled'] ?? true,
    );
  }
}

class AzkarReminderService {
  static const String _remindersKey = 'azkar_reminders';
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Initialize the service
  static Future<void> init() async {
    if (_initialized) return;
    
    // Initialize timezone
    tz_data.initializeTimeZones();
    
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(initSettings);
    _initialized = true;
    
    // Schedule all saved reminders
    await _scheduleAllReminders();
  }

  // Get all reminders
  static Future<List<AzkarReminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getString(_remindersKey);
    
    if (remindersJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(remindersJson);
      return jsonList.map((json) => AzkarReminder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading azkar reminders: $e');
      return [];
    }
  }

  // Save reminders
  static Future<bool> saveReminders(List<AzkarReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reminders.map((reminder) => reminder.toJson()).toList();
    return await prefs.setString(_remindersKey, jsonEncode(jsonList));
  }

  // Add a new reminder
  static Future<bool> addReminder(AzkarReminder reminder) async {
    final reminders = await getReminders();
    
    // Check if reminder with same ID already exists
    final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);
    if (existingIndex >= 0) {
      reminders[existingIndex] = reminder;
    } else {
      reminders.add(reminder);
    }
    
    final result = await saveReminders(reminders);
    if (result) {
      await _scheduleReminder(reminder);
    }
    return result;
  }

  // Update a reminder
  static Future<bool> updateReminder(AzkarReminder reminder) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    
    if (index < 0) return false;
    
    reminders[index] = reminder;
    final result = await saveReminders(reminders);
    
    // Cancel the old notification and schedule the new one
    if (result) {
      await _cancelReminder(reminder.id);
      if (reminder.isEnabled) {
        await _scheduleReminder(reminder);
      }
    }
    
    return result;
  }

  // Remove a reminder
  static Future<bool> removeReminder(String id) async {
    final reminders = await getReminders();
    final initialLength = reminders.length;
    
    reminders.removeWhere((reminder) => reminder.id == id);
    
    if (reminders.length == initialLength) {
      return false; // Nothing was removed
    }
    
    await _cancelReminder(id);
    return await saveReminders(reminders);
  }

  // Enable/disable a reminder
  static Future<bool> toggleReminder(String id, bool isEnabled) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((r) => r.id == id);
    
    if (index < 0) return false;
    
    reminders[index] = AzkarReminder(
      id: reminders[index].id,
      azkarId: reminders[index].azkarId,
      title: reminders[index].title,
      time: reminders[index].time,
      days: reminders[index].days,
      isEnabled: isEnabled,
    );
    
    final result = await saveReminders(reminders);
    
    if (result) {
      if (isEnabled) {
        await _scheduleReminder(reminders[index]);
      } else {
        await _cancelReminder(id);
      }
    }
    
    return result;
  }

  // Schedule a reminder notification
  static Future<void> _scheduleReminder(AzkarReminder reminder) async {
    if (!_initialized || kIsWeb) return;
    
    // Cancel any existing notification with this ID
    await _cancelReminder(reminder.id);
    
    if (!reminder.isEnabled) return;
    
    // Get a unique ID for each day
    for (final day in reminder.days) {
      final notificationId = int.parse('${reminder.id.hashCode}$day');
      
      final androidDetails = AndroidNotificationDetails(
        'azkar_reminders_channel',
        'Azkar Reminders',
        channelDescription: 'Reminders for azkar recitation',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      
      final iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );
      
      // Calculate the next occurrence for this day
      final nextOccurrence = _getNextOccurrence(reminder.time, day);
      
      if (nextOccurrence != null) {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          'Azkar Reminder',
          'Time for ${reminder.title}',
          nextOccurrence,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  // Calculate the next occurrence of a reminder
  static tz.TZDateTime? _getNextOccurrence(TimeOfDay time, int day) {
    final now = DateTime.now();
    
    // Create a DateTime object for the specified time today
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // Calculate days until the target day (0-6 where 0 is Sunday)
    final currentDay = now.weekday % 7; // Convert to 0-6 format where 0 is Sunday
    int daysUntilTarget = day - currentDay;
    
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7; // Wrap around to next week
    } else if (daysUntilTarget == 0 && scheduledTime.isBefore(now)) {
      daysUntilTarget = 7; // If today but time has passed, schedule for next week
    }
    
    // Add the appropriate number of days
    final nextOccurrence = scheduledTime.add(Duration(days: daysUntilTarget));
    
    // Convert to TZDateTime for the local timezone
    return tz.TZDateTime.from(nextOccurrence, tz.local);
  }

  // Cancel a reminder notification
  static Future<void> _cancelReminder(String id) async {
    if (!_initialized || kIsWeb) return;
    
    // Cancel for all 7 days of the week
    for (int day = 0; day < 7; day++) {
      final notificationId = int.parse('${id.hashCode}$day');
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  // Schedule all saved reminders
  static Future<void> _scheduleAllReminders() async {
    if (!_initialized || kIsWeb) return;
    
    final reminders = await getReminders();
    
    for (final reminder in reminders) {
      if (reminder.isEnabled) {
        await _scheduleReminder(reminder);
      }
    }
  }

  // Cancel all reminders
  static Future<void> cancelAllReminders() async {
    if (!_initialized || kIsWeb) return;
    
    await _notificationsPlugin.cancelAll();
  }
} 