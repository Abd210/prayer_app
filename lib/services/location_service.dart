import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

/// A comprehensive Geolocator wrapper for obtaining location,
/// with manual location support, caching, and frequent updates.
class LocationService {
  static Position? _cachedPosition;
  static bool _deniedForever = false;
  static DateTime? _lastUpdateTime;
  static const int _standardCacheTimeMs = 3600000; // 1 hour
  static const int _frequentCacheTimeMs = 300000;  // 5 minutes

  /// Gets current position or returns null if not possible.
  /// Caches the result so both QiblaPage & PrayerTimesPage
  /// see the same location data/permission status.
  static Future<Position?> determinePosition({bool frequentUpdates = false}) async {
    // First, check if manual location is enabled
    final manualPosition = await getManualLocationIfEnabled();
    if (manualPosition != null) {
      return manualPosition;
    }

    // If we already have a position, check if it needs to be refreshed
    if (_cachedPosition != null && _lastUpdateTime != null) {
      final currentTime = DateTime.now();
      final cacheTimeMs = frequentUpdates ? _frequentCacheTimeMs : _standardCacheTimeMs;
      if (currentTime.difference(_lastUpdateTime!).inMilliseconds < cacheTimeMs) {
        return _cachedPosition;
      }
      // Otherwise, continue to get a new position
    }

    // If user already deniedForever, short-circuit
    if (_deniedForever) {
      return null;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _deniedForever = true;
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Add timeout
      );
      _cachedPosition = pos; // Cache the location
      _lastUpdateTime = DateTime.now();
      
      // Save elevation data
      await _saveElevationData(pos.altitude);
      
      return pos;
    } catch (e) {
      print('[LocationService] Error getting position: $e');
      return null;
    }
  }
  
  /// Save elevation data from GPS
  static Future<void> _saveElevationData(double altitude) async {
    if (altitude != 0) { // Only save if we have valid data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_elevation', altitude);
    }
  }
  
  /// Get the last known elevation
  static Future<double> getLastElevation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('last_elevation') ?? 0.0;
  }

  /// Get the user's country for region-based calculation method
  static Future<String?> getUserCountry() async {
    try {
      final position = await determinePosition();
      if (position == null) return null;
      
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final country = placemarks.first.country;
        final isoCountryCode = placemarks.first.isoCountryCode;
        
        if (country != null && country.isNotEmpty) {
          await _saveUserCountry(country, isoCountryCode);
          return country;
        }
      }
      
      return _getLastKnownCountry();
    } catch (_) {
      return _getLastKnownCountry();
    }
  }
  
  /// Save user's country to preferences
  static Future<void> _saveUserCountry(String country, String? isoCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_country', country);
    if (isoCode != null && isoCode.isNotEmpty) {
      await prefs.setString('user_country_code', isoCode);
    }
  }
  
  /// Get last known country from preferences
  static Future<String?> _getLastKnownCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_country');
  }
  
  /// Get the user's country code (ISO)
  static Future<String?> getUserCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_country_code');
  }

  /// Optional helper if you want to force a new request next time
  static void resetCache() {
    _cachedPosition = null;
    _lastUpdateTime = null;
    _deniedForever = false;
  }
  
  /// Get manual location if set and enabled
  static Future<Position?> getManualLocationIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final useManual = prefs.getBool('useManualLocation') ?? false;
    
    if (useManual) {
      final lat = prefs.getDouble('manualLatitude') ?? 0.0;
      final lng = prefs.getDouble('manualLongitude') ?? 0.0;
      
      // Validate coordinates
      if (_isValidLatitude(lat) && _isValidLongitude(lng)) {
        return Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: prefs.getDouble('manualElevation') ?? 0.0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        print('[LocationService] Invalid manual coordinates: lat=$lat, lng=$lng');
        // Disable manual location if coordinates are invalid
        await prefs.setBool('useManualLocation', false);
        return null;
      }
    }
    
    return null;
  }
  
  /// Validate latitude coordinates
  static bool _isValidLatitude(double lat) {
    return lat >= -90 && lat <= 90 && lat != 0.0;
  }
  
  /// Validate longitude coordinates
  static bool _isValidLongitude(double lng) {
    return lng >= -180 && lng <= 180 && lng != 0.0;
  }
  
  /// Get location status information
  static Future<Map<String, dynamic>> getLocationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final useManual = prefs.getBool('useManualLocation') ?? false;
    final frequentUpdates = prefs.getBool('frequentLocationUpdates') ?? false;
    final useElevation = prefs.getBool('useElevation') ?? false;
    
    Map<String, dynamic> status = {
      'useManual': useManual,
      'frequentUpdates': frequentUpdates,
      'useElevation': useElevation,
      'hasValidManualLocation': false,
      'lastUpdateTime': _lastUpdateTime?.toIso8601String(),
      'cacheTime': frequentUpdates ? _frequentCacheTimeMs : _standardCacheTimeMs,
    };
    
    if (useManual) {
      final lat = prefs.getDouble('manualLatitude') ?? 0.0;
      final lng = prefs.getDouble('manualLongitude') ?? 0.0;
      status['hasValidManualLocation'] = _isValidLatitude(lat) && _isValidLongitude(lng);
      status['manualLatitude'] = lat;
      status['manualLongitude'] = lng;
      status['manualElevation'] = prefs.getDouble('manualElevation') ?? 0.0;
    }
    
    if (useElevation) {
      status['elevation'] = prefs.getDouble('manualElevation') ?? 0.0;
    }
    
    return status;
  }
  
  /// Force refresh location (ignores cache)
  static Future<Position?> forceRefreshLocation() async {
    _cachedPosition = null;
    _lastUpdateTime = null;
    return await determinePosition();
  }
  
  /// Check if location services are available
  static Future<bool> isLocationServiceAvailable() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }
  
  /// Get location permission status
  static Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }
  
  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }
}
