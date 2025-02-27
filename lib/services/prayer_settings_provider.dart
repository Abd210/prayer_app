import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds user-selected settings for Prayer calculations.
class PrayerSettingsProvider extends ChangeNotifier {
  CalculationMethod _calculationMethod = CalculationMethod.karachi;
  Madhab _madhab = Madhab.hanafi;
  bool _use24hFormat = false;

  // GETTERS
  CalculationMethod get calculationMethod => _calculationMethod;
  Madhab get madhab => _madhab;
  bool get use24hFormat => _use24hFormat;

  /// Constructor: on creation, load from SharedPreferences
  PrayerSettingsProvider() {
    _loadFromPrefs();
  }

  /// Load the saved preferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Read stored values (or defaults if not found):
    final methodString = prefs.getString('calculationMethod') ?? 'karachi';
    final madhabString = prefs.getString('madhab') ?? 'hanafi';
    final use24h = prefs.getBool('use24hFormat') ?? false;

    // Apply them:
    _calculationMethod = _stringToMethod(methodString);
    _madhab = (madhabString == 'shafi') ? Madhab.shafi : Madhab.hanafi;
    _use24hFormat = use24h;

    notifyListeners();
  }

  /// Save the current settings to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculationMethod', _calculationMethod.name);
    await prefs.setString('madhab', _madhab.name);
    await prefs.setBool('use24hFormat', _use24hFormat);
  }

  /// Convert the stored string to a CalculationMethod
  CalculationMethod _stringToMethod(String name) {
    switch (name) {
      case 'muslim_world_league':
        return CalculationMethod.muslim_world_league;
      case 'egyptian':
        return CalculationMethod.egyptian;
      case 'karachi':
        return CalculationMethod.karachi;
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura;
      case 'moon_sighting_committee':
        return CalculationMethod.moon_sighting_committee;
      case 'north_america':
        return CalculationMethod.north_america;
      case 'dubai':
        return CalculationMethod.dubai;
      case 'qatar':
        return CalculationMethod.qatar;
      case 'kuwait':
        return CalculationMethod.kuwait;
      case 'turkey':
        return CalculationMethod.turkey;
      case 'tehran':
        return CalculationMethod.tehran;
      case 'other':
        return CalculationMethod.other;
      default:
        return CalculationMethod.karachi; // fallback
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  UPDATE METHODS
  // ─────────────────────────────────────────────────────────────────────────────
  void updateCalculationMethod(CalculationMethod method) {
    _calculationMethod = method;
    notifyListeners();
    _saveToPrefs(); // <--- persist change
  }

  void updateMadhab(Madhab newMadhab) {
    _madhab = newMadhab;
    notifyListeners();
    _saveToPrefs(); // <--- persist change
  }

  void toggle24hFormat(bool value) {
    _use24hFormat = value;
    notifyListeners();
    _saveToPrefs(); // <--- persist change
  }
}
