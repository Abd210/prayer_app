// lib/pages/prayer_times_page.dart
// ————————————————————————————————————————————————————————————————
// Full file: public state class + refreshPage() + localisation hooks
// ————————————————————————————————————————————————————————————————
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'statistics.dart';
import '../services/location_service.dart';
import '../services/prayer_settings_provider.dart';
import '../services/notification_service.dart';
import '../models/prayer_adjustments.dart';
import '../widgets/animated_wave_background.dart';
import '../widgets/prayer_times/prayer_time_card.dart';
import '../widgets/prayer_times/next_prayer_indicator.dart';
import '../widgets/prayer_times/location_display.dart';

/// ————————————————— Animated wave background —————————————————
class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;
  const AnimatedWaveBackground({super.key, required this.child});

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _WavePainter(
              value: _ctrl.value,
              color: Theme.of(context).colorScheme.primary.withOpacity(.15)),
          child: widget.child,
        ),
      );
}

class _WavePainter extends CustomPainter {
  final double value;
  final Color color;
  const _WavePainter({required this.value, required this.color});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color;
    _wave(c, s, p, 18, 1.0, 0);
    _wave(c, s, p, 24, 1.4, 40);
    _wave(c, s, p, 16, 2.0, 70);
  }

  void _wave(Canvas c, Size s, Paint p, double amp, double speed, double off) {
    final path = Path()..moveTo(0, s.height);
    for (double x = 0; x <= s.width; x++) {
      final y = amp *
              math.sin((x / s.width * 2 * math.pi * speed) +
                  (value * 2 * math.pi * speed)) +
          (s.height - 120 - off);
      path.lineTo(x, y);
    }
    path
      ..lineTo(s.width, s.height)
      ..close();
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => true;
}

/// ————————————————— Prayer Times Page —————————————————
class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});
  @override
  PrayerTimesPageState createState() => PrayerTimesPageState();
}

