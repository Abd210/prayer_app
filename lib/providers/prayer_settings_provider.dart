import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

class PrayerSettingsProvider extends ChangeNotifier {
  CalculationMethod _calculationMethod = CalculationMethod.karachi;
  Madhab _madhab = Madhab.hanafi;
  bool _use24hFormat = false;

  CalculationMethod get calculationMethod => _calculationMethod;
  Madhab get madhab => _madhab;
  bool get use24hFormat => _use24hFormat;

  void updateCalculationMethod(CalculationMethod method) {
    _calculationMethod = method;
    notifyListeners();
  }

  void updateMadhab(Madhab newMadhab) {
    _madhab = newMadhab;
    notifyListeners();
  }

  void toggle24hFormat(bool value) {
    _use24hFormat = value;
    notifyListeners();
  }
}
