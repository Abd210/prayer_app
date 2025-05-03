import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

class CachingService {
  static const String _prayerTimesPrefix = 'prayer_times_';
  static const String _lastLocationKey = 'last_location';
  static const String _quranDataPrefix = 'quran_data_';
  static const int _maxCacheAge = 86400000; // 24 hours in milliseconds
  
  /// Save prayer times for offline use
  static Future<void> cachePrayerTimes(DateTime date, PrayerTimes prayerTimes, String locationKey) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = _formatDateForKey(date);
    final key = '$_prayerTimesPrefix${locationKey}_$dateString';
    
    final prayerTimesMap = {
      'fajr': prayerTimes.fajr.millisecondsSinceEpoch,
      'sunrise': prayerTimes.sunrise.millisecondsSinceEpoch,
      'dhuhr': prayerTimes.dhuhr.millisecondsSinceEpoch,
      'asr': prayerTimes.asr.millisecondsSinceEpoch,
      'maghrib': prayerTimes.maghrib.millisecondsSinceEpoch,
      'isha': prayerTimes.isha.millisecondsSinceEpoch,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    await prefs.setString(key, jsonEncode(prayerTimesMap));
  }
  
  /// Get cached prayer times if available
  static Future<PrayerTimes?> getCachedPrayerTimes(DateTime date, String locationKey) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = _formatDateForKey(date);
    final key = '$_prayerTimesPrefix${locationKey}_$dateString';
    
    final cachedData = prefs.getString(key);
    if (cachedData == null) return null;
    
    try {
      final Map<String, dynamic> prayerTimesMap = jsonDecode(cachedData);
      
      // Check if cache is too old
      final timestamp = prayerTimesMap['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge > _maxCacheAge) return null;
      
      // Create PrayerTimes object from cached data
      final coordinates = await getLastKnownLocation();
      if (coordinates == null) return null;
      
      final params = CalculationParameters(
        madhab: Madhab.shafi,
        method: CalculationMethod.muslim_world_league,
      );
      
      // Create a custom prayer times object
      return PrayerTimes(
        coordinates,
        DateComponents.from(date),
        params,
        utcOffset: date.timeZoneOffset.inHours.toDouble(),
        customFajrTime: DateTime.fromMillisecondsSinceEpoch(prayerTimesMap['fajr'] as int),
        customSunriseTime: DateTime.fromMillisecondsSinceEpoch(prayerTimesMap['sunrise'] as int),
        customDhuhrTime: DateTime.fromMillisecondsSinceEpoch(prayerTimesMap['dhuhr'] as int),
        customAsrTime: DateTime.fromMillisecondsSinceEpoch(prayerTimesMap['asr'] as int),
        customMaghribTime: DateTime.fromMillisecondsSinceEpoch(prayerTimesMap['maghrib'] as int),
        customIshaTime: DateTime.fromMillisecondsSinceEpoch(prayerTimesMap['isha'] as int),
      );
    } catch (e) {
      print('Error getting cached prayer times: $e');
      return null;
    }
  }
  
  /// Save the last known location
  static Future<void> saveLastKnownLocation(Coordinates coordinates) async {
    final prefs = await SharedPreferences.getInstance();
    final locationMap = {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    await prefs.setString(_lastLocationKey, jsonEncode(locationMap));
  }
  
  /// Get the last known location
  static Future<Coordinates?> getLastKnownLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedLocation = prefs.getString(_lastLocationKey);
    
    if (cachedLocation == null) return null;
    
    try {
      final Map<String, dynamic> locationMap = jsonDecode(cachedLocation);
      return Coordinates(
        locationMap['latitude'] as double,
        locationMap['longitude'] as double,
      );
    } catch (e) {
      print('Error getting cached location: $e');
      return null;
    }
  }
  
  /// Cache Quran data
  static Future<void> cacheQuranData(String surahNumber, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_quranDataPrefix$surahNumber';
    
    await prefs.setString(key, data);
  }
  
  /// Get cached Quran data
  static Future<String?> getCachedQuranData(String surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_quranDataPrefix$surahNumber';
    
    return prefs.getString(key);
  }
  
  /// Helper to format date for cache key
  static String _formatDateForKey(DateTime date) {
    return '${date.year}_${date.month}_${date.day}';
  }
  
  /// Clear all cached data
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get all keys and filter ones that start with our prefixes
    final keys = prefs.getKeys();
    final cacheKeys = keys.where((key) => 
      key.startsWith(_prayerTimesPrefix) || 
      key.startsWith(_quranDataPrefix) ||
      key == _lastLocationKey
    );
    
    // Remove each cache key
    for (final key in cacheKeys) {
      await prefs.remove(key);
    }
  }
  
  /// Check if we have cached data for offline use
  static Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    return keys.any((key) => 
      key.startsWith(_prayerTimesPrefix) || 
      key == _lastLocationKey
    );
  }
} 