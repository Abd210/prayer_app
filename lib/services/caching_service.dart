import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

/// Enhanced CachingService with robust offline support and error handling
class CachingService {
  static final CachingService _instance = CachingService._internal();
  factory CachingService() => _instance;
  CachingService._internal();

  /// Storage keys for different types of cached data
  static const String _locationCacheKey = 'CACHED_LOCATION_DATA';
  static const String _locationTimestampKey = 'CACHED_LOCATION_TIMESTAMP';
  static const String _prayerTimesCacheKey = 'CACHED_PRAYER_TIMES';
  static const String _prayerTimesTimestampKey = 'CACHED_PRAYER_TIMES_TIMESTAMP';
  static const String _azkarCacheKey = 'CACHED_AZKAR_DATA';
  static const String _azkarTimestampKey = 'CACHED_AZKAR_TIMESTAMP';
  static const String _qiblaCacheKey = 'CACHED_QIBLA_DATA';
  static const String _qiblaTimestampKey = 'CACHED_QIBLA_TIMESTAMP';

  /// Default expiration times for different types of data
  static const int _locationExpirationHours = 24; // Location data expires after 24 hours
  static const int _prayerTimesExpirationHours = 24; // Prayer times expire after 24 hours
  static const int _azkarExpirationDays = 7; // Azkar data expires after 7 days
  static const int _qiblaExpirationDays = 30; // Qibla data expires after 30 days
  
  /// In-memory cache for frequently accessed data
  final Map<String, dynamic> _memoryCache = {};
  
  /// Flag to track network connectivity
  bool _isOffline = false;
  
  /// Gets the current offline status
  bool get isOffline => _isOffline;
  
  /// Set the offline status manually (e.g., based on connectivity check)
  set isOffline(bool value) {
    _isOffline = value;
    debugPrint('CachingService: Offline mode ${value ? 'enabled' : 'disabled'}');
  }

  /// Cache location data with expiration
  Future<bool> cacheLocationData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(data);
      
