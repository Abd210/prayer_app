import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A tiny helper that reads / writes Azkar progress & stats to `SharedPreferences`.
class AzkarStorage {
  static const _progressPrefix = 'azkarProgress_';   // + title
  static const _statsKey = 'azkarStats';             // JSON map

  static String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /* ───────────  IN‑PROGRESS SESSION  ─────────── */

  static Future<void> saveProgress({
    required String title,
    required int pageIndex,
    required List<int> counts,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'date': _today(),
      'page': pageIndex,
      'counts': counts,
    };
    await prefs.setString('$_progressPrefix$title', jsonEncode(data));
  }

  /// Returns `null` if nothing saved **for today**.
  static Future<(int page, List<int> counts)?> loadProgress(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_progressPrefix$title');
    if (raw == null) return null;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['date'] != _today()) return null;

    final page = decoded['page'] as int;
    final counts = List<int>.from(decoded['counts'] as List);
    return (page, counts);
  }

  static Future<void> clearProgress(String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_progressPrefix$title');
  }

  /* ───────────  DAILY STATS  ─────────── */

  /// Mark a category finished for **today**.
  static Future<void> markFinished(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> stats =
        jsonDecode(prefs.getString(_statsKey) ?? '{}');

    final day = _today();
    final Map<String, dynamic> forDay =
        (stats[day] ?? <String, dynamic>{}) as Map<String, dynamic>;
    forDay[title] = true;
    stats[day] = forDay;

    await prefs.setString(_statsKey, jsonEncode(stats));
  }

  /// Map<date, Map<title,bool>>
  static Future<Map<String, Map<String, bool>>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> raw =
        jsonDecode(prefs.getString(_statsKey) ?? '{}');
    return raw.map((k, v) =>
        MapEntry(k, (v as Map).map((k2, v2) => MapEntry(k2, v2 as bool))));
  }
}
