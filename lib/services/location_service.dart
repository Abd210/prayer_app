import 'package:geolocator/geolocator.dart';

/// A simple Geolocator wrapper for obtaining location,
/// now with caching to avoid double-prompting or inconsistent states.
class LocationService {
  static Position? _cachedPosition;
  static bool _deniedForever = false;

  /// Gets current position or returns null if not possible.
  /// Caches the result so both QiblaPage & PrayerTimesPage
  /// see the same location data/permission status.
  static Future<Position?> determinePosition() async {
    // If we already have a position, return it
    if (_cachedPosition != null) {
      return _cachedPosition;
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
      );
      _cachedPosition = pos; // Cache the location
      return pos;
    } catch (_) {
      return null;
    }
  }

  /// Optional helper if you want to force a new request next time
  static void resetCache() {
    _cachedPosition = null;
    _deniedForever = false;
  }
}
