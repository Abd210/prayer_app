// import 'package:adhan/adhan.dart';
// import 'package:intl/intl.dart';
// import 'package:geolocator/geolocator.dart';

// class PrayerTimeService {
//   static Map<String, String>? calculatePrayerTimes(Position position) {
//     try {
//       final coordinates = Coordinates(position.latitude, position.longitude);
//       final params = CalculationMethod.muslim_world_league.getParameters();
//       params.madhab = Madhab.shafi;
//       final prayerTimes = PrayerTimes.today(coordinates, params);
//       final formatter = DateFormat('HH:mm');
//       return {
//         'Fajr': formatter.format(prayerTimes.fajr),
//         'Sunrise': formatter.format(prayerTimes.sunrise),
//         'Dhuhr': formatter.format(prayerTimes.dhuhr),
//         'Asr': formatter.format(prayerTimes.asr),
//         'Maghrib': formatter.format(prayerTimes.maghrib),
//         'Isha': formatter.format(prayerTimes.isha),
//       };
//     } catch (e) {
//       return null;
//     }
//   }

//   static Map<String, String>? getNextPrayerTime(Map<String, String>? prayerTimes) {
//     if (prayerTimes == null) return null;
//     final now = DateTime.now();
//     final format = DateFormat('HH:mm');
//     final timesMap = <String, DateTime>{};
//     prayerTimes.forEach((name, timeStr) {
//       final parsedTime = format.parse(timeStr);
//       final dt = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
//       timesMap[name] = dt;
//     });
//     final upcoming = timesMap.entries.where((e) => e.value.isAfter(now)).toList()
//       ..sort((a, b) => a.value.compareTo(b.value));
//     if (upcoming.isNotEmpty) {
//       final next = upcoming.first;
//       return {'name': next.key, 'time': format.format(next.value)};
//     } else {
//       return {
//         'name': 'Fajr (Tomorrow)',
//         'time': prayerTimes['Fajr'] ?? 'N/A',
//       };
//     }
//   }
// }
