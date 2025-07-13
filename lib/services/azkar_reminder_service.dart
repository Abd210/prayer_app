import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

import 'notification_service.dart';
import 'location_service.dart';

class AzkarReminderService {
  static final AzkarReminderService _instance = AzkarReminderService._internal();
  factory AzkarReminderService() => _instance;
  AzkarReminderService._internal();

  final NotificationService _notificationService = NotificationService();
  
  // Default reminder settings
  static const int _defaultDhuhrReminderMinutes = 60; // 1 hour before Dhuhr
  static const int _defaultMaghribReminderMinutes = 60; // 1 hour before Maghrib
  
  // Reminder settings
  bool _azkarRemindersEnabled = true;
  int _dhuhrReminderMinutes = _defaultDhuhrReminderMinutes;
  int _maghribReminderMinutes = _defaultMaghribReminderMinutes;
  
  // Getters
  bool get azkarRemindersEnabled => _azkarRemindersEnabled;
  int get dhuhrReminderMinutes => _dhuhrReminderMinutes;
  int get maghribReminderMinutes => _maghribReminderMinutes;

  /// Initialize the service and load settings
  Future<void> init() async {
    await _loadSettings();
  }

  /// Load reminder settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _azkarRemindersEnabled = prefs.getBool('azkarRemindersEnabled') ?? true;
    _dhuhrReminderMinutes = prefs.getInt('dhuhrReminderMinutes') ?? _defaultDhuhrReminderMinutes;
    _maghribReminderMinutes = prefs.getInt('maghribReminderMinutes') ?? _defaultMaghribReminderMinutes;
    
