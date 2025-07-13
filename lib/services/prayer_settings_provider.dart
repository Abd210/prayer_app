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
    // Validate coordinates before setting
    if (latitude < -90 || latitude > 90) {
      print('[PrayerSettingsProvider] Invalid latitude: $latitude');
      return;
    }
    if (longitude < -180 || longitude > 180) {
      print('[PrayerSettingsProvider] Invalid longitude: $longitude');
      return;
    }
    
    _manualLatitude = latitude;
    _manualLongitude = longitude;
    _saveAndNotify();
    
    print('[PrayerSettingsProvider] Manual location set: $latitude, $longitude');
  }
  
  void toggleFrequentLocationUpdates(bool value) {
    _frequentLocationUpdates = value;
    _saveAndNotify();
    
    print('[PrayerSettingsProvider] Frequent location updates: ${value ? 'enabled' : 'disabled'}');
  }
  
  /// Get current location status
  Map<String, dynamic> getLocationStatus() {
    return {
      'useManualLocation': _useManualLocation,
      'manualLatitude': _manualLatitude,
      'manualLongitude': _manualLongitude,
      'useElevation': _useElevation,
      'manualElevation': _manualElevation,
      'frequentLocationUpdates': _frequentLocationUpdates,
      'hasValidManualLocation': _useManualLocation && 
        _manualLatitude >= -90 && _manualLatitude <= 90 && 
        _manualLongitude >= -180 && _manualLongitude <= 180 &&
        (_manualLatitude != 0.0 || _manualLongitude != 0.0),
    };
  }
  
  /// Validate and fix manual location settings
  bool validateManualLocation() {
    if (!_useManualLocation) return true;
    
    bool isValid = _manualLatitude >= -90 && _manualLatitude <= 90 && 
                   _manualLongitude >= -180 && _manualLongitude <= 180 &&
                   (_manualLatitude != 0.0 || _manualLongitude != 0.0);
    
    if (!isValid) {
      print('[PrayerSettingsProvider] Invalid manual location detected, disabling...');
      _useManualLocation = false;
      _saveAndNotify();
    }
    
    return isValid;
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
      case 'united kingdom':
      case 'germany':
      case 'france':
      case 'italy':
      case 'spain':
      case 'netherlands':
      case 'belgium':
      case 'austria':
      case 'switzerland':
      case 'sweden':
      case 'norway':
      case 'denmark':
      case 'finland':
      case 'poland':
      case 'czech republic':
      case 'hungary':
      case 'romania':
      case 'bulgaria':
      case 'croatia':
      case 'slovenia':
      case 'slovakia':
      case 'lithuania':
      case 'latvia':
      case 'estonia':
      case 'ireland':
      case 'portugal':
      case 'greece':
      case 'cyprus':
      case 'malta':
      case 'luxembourg':
      case 'iceland':
      case 'albania':
      case 'north macedonia':
      case 'montenegro':
      case 'serbia':
      case 'bosnia and herzegovina':
      case 'kosovo':
      case 'moldova':
      case 'ukraine':
      case 'belarus':
      case 'russia':
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
      case 'australia':
      case 'new zealand':
      case 'fiji':
      case 'papua new guinea':
      case 'new caledonia':
      case 'vanuatu':
      case 'solomon islands':
      case 'tonga':
      case 'samoa':
      case 'kiribati':
      case 'tuvalu':
      case 'nauru':
      case 'palau':
      case 'marshall islands':
      case 'micronesia':
      case 'cook islands':
      case 'niue':
      case 'tokelau':
      case 'american samoa':
      case 'guam':
      case 'northern mariana islands':
      case 'french polynesia':
      case 'wallis and futuna':
      case 'pitcairn islands':
        return CalculationMethod.muslim_world_league;
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
          
        // Europe - Muslim World League method is commonly used
        case 'GB': // United Kingdom
        case 'DE': // Germany
        case 'FR': // France
        case 'IT': // Italy
        case 'ES': // Spain
        case 'NL': // Netherlands
        case 'BE': // Belgium
        case 'AT': // Austria
        case 'CH': // Switzerland
        case 'SE': // Sweden
        case 'NO': // Norway
        case 'DK': // Denmark
        case 'FI': // Finland
        case 'PL': // Poland
        case 'CZ': // Czech Republic
        case 'HU': // Hungary
        case 'RO': // Romania
        case 'BG': // Bulgaria
        case 'HR': // Croatia
        case 'SI': // Slovenia
        case 'SK': // Slovakia
        case 'LT': // Lithuania
        case 'LV': // Latvia
        case 'EE': // Estonia
        case 'IE': // Ireland
        case 'PT': // Portugal
        case 'GR': // Greece
        case 'CY': // Cyprus
        case 'MT': // Malta
        case 'LU': // Luxembourg
        case 'IS': // Iceland
        case 'AL': // Albania
        case 'MK': // North Macedonia
        case 'ME': // Montenegro
        case 'RS': // Serbia
        case 'BA': // Bosnia and Herzegovina
        case 'XK': // Kosovo
        case 'MD': // Moldova
        case 'UA': // Ukraine
        case 'BY': // Belarus
        case 'RU': // Russia (European part)
          _calculationMethod = CalculationMethod.muslim_world_league;
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
          
        // Africa - Muslim World League method is commonly used
        case 'MA': // Morocco
        case 'DZ': // Algeria
        case 'TN': // Tunisia
        case 'LY': // Libya
        case 'SD': // Sudan
        case 'SO': // Somalia
        case 'DJ': // Djibouti
        case 'ET': // Ethiopia
        case 'ER': // Eritrea
        case 'KE': // Kenya
        case 'TZ': // Tanzania
        case 'UG': // Uganda
        case 'RW': // Rwanda
        case 'BI': // Burundi
        case 'MG': // Madagascar
        case 'MU': // Mauritius
        case 'SC': // Seychelles
        case 'KM': // Comoros
        case 'YT': // Mayotte
        case 'RE': // Réunion
        case 'ZA': // South Africa
        case 'BW': // Botswana
        case 'NA': // Namibia
        case 'ZW': // Zimbabwe
        case 'ZM': // Zambia
        case 'MW': // Malawi
        case 'MZ': // Mozambique
        case 'SZ': // Eswatini
        case 'LS': // Lesotho
        case 'SS': // South Sudan
        case 'CF': // Central African Republic
        case 'TD': // Chad
        case 'CM': // Cameroon
        case 'GQ': // Equatorial Guinea
        case 'GA': // Gabon
        case 'CG': // Republic of the Congo
        case 'CD': // Democratic Republic of the Congo
        case 'AO': // Angola
        case 'ST': // São Tomé and Príncipe
        case 'GW': // Guinea-Bissau
        case 'GN': // Guinea
        case 'SL': // Sierra Leone
        case 'LR': // Liberia
        case 'CI': // Ivory Coast
        case 'GH': // Ghana
        case 'TG': // Togo
        case 'BJ': // Benin
        case 'NG': // Nigeria
        case 'NE': // Niger
        case 'BF': // Burkina Faso
        case 'ML': // Mali
        case 'SN': // Senegal
        case 'GM': // Gambia
        case 'CV': // Cape Verde
        case 'MR': // Mauritania
        case 'EH': // Western Sahara
          _calculationMethod = CalculationMethod.muslim_world_league;
          return;
          
        // Oceania - Muslim World League method is commonly used
        case 'AU': // Australia
        case 'NZ': // New Zealand
        case 'FJ': // Fiji
        case 'PG': // Papua New Guinea
        case 'NC': // New Caledonia
        case 'VU': // Vanuatu
        case 'SB': // Solomon Islands
        case 'TO': // Tonga
        case 'WS': // Samoa
        case 'KI': // Kiribati
        case 'TV': // Tuvalu
        case 'NR': // Nauru
        case 'PW': // Palau
        case 'MH': // Marshall Islands
        case 'FM': // Micronesia
        case 'CK': // Cook Islands
        case 'NU': // Niue
        case 'TK': // Tokelau
        case 'AS': // American Samoa
        case 'GU': // Guam
        case 'MP': // Northern Mariana Islands
        case 'PF': // French Polynesia
        case 'WF': // Wallis and Futuna
        case 'PN': // Pitcairn Islands
          _calculationMethod = CalculationMethod.muslim_world_league;
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

  /// Automatically detect and set calculation method based on user's current location
  /// This method can be called periodically or when location changes
  Future<bool> autoDetectCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final autoDetectionEnabled = prefs.getBool('autoDetectCalculationMethod') ?? true;
    
    if (!autoDetectionEnabled) {
      return false; // User has disabled auto-detection
    }
    
    final oldMethod = _calculationMethod;
    await _setCalculationMethodByRegion();
    
    // Check if the method actually changed
    if (oldMethod != _calculationMethod) {
      await _saveToPrefs();
      notifyListeners();
      
      // Save that we auto-detected this method
      await prefs.setBool('calculationMethodAutoDetected', true);
      await prefs.setString('lastAutoDetectedMethod', _calculationMethod.name);
      
      print('[PrayerSettingsProvider] Auto-detected calculation method: ${_calculationMethod.name}');
      return true; // Method was changed
    }
    
    return false; // Method didn't change
  }
  
  /// Enable or disable automatic calculation method detection
  Future<void> setAutoDetectionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoDetectCalculationMethod', enabled);
    
    if (enabled) {
      // If enabling, try to auto-detect now
      await autoDetectCalculationMethod();
    }
  }
  
  /// Check if auto-detection is enabled
  Future<bool> isAutoDetectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoDetectCalculationMethod') ?? true;
  }
  
  /// Get the last auto-detected method name
  Future<String?> getLastAutoDetectedMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastAutoDetectedMethod');
  }
  
  /// Check if current method was auto-detected
  Future<bool> wasMethodAutoDetected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('calculationMethodAutoDetected') ?? false;
  }

  void _saveAndNotify() {
    _saveToPrefs();      // Save first to ensure settings are stored
    notifyListeners();   // Then notify consumers (PrayerTimesPage)
  }
}
