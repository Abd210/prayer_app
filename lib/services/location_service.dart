import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown
}

class LocationError {
  final LocationErrorType type;
  final String message;
  
  LocationError(this.type, this.message);
  
  @override
  String toString() => message;
}

/// A simple Geolocator wrapper for obtaining location,
/// now with caching to avoid double-prompting or inconsistent states.
class LocationService {
  static Position? _cachedPosition;
  static bool _deniedForever = false;
  static DateTime? _lastUpdateTime;
  static const int _standardCacheTimeMs = 3600000; // 1 hour
  static const int _frequentCacheTimeMs = 300000;  // 5 minutes
  
  // Timeout for location requests
  static const int _locationTimeoutMs = 15000; // 15 seconds

  /// Gets current position or returns null if not possible.
  /// Returns a Future with either Position or LocationError
  static Future<Object> determinePositionWithError({
    bool frequentUpdates = false,
    int timeoutMs = _locationTimeoutMs,
  }) async {
    // If we already have a position, check if it needs to be refreshed
    if (_cachedPosition != null && _lastUpdateTime != null) {
      final currentTime = DateTime.now();
      final cacheTimeMs = frequentUpdates ? _frequentCacheTimeMs : _standardCacheTimeMs;
      if (currentTime.difference(_lastUpdateTime!).inMilliseconds < cacheTimeMs) {
        return _cachedPosition!;
      }
      // Otherwise, continue to get a new position
    }

    // If user already deniedForever, return error
    if (_deniedForever) {
      return LocationError(
        LocationErrorType.permissionDeniedForever,
        'Location permission has been permanently denied. Please enable it in app settings.'
      );
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationError(
          LocationErrorType.serviceDisabled,
          'Location services are disabled. Please enable location services.'
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationError(
            LocationErrorType.permissionDenied,
            'Location permissions are denied. Please grant location permission.'
          );
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _deniedForever = true;
        return LocationError(
          LocationErrorType.permissionDeniedForever,
          'Location permissions are permanently denied. Please enable in app settings.'
        );
      }

      // Add timeout to the position request
      final positionCompleter = Completer<Position>();
      final positionFuture = Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Set up the position request with timeout
      positionFuture.then(positionCompleter.complete).catchError(positionCompleter.completeError);
      
      // Set up a timer to handle timeout
      final timer = Timer(Duration(milliseconds: timeoutMs), () {
        if (!positionCompleter.isCompleted) {
          positionCompleter.completeError(TimeoutException(
            'Location request timed out. Using last known position.'
          ));
        }
      });
      
      try {
        final pos = await positionCompleter.future;
        timer.cancel();
        
        _cachedPosition = pos; // Cache the location
        _lastUpdateTime = DateTime.now();
        
        // Save elevation data
        await _saveElevationData(pos.altitude);
        
        return pos;
      } on TimeoutException {
        timer.cancel();
        
        // Try to get last known position as fallback
        try {
          final lastKnownPosition = await Geolocator.getLastKnownPosition();
          if (lastKnownPosition != null) {
            _cachedPosition = lastKnownPosition;
            _lastUpdateTime = DateTime.now();
            return lastKnownPosition;
          }
        } catch (_) {
          // If this also fails, continue to fallback for manual location
        }
        
        // Fall back to saved manual location if available
        final manualPosition = await getManualLocationIfEnabled();
        if (manualPosition != null) {
          return manualPosition;
        }
        
        return LocationError(
          LocationErrorType.timeout,
          'Location request timed out and no fallback position available.'
        );
      }
    } catch (e) {
      return LocationError(
        LocationErrorType.unknown,
        'Error getting location: $e'
      );
    }
  }
  
  /// Gets current position or returns null if not possible (original method)
  static Future<Position?> determinePosition({bool frequentUpdates = false}) async {
    final result = await determinePositionWithError(frequentUpdates: frequentUpdates);
    if (result is Position) {
      return result;
    }
    return null;
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
      final result = await determinePositionWithError();
      if (result is Position) {
        final position = result;
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final country = placemarks.first.country;
          final isoCountryCode = placemarks.first.isoCountryCode;
          
          if (country != null && country.isNotEmpty) {
            await _saveUserCountry(country, isoCountryCode);
            return country;
          }
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
  
  /// Get manual location if set
  static Future<Position?> getManualLocationIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final useManual = prefs.getBool('useManualLocation') ?? false;
    
    if (useManual) {
      final lat = prefs.getDouble('manualLatitude') ?? 0.0;
      final lng = prefs.getDouble('manualLongitude') ?? 0.0;
      
      if (lat != 0.0 || lng != 0.0) {
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
      }
    }
    
    return null;
  }
  
  /// Save current location as manual location
  static Future<void> saveCurrentLocationAsManual() async {
    final result = await determinePositionWithError();
    if (result is Position) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('manualLatitude', result.latitude);
      await prefs.setDouble('manualLongitude', result.longitude);
      await prefs.setDouble('manualElevation', result.altitude);
      await prefs.setBool('useManualLocation', true);
    }
  }
}