    print('[AzkarReminderService] Settings loaded - Enabled: $_azkarRemindersEnabled, Dhuhr: ${_dhuhrReminderMinutes}min, Maghrib: ${_maghribReminderMinutes}min');
  }

  /// Save reminder settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('azkarRemindersEnabled', _azkarRemindersEnabled);
    await prefs.setInt('dhuhrReminderMinutes', _dhuhrReminderMinutes);
    await prefs.setInt('maghribReminderMinutes', _maghribReminderMinutes);
    
    print('[AzkarReminderService] Settings saved');
  }

  /// Enable or disable Azkar reminders
  Future<void> setAzkarRemindersEnabled(bool enabled) async {
    _azkarRemindersEnabled = enabled;
    await _saveSettings();
    
    if (enabled) {
      await scheduleAzkarReminders();
    } else {
      await cancelAzkarReminders();
    }
    
    print('[AzkarReminderService] Azkar reminders ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set Dhuhr reminder time (in minutes before prayer)
  Future<void> setDhuhrReminderMinutes(int minutes) async {
    if (minutes < 0 || minutes > 1440) { // Max 24 hours
      print('[AzkarReminderService] Invalid Dhuhr reminder minutes: $minutes');
      return;
    }
    
    _dhuhrReminderMinutes = minutes;
    await _saveSettings();
    
    if (_azkarRemindersEnabled) {
      await scheduleAzkarReminders();
    }
    
    print('[AzkarReminderService] Dhuhr reminder set to $minutes minutes before prayer');
  }

  /// Set Maghrib reminder time (in minutes before prayer)
  Future<void> setMaghribReminderMinutes(int minutes) async {
    if (minutes < 0 || minutes > 1440) { // Max 24 hours
      print('[AzkarReminderService] Invalid Maghrib reminder minutes: $minutes');
      return;
    }
    
    _maghribReminderMinutes = minutes;
    await _saveSettings();
    
    if (_azkarRemindersEnabled) {
      await scheduleAzkarReminders();
    }
    
    print('[AzkarReminderService] Maghrib reminder set to $minutes minutes before prayer');
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    _dhuhrReminderMinutes = _defaultDhuhrReminderMinutes;
    _maghribReminderMinutes = _defaultMaghribReminderMinutes;
    await _saveSettings();
    
    if (_azkarRemindersEnabled) {
      await scheduleAzkarReminders();
    }
    
    print('[AzkarReminderService] Reset to default settings');
  }

  /// Schedule Azkar reminders for today
  Future<void> scheduleAzkarReminders() async {
    if (kIsWeb || !_azkarRemindersEnabled) return;
    
    try {
      // Cancel existing reminders first
      await cancelAzkarReminders();
      
      // Get current location
      final position = await LocationService.determinePosition();
      if (position == null) {
        print('[AzkarReminderService] Could not get location for prayer times');
        return;
      }
      
      // Get prayer times for today
      final prayerTimes = await _getPrayerTimes(position);
      if (prayerTimes == null) {
        print('[AzkarReminderService] Could not get prayer times');
        return;
      }
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Schedule Dhuhr reminder
      if (prayerTimes.dhuhr != null) {
        final dhuhrReminderTime = prayerTimes.dhuhr!.subtract(Duration(minutes: _dhuhrReminderMinutes));
        if (dhuhrReminderTime.isAfter(now)) {
          await _scheduleReminder(
            id: 1001, // Unique ID for Dhuhr reminder
            title: 'Azkar Reminder',
            body: 'Time to recite morning azkar before Dhuhr prayer',
            scheduledTime: dhuhrReminderTime,
            prayerName: 'dhuhr_azkar',
          );
          print('[AzkarReminderService] Scheduled Dhuhr azkar reminder for ${dhuhrReminderTime.toString()}');
        }
      }
      
      // Schedule Maghrib reminder
      if (prayerTimes.maghrib != null) {
        final maghribReminderTime = prayerTimes.maghrib!.subtract(Duration(minutes: _maghribReminderMinutes));
        if (maghribReminderTime.isAfter(now)) {
          await _scheduleReminder(
            id: 1002, // Unique ID for Maghrib reminder
            title: 'Azkar Reminder',
            body: 'Time to recite evening azkar before Maghrib prayer',
            scheduledTime: maghribReminderTime,
            prayerName: 'maghrib_azkar',
          );
          print('[AzkarReminderService] Scheduled Maghrib azkar reminder for ${maghribReminderTime.toString()}');
        }
      }
      
    } catch (e) {
      print('[AzkarReminderService] Error scheduling reminders: $e');
    }
  }

  /// Get prayer times for current location
  Future<PrayerTimes?> _getPrayerTimes(Position position) async {
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
      
      // Calculate prayer times
      final coordinates = Coordinates(position.latitude, position.longitude);
      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);
      
      return prayerTimes;
      
    } catch (e) {
      print('[AzkarReminderService] Error getting prayer times: $e');
      return null;
    }
  }

  /// Schedule a single reminder
  Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String prayerName,
  }) async {
    if (kIsWeb) return;
    
    await _notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      repeatDaily: true,
      prayerName: prayerName,
    );
  }

  /// Cancel all Azkar reminders
  Future<void> cancelAzkarReminders() async {
    if (kIsWeb) return;
    
    try {
      // Cancel specific reminder IDs
      await _notificationService.flutterLocalNotificationsPlugin.cancel(1001); // Dhuhr reminder
      await _notificationService.flutterLocalNotificationsPlugin.cancel(1002); // Maghrib reminder
      
      print('[AzkarReminderService] Cancelled all Azkar reminders');
    } catch (e) {
      print('[AzkarReminderService] Error cancelling reminders: $e');
    }
  }

  /// Get reminder status
  Map<String, dynamic> getReminderStatus() {
    return {
      'enabled': _azkarRemindersEnabled,
      'dhuhrReminderMinutes': _dhuhrReminderMinutes,
      'maghribReminderMinutes': _maghribReminderMinutes,
      'dhuhrReminderTime': _formatReminderTime(_dhuhrReminderMinutes),
      'maghribReminderTime': _formatReminderTime(_maghribReminderMinutes),
    };
  }

  /// Format reminder time for display
  String _formatReminderTime(int minutes) {
    if (minutes == 0) return 'At prayer time';
    if (minutes == 60) return '1 hour before';
    if (minutes < 60) return '$minutes minutes before';
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes == 0) {
      return '$hours hours before';
    } else {
      return '$hours hours $remainingMinutes minutes before';
    }
  }

  /// Test reminder (for testing purposes)
  Future<void> testReminder() async {
    if (kIsWeb) return;
    
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    await _scheduleReminder(
      id: 9999,
      title: 'Test Azkar Reminder',
      body: 'This is a test azkar reminder',
      scheduledTime: testTime,
      prayerName: 'test_azkar',
    );
    
    print('[AzkarReminderService] Test reminder scheduled for ${testTime.toString()}');
  }
} 