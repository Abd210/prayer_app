import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds user‑selected settings for prayer calculations.
class PrayerSettingsProvider extends ChangeNotifier {
  CalculationMethod _calculationMethod =
      CalculationMethod.moon_sighting_committee;
  Madhab _madhab = Madhab.shafi;
  bool _use24hFormat = false;

  CalculationMethod get calculationMethod => _calculationMethod;
  Madhab get madhab => _madhab;
  bool get use24hFormat => _use24hFormat;

  PrayerSettingsProvider() {
    _loadFromPrefs();
  }

  /* ──────────  Persistence  ────────── */

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _calculationMethod = _stringToMethod(
      prefs.getString('calculationMethod') ??
          CalculationMethod.moon_sighting_committee.name,
    );

    //  🔹 FIX — load correct madhab
    _madhab = (prefs.getString('madhab') ?? Madhab.hanafi.name) == 'shafi'
        ? Madhab.hanafi
        : Madhab.shafi;

    _use24hFormat = prefs.getBool('use24hFormat') ?? false;

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculationMethod', _calculationMethod.name);
    await prefs.setString('madhab', _madhab.name);
    await prefs.setBool('use24hFormat', _use24hFormat);
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

  void _saveAndNotify() {
    notifyListeners();   // consumers (PrayerTimesPage) react here
    _saveToPrefs();
  }
}
