import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_adjustments.dart';
import '../services/location_service.dart';

/// Holds user‑selected settings for prayer calculations.
class PrayerSettingsProvider extends ChangeNotifier {
  CalculationMethod _calculationMethod =
      CalculationMethod.moon_sighting_committee;
  Madhab _madhab = Madhab.shafi;
  bool _use24hFormat = false;
  
  // Add customizable prayer time adjustments
  int _fajrAdjustment = 0;
  int _dhuhrAdjustment = 0;
  int _asrAdjustment = 0;
  int _maghribAdjustment = 0;
  int _ishaAdjustment = 0;
  
  // Add elevation option
  bool _useElevation = false;
  double _manualElevation = 0.0;
  
  // Add manual location options
  bool _useManualLocation = false;
  double _manualLatitude = 0.0;
  double _manualLongitude = 0.0;
  
  // Add more frequent location updates option
  bool _frequentLocationUpdates = false;

  CalculationMethod get calculationMethod => _calculationMethod;
  Madhab get madhab => _madhab;
  bool get use24hFormat => _use24hFormat;
  
  // Getters for new properties
  int get fajrAdjustment => _fajrAdjustment;
  int get dhuhrAdjustment => _dhuhrAdjustment;
  int get asrAdjustment => _asrAdjustment;
  int get maghribAdjustment => _maghribAdjustment;
  int get ishaAdjustment => _ishaAdjustment;
  
  bool get useElevation => _useElevation;
  double get manualElevation => _manualElevation;
  
  bool get useManualLocation => _useManualLocation;
  double get manualLatitude => _manualLatitude;
  double get manualLongitude => _manualLongitude;
  
  bool get frequentLocationUpdates => _frequentLocationUpdates;
  
  // Return prayer adjustments as an object
  CustomPrayerAdjustments get prayerAdjustments => CustomPrayerAdjustments(
    fajr: _fajrAdjustment,
    dhuhr: _dhuhrAdjustment,
    asr: _asrAdjustment,
    maghrib: _maghribAdjustment,
    isha: _ishaAdjustment,
  );

  PrayerSettingsProvider() {
    _loadFromPrefs();
  }

  /* ──────────  Persistence  ────────── */

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if calculation method has been explicitly set before
    final savedMethod = prefs.getString('calculationMethod');
    if (savedMethod != null) {
      _calculationMethod = _stringToMethod(savedMethod);
    } else {
      // If no method has been explicitly set, determine based on country
      await _setCalculationMethodByRegion();
    }

    // Fix the madhab loading logic
    final madhabStr = prefs.getString('madhab') ?? 'shafi';
    _madhab = madhabStr == 'hanafi' ? Madhab.hanafi : Madhab.shafi;

    _use24hFormat = prefs.getBool('use24hFormat') ?? false;
    
    // Load adjustments
    _fajrAdjustment = prefs.getInt('fajrAdjustment') ?? 0;
    _dhuhrAdjustment = prefs.getInt('dhuhrAdjustment') ?? 0;
    _asrAdjustment = prefs.getInt('asrAdjustment') ?? 0;
    _maghribAdjustment = prefs.getInt('maghribAdjustment') ?? 0;
    _ishaAdjustment = prefs.getInt('ishaAdjustment') ?? 0;
    
    // Load elevation settings
    _useElevation = prefs.getBool('useElevation') ?? false;
    _manualElevation = prefs.getDouble('manualElevation') ?? 0.0;
    
    // Load manual location settings
    _useManualLocation = prefs.getBool('useManualLocation') ?? false;
    _manualLatitude = prefs.getDouble('manualLatitude') ?? 0.0;
    _manualLongitude = prefs.getDouble('manualLongitude') ?? 0.0;
    
    // Load frequent updates setting
    _frequentLocationUpdates = prefs.getBool('frequentLocationUpdates') ?? false;

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculationMethod', _calculationMethod.name);
    await prefs.setString('madhab', _madhab.name);
    await prefs.setBool('use24hFormat', _use24hFormat);
    
    // Save adjustments
    await prefs.setInt('fajrAdjustment', _fajrAdjustment);
    await prefs.setInt('dhuhrAdjustment', _dhuhrAdjustment);
    await prefs.setInt('asrAdjustment', _asrAdjustment);
    await prefs.setInt('maghribAdjustment', _maghribAdjustment);
    await prefs.setInt('ishaAdjustment', _ishaAdjustment);
    
    // Save elevation settings
    await prefs.setBool('useElevation', _useElevation);
    await prefs.setDouble('manualElevation', _manualElevation);
    
    // Save manual location settings
    await prefs.setBool('useManualLocation', _useManualLocation);
    await prefs.setDouble('manualLatitude', _manualLatitude);
    await prefs.setDouble('manualLongitude', _manualLongitude);
    