      // Store in SharedPreferences
      await prefs.setString(_locationCacheKey, jsonData);
      await prefs.setInt(_locationTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      // Also keep in memory cache
      _memoryCache[_locationCacheKey] = data;
      
      debugPrint('CachingService: Location data cached successfully');
      return true;
    } catch (e) {
      debugPrint('CachingService: Error caching location data - $e');
      return false;
    }
  }

  /// Retrieve cached location data if not expired
  Future<Map<String, dynamic>?> getLocationData({bool ignoreExpiration = false}) async {
    try {
      // First check memory cache
      if (_memoryCache.containsKey(_locationCacheKey)) {
        debugPrint('CachingService: Returning location data from memory cache');
        return _memoryCache[_locationCacheKey];
      }
      
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_locationTimestampKey);
      
      // If no timestamp, cache doesn't exist
      if (timestamp == null) {
        debugPrint('CachingService: No cached location data found');
        return null;
      }
      
      // Check if cache is expired
      final cacheDuration = DateTime.now().millisecondsSinceEpoch - timestamp;
      final isExpired = cacheDuration > _locationExpirationHours * 60 * 60 * 1000;
      
      // Return null if expired (unless we're in offline mode or explicitly ignoring expiration)
      if (isExpired && !_isOffline && !ignoreExpiration) {
        debugPrint('CachingService: Cached location data is expired');
        return null;
      }
      
      // Get the cached data
      final jsonData = prefs.getString(_locationCacheKey);
      if (jsonData == null || jsonData.isEmpty) {
        debugPrint('CachingService: No cached location data found');
        return null;
      }
      
      // Parse and store in memory cache
      final data = json.decode(jsonData) as Map<String, dynamic>;
      _memoryCache[_locationCacheKey] = data;
      
      debugPrint('CachingService: Retrieved cached location data');
      return data;
    } catch (e) {
      debugPrint('CachingService: Error retrieving cached location data - $e');
      return null;
    }
  }

  /// Cache prayer times data with expiration
  Future<bool> cachePrayerTimes(String date, Map<String, dynamic> prayerTimes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing cache or create new one
      Map<String, dynamic> cache = {};
      final existingCache = prefs.getString(_prayerTimesCacheKey);
      if (existingCache != null && existingCache.isNotEmpty) {
        cache = json.decode(existingCache) as Map<String, dynamic>;
      }
      
      // Add or update this date's prayer times
      cache[date] = prayerTimes;
      
      // Save back to preferences
      await prefs.setString(_prayerTimesCacheKey, json.encode(cache));
      await prefs.setInt(_prayerTimesTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      // Update memory cache
      _memoryCache[_prayerTimesCacheKey] = cache;
      
      debugPrint('CachingService: Prayer times cached for $date');
      return true;
    } catch (e) {
      debugPrint('CachingService: Error caching prayer times - $e');
      return false;
    }
  }

  /// Get cached prayer times for a specific date
  Future<Map<String, dynamic>?> getPrayerTimes(String date, {bool ignoreExpiration = false}) async {
    try {
      // First check memory cache
      if (_memoryCache.containsKey(_prayerTimesCacheKey)) {
        final cache = _memoryCache[_prayerTimesCacheKey] as Map<String, dynamic>;
        if (cache.containsKey(date)) {
          debugPrint('CachingService: Returning prayer times from memory cache for $date');
          return cache[date] as Map<String, dynamic>;
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_prayerTimesTimestampKey);
      
      // If no timestamp, cache doesn't exist
      if (timestamp == null) {
        debugPrint('CachingService: No cached prayer times found');
        return null;
      }
      
      // Check if cache is expired
      final cacheDuration = DateTime.now().millisecondsSinceEpoch - timestamp;
      final isExpired = cacheDuration > _prayerTimesExpirationHours * 60 * 60 * 1000;
      
      // Return null if expired (unless we're in offline mode or explicitly ignoring expiration)
      if (isExpired && !_isOffline && !ignoreExpiration) {
        debugPrint('CachingService: Cached prayer times are expired');
        return null;
      }
      
      // Get the cached data
      final jsonData = prefs.getString(_prayerTimesCacheKey);
      if (jsonData == null || jsonData.isEmpty) {
        debugPrint('CachingService: No cached prayer times found');
        return null;
      }
      
      // Parse and check for requested date
      final allDates = json.decode(jsonData) as Map<String, dynamic>;
      _memoryCache[_prayerTimesCacheKey] = allDates;
      
      if (!allDates.containsKey(date)) {
        debugPrint('CachingService: No cached prayer times for $date');
        return null;
      }
      
      debugPrint('CachingService: Retrieved cached prayer times for $date');
      return allDates[date] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('CachingService: Error retrieving cached prayer times - $e');
      return null;
    }
  }

  /// Cache azkar data (which changes rarely)
  Future<bool> cacheAzkarData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(data);
      
      await prefs.setString(_azkarCacheKey, jsonData);
      await prefs.setInt(_azkarTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      _memoryCache[_azkarCacheKey] = data;
      
      debugPrint('CachingService: Azkar data cached successfully');
      return true;
    } catch (e) {
      debugPrint('CachingService: Error caching azkar data - $e');
      return false;
    }
  }

  /// Get cached azkar data
  Future<Map<String, dynamic>?> getAzkarData({bool ignoreExpiration = false}) async {
    try {
      // First check memory cache
      if (_memoryCache.containsKey(_azkarCacheKey)) {
        debugPrint('CachingService: Returning azkar data from memory cache');
        return _memoryCache[_azkarCacheKey];
      }
      
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_azkarTimestampKey);
      
      // If no timestamp, cache doesn't exist
      if (timestamp == null) {
        debugPrint('CachingService: No cached azkar data found');
        return null;
      }
      
      // Check if cache is expired
      final cacheDuration = DateTime.now().millisecondsSinceEpoch - timestamp;
      final isExpired = cacheDuration > _azkarExpirationDays * 24 * 60 * 60 * 1000;
      
      // Return null if expired (unless we're in offline mode or explicitly ignoring expiration)
      if (isExpired && !_isOffline && !ignoreExpiration) {
        debugPrint('CachingService: Cached azkar data is expired');
        return null;
      }
      
      // Get the cached data
      final jsonData = prefs.getString(_azkarCacheKey);
      if (jsonData == null || jsonData.isEmpty) {
        debugPrint('CachingService: No cached azkar data found');
        return null;
      }
      
      // Parse and store in memory cache
      final data = json.decode(jsonData) as Map<String, dynamic>;
      _memoryCache[_azkarCacheKey] = data;
      
      debugPrint('CachingService: Retrieved cached azkar data');
      return data;
    } catch (e) {
      debugPrint('CachingService: Error retrieving cached azkar data - $e');
      return null;
    }
  }

  /// Check if the device is currently connected to the internet
  Future<bool> isConnectedToInternet() async {
    if (kIsWeb) {
      // For web, assume always connected (could improve with navigator.onLine)
      return true;
    }
    
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOffline = !(result.isNotEmpty && result[0].rawAddress.isNotEmpty);
      return !_isOffline;
    } on SocketException catch (_) {
      _isOffline = true;
      return false;
    }
  }

  /// Clear all cached data
  Future<bool> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all cache keys
      await prefs.remove(_locationCacheKey);
      await prefs.remove(_locationTimestampKey);
      await prefs.remove(_prayerTimesCacheKey);
      await prefs.remove(_prayerTimesTimestampKey);
      await prefs.remove(_azkarCacheKey);
      await prefs.remove(_azkarTimestampKey);
      await prefs.remove(_qiblaCacheKey);
      await prefs.remove(_qiblaTimestampKey);
      
      // Clear memory cache
      _memoryCache.clear();
      
      debugPrint('CachingService: All caches cleared successfully');
      return true;
    } catch (e) {
      debugPrint('CachingService: Error clearing caches - $e');
      return false;
    }
  }
  
  /// Clear specific cache by key
  Future<bool> clearCache(String cacheType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      switch (cacheType) {
        case 'location':
          await prefs.remove(_locationCacheKey);
          await prefs.remove(_locationTimestampKey);
          _memoryCache.remove(_locationCacheKey);
          break;
        case 'prayerTimes':
          await prefs.remove(_prayerTimesCacheKey);
          await prefs.remove(_prayerTimesTimestampKey);
          _memoryCache.remove(_prayerTimesCacheKey);
          break;
        case 'azkar':
          await prefs.remove(_azkarCacheKey);
          await prefs.remove(_azkarTimestampKey);
          _memoryCache.remove(_azkarCacheKey);
          break;
        case 'qibla':
          await prefs.remove(_qiblaCacheKey);
          await prefs.remove(_qiblaTimestampKey);
          _memoryCache.remove(_qiblaCacheKey);
          break;
        default:
          debugPrint('CachingService: Unknown cache type: $cacheType');
          return false;
      }
      
      debugPrint('CachingService: $cacheType cache cleared successfully');
      return true;
    } catch (e) {
      debugPrint('CachingService: Error clearing $cacheType cache - $e');
      return false;
    }
  }
  
  /// Get all cache statistics (sizes, timestamps)
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = <String, dynamic>{};
      
      // Location cache stats
      final locationData = prefs.getString(_locationCacheKey);
      final locationTimestamp = prefs.getInt(_locationTimestampKey);
      if (locationData != null && locationTimestamp != null) {
        stats['location'] = {
          'size': locationData.length,
          'timestamp': DateTime.fromMillisecondsSinceEpoch(locationTimestamp),
          'isExpired': DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(locationTimestamp)
          ).inHours > _locationExpirationHours,
        };
      }
      
      // Prayer times cache stats
      final prayerTimesData = prefs.getString(_prayerTimesCacheKey);
      final prayerTimesTimestamp = prefs.getInt(_prayerTimesTimestampKey);
      if (prayerTimesData != null && prayerTimesTimestamp != null) {
        stats['prayerTimes'] = {
          'size': prayerTimesData.length,
          'timestamp': DateTime.fromMillisecondsSinceEpoch(prayerTimesTimestamp),
          'isExpired': DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(prayerTimesTimestamp)
          ).inHours > _prayerTimesExpirationHours,
        };
      }
      
      // Azkar cache stats
      final azkarData = prefs.getString(_azkarCacheKey);
      final azkarTimestamp = prefs.getInt(_azkarTimestampKey);
      if (azkarData != null && azkarTimestamp != null) {
        stats['azkar'] = {
          'size': azkarData.length,
          'timestamp': DateTime.fromMillisecondsSinceEpoch(azkarTimestamp),
          'isExpired': DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(azkarTimestamp)
          ).inDays > _azkarExpirationDays,
        };
      }
      
      return stats;
    } catch (e) {
      debugPrint('CachingService: Error getting cache stats - $e');
      return {};
    }
  }
} 