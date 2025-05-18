import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer/services/caching_service.dart';

void main() {
  late CachingService cachingService;
  
  setUp(() {
    // Initialize with empty shared preferences
    SharedPreferences.setMockInitialValues({});
    cachingService = CachingService();
  });
  
  group('CachingService - Location data', () {
    test('should cache and retrieve location data', () async {
      // Arrange
      final locationData = {
        'latitude': 40.7128,
        'longitude': -74.0060,
        'city': 'New York',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Act
      final cacheSuccess = await cachingService.cacheLocationData(locationData);
      final retrievedData = await cachingService.getLocationData();
      
      // Assert
      expect(cacheSuccess, true);
      expect(retrievedData, isNotNull);
      expect(retrievedData!['latitude'], 40.7128);
      expect(retrievedData['longitude'], -74.0060);
      expect(retrievedData['city'], 'New York');
    });
    
    test('should return null when location data is expired', () async {
      // Arrange
      final locationData = {
        'latitude': 40.7128,
        'longitude': -74.0060,
        'timestamp': DateTime.now().subtract(const Duration(hours: 25)).millisecondsSinceEpoch,
      };
      
      // Set up mock shared preferences with expired data
      SharedPreferences.setMockInitialValues({
        'CACHED_LOCATION_DATA': '{"latitude":40.7128,"longitude":-74.0060,"timestamp":${locationData['timestamp']}}',
        'CACHED_LOCATION_TIMESTAMP': locationData['timestamp'],
      });
      
      // Act
      final retrievedData = await cachingService.getLocationData();
      final retrievedDataIgnoringExpiration = await cachingService.getLocationData(ignoreExpiration: true);
      
      // Assert
      expect(retrievedData, isNull); // Should be null because it's expired
      expect(retrievedDataIgnoringExpiration, isNotNull); // Should not be null when ignoring expiration
    });
    
    test('should return cached data in offline mode even if expired', () async {
      // Arrange
      final locationData = {
        'latitude': 40.7128,
        'longitude': -74.0060,
        'timestamp': DateTime.now().subtract(const Duration(hours: 25)).millisecondsSinceEpoch,
      };
      
      // Set up mock shared preferences with expired data
      SharedPreferences.setMockInitialValues({
        'CACHED_LOCATION_DATA': '{"latitude":40.7128,"longitude":-74.0060,"timestamp":${locationData['timestamp']}}',
        'CACHED_LOCATION_TIMESTAMP': locationData['timestamp'],
      });
      
      // Set offline mode
      cachingService.isOffline = true;
      
      // Act
      final retrievedData = await cachingService.getLocationData();
      
      // Assert
      expect(retrievedData, isNotNull); // Should not be null in offline mode
      expect(retrievedData!['latitude'], 40.7128);
    });
  });
  
  group('CachingService - Prayer times data', () {
    test('should cache and retrieve prayer times for a specific date', () async {
      // Arrange
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month}-${today.day}';
      final prayerTimesData = {
        'fajr': '05:30',
        'dhuhr': '12:30',
        'asr': '15:45',
        'maghrib': '18:15',
        'isha': '19:45',
      };
      
      // Act
      final cacheSuccess = await cachingService.cachePrayerTimes(dateString, prayerTimesData);
      final retrievedData = await cachingService.getPrayerTimes(dateString);
      
      // Assert
      expect(cacheSuccess, true);
      expect(retrievedData, isNotNull);
      expect(retrievedData!['fajr'], '05:30');
      expect(retrievedData['maghrib'], '18:15');
    });
    
    test('should handle multiple dates in prayer times cache', () async {
      // Arrange
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final todayString = '${today.year}-${today.month}-${today.day}';
      final tomorrowString = '${tomorrow.year}-${tomorrow.month}-${tomorrow.day}';
      
      final todayData = {
        'fajr': '05:30',
        'isha': '19:45',
      };
      
      final tomorrowData = {
        'fajr': '05:32',
        'isha': '19:43',
      };
      
      // Act
      await cachingService.cachePrayerTimes(todayString, todayData);
      await cachingService.cachePrayerTimes(tomorrowString, tomorrowData);
      
      final retrievedToday = await cachingService.getPrayerTimes(todayString);
      final retrievedTomorrow = await cachingService.getPrayerTimes(tomorrowString);
      
      // Assert
      expect(retrievedToday, isNotNull);
      expect(retrievedToday!['fajr'], '05:30');
      
      expect(retrievedTomorrow, isNotNull);
      expect(retrievedTomorrow!['fajr'], '05:32');
    });
  });
  
  group('CachingService - Cache management', () {
    test('should clear specific cache type', () async {
      // Arrange
      final locationData = {'latitude': 40.7128, 'longitude': -74.0060};
      final prayerTimesData = {'fajr': '05:30', 'isha': '19:45'};
      
      await cachingService.cacheLocationData(locationData);
      await cachingService.cachePrayerTimes('2023-05-15', prayerTimesData);
      
      // Act
      final clearSuccess = await cachingService.clearCache('location');
      
      // Assert
      expect(clearSuccess, true);
      
      // Location data should be null now
      final retrievedLocation = await cachingService.getLocationData();
      expect(retrievedLocation, isNull);
      
      // Prayer times should still be available
      final retrievedPrayerTimes = await cachingService.getPrayerTimes('2023-05-15');
      expect(retrievedPrayerTimes, isNotNull);
    });
    
    test('should clear all caches', () async {
      // Arrange
      final locationData = {'latitude': 40.7128, 'longitude': -74.0060};
      final prayerTimesData = {'fajr': '05:30', 'isha': '19:45'};
      
      await cachingService.cacheLocationData(locationData);
      await cachingService.cachePrayerTimes('2023-05-15', prayerTimesData);
      
      // Act
      final clearSuccess = await cachingService.clearAllCaches();
      
      // Assert
      expect(clearSuccess, true);
      
      // All data should be null now
      final retrievedLocation = await cachingService.getLocationData();
      final retrievedPrayerTimes = await cachingService.getPrayerTimes('2023-05-15');
      
      expect(retrievedLocation, isNull);
      expect(retrievedPrayerTimes, isNull);
    });
    
    test('should get cache stats', () async {
      // Arrange
      final locationData = {'latitude': 40.7128, 'longitude': -74.0060};
      await cachingService.cacheLocationData(locationData);
      
      // Act
      final stats = await cachingService.getCacheStats();
      
      // Assert
      expect(stats, isNotEmpty);
      expect(stats['location'], isNotNull);
      expect(stats['location']['isExpired'], false);
    });
  });
} 