    // Save frequent updates setting
    await prefs.setBool('frequentLocationUpdates', _frequentLocationUpdates);
  }

  CalculationMethod _stringToMethod(String name) =>
      CalculationMethod.values.firstWhere(
        (m) => m.name == name,
        orElse: () => CalculationMethod.moon_sighting_committee,
      );

  /* ──────────  Mutators  ────────── */

  void updateCalculationMethod(CalculationMethod m) {
    _calculationMethod = m;
    _saveAndNotify();
  }

  void updateMadhab(Madhab m) {
    _madhab = m;
    _saveAndNotify();
  }

  void toggle24hFormat(bool v) {
    _use24hFormat = v;
    _saveAndNotify();
  }
  
  // Add methods for new settings
  void updatePrayerAdjustment(String prayer, int minutes) {
    switch (prayer) {
      case 'fajr':
        _fajrAdjustment = minutes;
        break;
      case 'dhuhr':
        _dhuhrAdjustment = minutes;
        break;
      case 'asr':
        _asrAdjustment = minutes;
        break;
      case 'maghrib':
        _maghribAdjustment = minutes;
        break;
      case 'isha':
        _ishaAdjustment = minutes;
        break;
    }
    _saveAndNotify();
  }
  
  void toggleUseElevation(bool value) {
    _useElevation = value;
    _saveAndNotify();
  }
  
  void setManualElevation(double value) {
    _manualElevation = value;
    _saveAndNotify();
  }
  
  void toggleUseManualLocation(bool value) {
    _useManualLocation = value;
    _saveAndNotify();
  }
  
  void setManualLocation(double latitude, double longitude) {
    _manualLatitude = latitude;
    _manualLongitude = longitude;
    _saveAndNotify();
  }
  
  void toggleFrequentLocationUpdates(bool value) {
    _frequentLocationUpdates = value;
    _saveAndNotify();
  }
  
  // Reset all prayer time adjustments to 0
  void resetAllAdjustments() {
    _fajrAdjustment = 0;
    _dhuhrAdjustment = 0;
    _asrAdjustment = 0;
    _maghribAdjustment = 0;
    _ishaAdjustment = 0;
    _saveAndNotify();
    
    print('[PrayerSettingsProvider] All prayer time adjustments reset to 0');
  }
  
  // Helper method to recommend calculation method based on region
  CalculationMethod getRecommendedMethodForRegion(String region) {
    switch (region.toLowerCase()) {
      case 'north america':
        return CalculationMethod.north_america;
      case 'europe':
        return CalculationMethod.muslim_world_league;
      case 'middle east':
        return CalculationMethod.dubai;
      case 'saudi arabia':
        return CalculationMethod.umm_al_qura;
      case 'egypt':
        return CalculationMethod.egyptian;
      case 'pakistan':
      case 'india':
      case 'bangladesh':
        return CalculationMethod.karachi;
      case 'turkey':
        return CalculationMethod.turkey;
      case 'singapore':
      case 'malaysia':
      case 'indonesia':
        return CalculationMethod.singapore;
      case 'iran':
        return CalculationMethod.tehran;
      default:
        return CalculationMethod.moon_sighting_committee;
    }
  }

  // Helper method to determine calculation method by region
  Future<void> _setCalculationMethodByRegion() async {
    final country = await LocationService.getUserCountry();
    final countryCode = await LocationService.getUserCountryCode();
    
    if (country == null && countryCode == null) {
      // Default to Moon Sighting Committee if we can't determine region
      _calculationMethod = CalculationMethod.moon_sighting_committee;
      return;
    }
    
    // Determine calculation method based on country or ISO code
    if (countryCode != null) {
      switch (countryCode.toUpperCase()) {
        // North America
        case 'US':
        case 'CA':
          _calculationMethod = CalculationMethod.north_america;
          return;
          
        // Middle East
        case 'SA':
          _calculationMethod = CalculationMethod.umm_al_qura;
          return;
        case 'AE':
          _calculationMethod = CalculationMethod.dubai;
          return;
        case 'QA':
          _calculationMethod = CalculationMethod.qatar;
          return;
        case 'KW':
          _calculationMethod = CalculationMethod.kuwait;
          return;
        case 'EG':
          _calculationMethod = CalculationMethod.egyptian;
          return;
        case 'IR':
          _calculationMethod = CalculationMethod.tehran;
          return;
        
        // Asia
        case 'PK':
        case 'IN':
        case 'BD':
        case 'AF':
          _calculationMethod = CalculationMethod.karachi;
          return;
        case 'SG':
        case 'MY':
        case 'ID':
          _calculationMethod = CalculationMethod.singapore;
          return;
        case 'TR':
          _calculationMethod = CalculationMethod.turkey;
          return;
      }
    }
    
    // If country code didn't match or isn't available, try with full country name
    if (country != null) {
      _calculationMethod = getRecommendedMethodForRegion(country);
    } else {
      // Default to Moon Sighting Committee
      _calculationMethod = CalculationMethod.moon_sighting_committee;
    }
  }

  void _saveAndNotify() {
    _saveToPrefs();      // Save first to ensure settings are stored
    notifyListeners();   // Then notify consumers (PrayerTimesPage)
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;
    
    if (isFirstTime) {
      await prefs.setBool('is_first_time', false);
    }
    
    return isFirstTime;
  }
}