class PrayerTimesPageState extends State<PrayerTimesPage>
    with WidgetsBindingObserver {
  Position? _pos;
  String _city = '...';
  bool _permissionError = false;

  final _cachedTimes = <int, PrayerTimes?>{};
  final _cachedSunnah = <int, SunnahTimes?>{};
  static const _daysRange = 7;

  late final PageController _pager =
      PageController(initialPage: _pageCenterIndex);
  static const _pageCenterIndex = 7;
  int _currentIndex = _pageCenterIndex;

  Timer? _ticker;
  Duration _untilNext = Duration.zero;
  String _nextName = '-';
  double _progress = 0;

  // — tips (filled after first frame when l10n is available) ——–
  List<String> _tips = [];
  final _rand = math.Random();
  String get _randomTip =>
      _tips.isEmpty ? '...' : _tips[_rand.nextInt(_tips.length)];

  // — weekly cache keys
  static const _locKey = 'WEEKLY_LOCATION_DATA';
  static const _tsKey = 'WEEKLY_LOCATION_TIMESTAMP';
  static const _weekMs = 7 * 24 * 60 * 60 * 1000;

  // —————————————————— init / dispose
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tryLoadWeekly();
    _initLocation();
    _startTicker();

    Provider.of<PrayerSettingsProvider>(context, listen: false)
        .addListener(_onPrefsChanged);

    // build tips
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      _tips = [
        l.tipEstablishPrayer,
        l.tipBetterThanSleep,
        l.tipCallUponMe,
        l.tipReflectQuran,
        l.tipKhushu,
        l.tipSharePrayer,
        l.tipSunnah,
      ];
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<PrayerSettingsProvider>(context, listen: false)
        .removeListener(_onPrefsChanged);
    _ticker?.cancel();
    _pager.dispose();
    super.dispose();
  }

  /// ——— called by MainNavScreen via GlobalKey
  void refreshPage() => _initLocation();

  // —————————————————— lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _initLocation();
  }

  void _onPrefsChanged() {
    _cachedTimes.clear();
    _cachedSunnah.clear();
    _preload();
    _updateNext();
    // Re-schedule notifications so they match the current calculation settings
    _scheduleToday();
  }

  // —————————————————— weekly‑cache helpers
  Future<void> _tryLoadWeekly() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_tsKey) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - last > _weekMs) return;

    final raw = prefs.getString(_locKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final m = json.decode(raw) as Map<String, dynamic>;
      _pos = Position(
        latitude: m['lat'],
        longitude: m['lng'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(m['ts']),
        accuracy: m['acc'] ?? 0,
        altitude: m['alt'] ?? 0,
        heading: m['heading'] ?? 0,
        speed: m['speed'] ?? 0,
        speedAccuracy: m['speedAcc'] ?? 0,
        altitudeAccuracy: m['altAcc'] ?? 0,
        headingAccuracy: m['headingAcc'] ?? 0,
      );
      _city = m['city'];
      setState(() {});
      _preload();
    } catch (e) {
      print('Weekly cache deserialize: $e');
    }
  }

  Future<void> _saveLocationWeekly() async {
    if (_pos == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final m = <String, dynamic>{
        'lat': _pos!.latitude,
        'lng': _pos!.longitude,
        'ts': _pos!.timestamp?.millisecondsSinceEpoch ?? 0,
        'acc': _pos!.accuracy,
        'city': _city,
      };
      await prefs.setString(_locKey, json.encode(m));
      await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Weekly cache serialize: $e');
    }
  }

  // —————————————————— location
  Future<void> _initLocation() async {
    final loc = await LocationService.determinePosition();
    if (loc == null) {
      setState(() => _permissionError = true);
      return;
    }

    _pos = loc;
    _permissionError = false;
    if (!mounted) return;

    _preload();
    _updateNext();
    setState(() {});

    try {
      LocationService.getPlacemark(loc).then((place) {
        if (place != null && mounted) {
          setState(() => _city = place.locality ?? '?');
          _saveLocationWeekly();
        }
      });
    } catch (e) {
      print('Geocoding: $e');
    }
  }

  // —————————————————— prayer time helpers
  void _preload() {
    if (_pos == null) return;

    // Clear the cached times
    _cachedTimes.clear();
    _cachedSunnah.clear();

    // Get the calculation preferences
    final prefs = Provider.of<PrayerSettingsProvider>(context, listen: false);
    final custAdj = prefs.prayerAdjustments;

    // Create coordinates with or without elevation
    Coordinates coords;
    if (prefs.useElevation) {
      coords = Coordinates(
        _pos!.latitude, 
        _pos!.longitude,
        altitude: prefs.manualElevation
      );
    } else {
      coords = Coordinates(_pos!.latitude, _pos!.longitude);
    }

    // Get calculation method
    final calcParams = CalculationMethod.other.getParameters();
    calcParams.method = prefs.calculationMethod;
    calcParams.madhab = prefs.madhab;

    // Adjust for calculation method offsets
    if (calcParams.method == CalculationMethod.north_america) {
      // 15° for fajr, 15° for isha
      calcParams.fajrAngle = 15;
      calcParams.ishaAngle = 15;
    } else if (calcParams.method == CalculationMethod.muslim_world_league) {
      // 18° for fajr, 17° for isha
      calcParams.fajrAngle = 18;
      calcParams.ishaAngle = 17;
    }

    // Apply manual adjustments from preferences
    calcParams.adjustments = PrayerAdjustments(
      fajr: custAdj.fajr,
      sunrise: 0,
      dhuhr: custAdj.dhuhr,
      asr: custAdj.asr,
      maghrib: custAdj.maghrib,
      isha: custAdj.isha,
    );

    // Get prayer times for this date range
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _daysRange));
    final end = now.add(Duration(days: _daysRange));

    // Cache all days in range
    for (DateTime d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      final key = _dateToKey(d);
      final pt = PrayerTimes(
        coords, 
        DateComponents(d.year, d.month, d.day), 
        calcParams
      );
      final st = SunnahTimes(pt);
      _cachedTimes[key] = pt;
      _cachedSunnah[key] = st;
    }

    // Calculate for next prayer and time remaining
    _updateNext();
  }

  int _dateToKey(DateTime d) {
    // Convert a date to a simple integer key
    // Format: YYYYMMDD
    return d.year * 10000 + d.month * 100 + d.day;
  }

  DateTime _getDateTime(PrayerTimes pt, Prayer prayer) {
    // Convert from a PrayerTimes object to a DateTime
    final pTime = pt.timeForPrayer(prayer);
    if (pTime == null) return DateTime.now();
    
    final d = pt.date;
    return DateTime(d.year, d.month, d.day, pTime.hour, pTime.minute);
  }

  void _updateNext() {
    if (_pos == null) return;
    
    final now = DateTime.now();
    final todayKey = _dateToKey(now);
    final todayTimes = _cachedTimes[todayKey];
    
    if (todayTimes == null) {
      print('No cached times for today');
      return;
    }
    
    // Find next prayer
    final next = todayTimes.nextPrayer();
    if (next == null) {
      // If no next prayer today, get tomorrow's fajr
      final tmrKey = _dateToKey(now.add(const Duration(days: 1)));
      final tmrTimes = _cachedTimes[tmrKey];
      
      if (tmrTimes != null) {
        final tmrFajr = _getDateTime(tmrTimes, Prayer.fajr);
        _nextName = 'fajr';
        _untilNext = tmrFajr.difference(now);
      }
    } else {
      _nextName = next.name.toLowerCase();
      
      // Get DateTime for next prayer
      final nextTime = _getDateTime(todayTimes, next);
      _untilNext = nextTime.difference(now);
      
      // Calculate progress
      Prayer? prev;
      switch (next) {
        case Prayer.fajr:
          // Previous prayer was isha from yesterday
          final yday = now.subtract(const Duration(days: 1));
          final ydayKey = _dateToKey(yday);
          final ydayTimes = _cachedTimes[ydayKey];
          
          if (ydayTimes != null) {
            final ydayIsha = _getDateTime(ydayTimes, Prayer.isha);
            final totalDuration = nextTime.difference(ydayIsha);
            final elapsed = now.difference(ydayIsha);
            _progress = elapsed.inSeconds / totalDuration.inSeconds;
          }
          break;
          
        case Prayer.sunrise:
          prev = Prayer.fajr;
          break;
          
        case Prayer.dhuhr:
          prev = Prayer.sunrise;
          break;
          
        case Prayer.asr:
          prev = Prayer.dhuhr;
          break;
          
        case Prayer.maghrib:
          prev = Prayer.asr;
          break;
          
        case Prayer.isha:
          prev = Prayer.maghrib;
          break;
      }
      
      if (prev != null) {
        final prevTime = _getDateTime(todayTimes, prev);
        final totalDuration = nextTime.difference(prevTime);
        final elapsed = now.difference(prevTime);
        _progress = elapsed.inSeconds / totalDuration.inSeconds;
      }
      
      // Clamp progress to [0, 1] range
      _progress = _progress.clamp(0.0, 1.0);
    }
  }

  // —————————————————— schedule notification
  Future<void> _scheduleToday() async {
    final todayKey = _dateToKey(DateTime.now());
    final pt = _cachedTimes[todayKey];
    if (pt == null) return;
    
    final ns = NotificationService();
    await ns.cancelAllNotifications();
    
    final prayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];
    
    final l10n = AppLocalizations.of(context)!;
    
    for (final p in prayers) {
      final time = pt.timeForPrayer(p);
      if (time == null) continue;
      
      final d = pt.date;
      final dt = DateTime(d.year, d.month, d.day, time.hour, time.minute);
      
      // Only schedule notifications for future times
      if (dt.isAfter(DateTime.now())) {
        String prayerName;
        switch (p) {
          case Prayer.fajr:
            prayerName = l10n.fajr;
            break;
          case Prayer.dhuhr:
            prayerName = l10n.dhuhr;
            break;
          case Prayer.asr:
            prayerName = l10n.asr;
            break;
          case Prayer.maghrib:
            prayerName = l10n.maghrib;
            break;
          case Prayer.isha:
            prayerName = l10n.isha;
            break;
          default:
            prayerName = p.name;
        }
        
        await ns.scheduleNotification(
          id: p.index,
          title: l10n.timeForPrayer(prayerName),
          body: l10n.prayerTimeNotificationBody,
          scheduledDate: dt,
          prayerName: p.name,
        );
      }
    }
  }

  // —————————————————— ticker
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      
      // Decrement time until next prayer
      if (_untilNext.inSeconds > 0) {
        setState(() {
          _untilNext = _untilNext - const Duration(seconds: 1);
        });
      } else {
        _updateNext();
        _scheduleToday();
      }
    });
  }

  // —————————————————— page scroll function (unused in this snippet)
  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() => _currentIndex = index);
  }

  // —————————————————— BUILD METHOD
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final use24h = Provider.of<PrayerSettingsProvider>(context).use24hFormat;
    
    // If we have a permission error, show the permission UI
    if (_permissionError) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.prayerTimes)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.locationPermissionDenied,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initLocation,
                icon: const Icon(Icons.location_on),
                label: Text(l10n.allowLocationAccess),
              ),
            ],
          ),
        ),
      );
    }
    
    // If we don't have location data yet, show loading
    if (_pos == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.prayerTimes)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Check for cached prayer times
    final today = DateTime.now();
    final todayKey = _dateToKey(today);
    final todayTimes = _cachedTimes[todayKey];
    
    if (todayTimes == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.prayerTimes)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loadingPrayerTimes),
            ],
          ),
        ),
      );
    }
    
    // Format times for display
    final timeFormat = use24h ? DateFormat.Hm() : DateFormat.jm();
    final todaySunnah = _cachedSunnah[todayKey]!;
    
    // Build the UI with the extracted components
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayerTimes),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initLocation,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: AnimatedWaveBackground(
        child: RefreshIndicator(
          onRefresh: () async => _initLocation(),
          child: ListView(
            children: [
              // Location and date display
              LocationDisplay(
                cityName: _city,
                date: today,
                hasPermissionError: _permissionError,
                onRequestPermission: _initLocation,
              ),
              
              // Next prayer indicator with countdown
              NextPrayerIndicator(
                nextPrayerName: _nextName,
                timeUntil: _untilNext,
                progress: _progress,
                randomTip: _randomTip,
              ),
              
              // Prayer time cards
              PrayerTimeCard(
                prayerName: 'fajr',
                prayerTime: _getDateTime(todayTimes, Prayer.fajr),
                timeFormatted: timeFormat.format(_getDateTime(todayTimes, Prayer.fajr)),
                isNext: _nextName == 'fajr',
                use24hFormat: use24h,
              ),
              
              PrayerTimeCard(
                prayerName: 'sunrise',
                prayerTime: _getDateTime(todayTimes, Prayer.sunrise),
                timeFormatted: timeFormat.format(_getDateTime(todayTimes, Prayer.sunrise)),
                isNext: _nextName == 'sunrise',
                use24hFormat: use24h,
              ),
              
              PrayerTimeCard(
                prayerName: 'dhuhr',
                prayerTime: _getDateTime(todayTimes, Prayer.dhuhr),
                timeFormatted: timeFormat.format(_getDateTime(todayTimes, Prayer.dhuhr)),
                isNext: _nextName == 'dhuhr',
                use24hFormat: use24h,
              ),
              
              PrayerTimeCard(
                prayerName: 'asr',
                prayerTime: _getDateTime(todayTimes, Prayer.asr),
                timeFormatted: timeFormat.format(_getDateTime(todayTimes, Prayer.asr)),
                isNext: _nextName == 'asr',
                use24hFormat: use24h,
              ),
              
              PrayerTimeCard(
                prayerName: 'maghrib',
                prayerTime: _getDateTime(todayTimes, Prayer.maghrib),
                timeFormatted: timeFormat.format(_getDateTime(todayTimes, Prayer.maghrib)),
                isNext: _nextName == 'maghrib',
                use24hFormat: use24h,
              ),
              
              PrayerTimeCard(
                prayerName: 'isha',
                prayerTime: _getDateTime(todayTimes, Prayer.isha),
                timeFormatted: timeFormat.format(_getDateTime(todayTimes, Prayer.isha)),
                isNext: _nextName == 'isha',
                use24hFormat: use24h,
              ),
              
              // Additional sunnah times section
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.sunnahTimes,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Sunnah time cards
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.middleOfNight,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeFormat.format(todaySunnah.middleOfTheNight),
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.lastThirdOfNight,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeFormat.format(todaySunnah.lastThirdOfTheNight),
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
