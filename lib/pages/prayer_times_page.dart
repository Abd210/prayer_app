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

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'statistcs.dart';
import '../services/location_service.dart';
import '../services/prayer_settings_provider.dart';
import '../services/notification_service.dart';

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
        /*  🔹 NEW — re‑schedule notifications so they
        match the *current* calculation settings            */
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
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      _city = m['city'];
      _preload();
      _updateNext();
      _scheduleToday();
    } catch (_) {/* ignore */}
  }

  Future<void> _saveWeekly() async {
    if (_pos == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _locKey,
        json.encode(
            {'lat': _pos!.latitude, 'lng': _pos!.longitude, 'city': _city}));
    await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  // —————————————————— location + preload
  Future<void> _initLocation() async {
    if (_pos != null) return; // already have cached location

    final l10n = AppLocalizations.of(context)!;
    final pos = await LocationService.determinePosition();
    if (!mounted) return;

    if (pos == null) {
      setState(() {
        _pos = null;
        _city = l10n.locationUnavailable;
      });
      return;
    }

    _pos = pos;
    try {
      final pl = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      _city = _chooseCity(pl, pos);
    } catch (_) {
      _city =
          '${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}';
    }

    setState(() {});
    _preload();
    _updateNext();
    _scheduleToday();
    _saveWeekly();
  }

  String _chooseCity(List<Placemark> list, Position p) {
    final plc = list.firstWhere(
        (pl) =>
            (pl.locality?.isNotEmpty ?? false) ||
            (pl.subLocality?.isNotEmpty ?? false) ||
            (pl.administrativeArea?.isNotEmpty ?? false) ||
            (pl.country?.isNotEmpty ?? false),
        orElse: () => list.first);
    return plc.locality ??
        plc.subLocality ??
        plc.administrativeArea ??
        plc.country ??
        '${p.latitude.toStringAsFixed(2)}, ${p.longitude.toStringAsFixed(2)}';
  }

  void _preload() {
    if (_pos == null) return;
    final prefs = Provider.of<PrayerSettingsProvider>(context, listen: false);
    final now = DateTime.now();

    for (int off = -_daysRange; off <= _daysRange; off++) {
      final date = now.add(Duration(days: off));
      final params = prefs.calculationMethod.getParameters()
        ..madhab = prefs.madhab
        ..adjustments =
            PrayerAdjustments(fajr: 2, dhuhr: 2, asr: 2, maghrib: 2, isha: 2);
      final coords = Coordinates(_pos!.latitude, _pos!.longitude);
      final pt = PrayerTimes(coords, DateComponents.from(date), params);
      _cachedTimes[off] = pt;
      _cachedSunnah[off] = SunnahTimes(pt);
    }
    setState(() {});
  }

  // —————————————————— ticker & next prayer
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _updateNext());
  }

  void _updateNext() {
    final pt = _cachedTimes[0];
    if (pt == null) {
      setState(() {
        _untilNext = Duration.zero;
        _nextName = '-';
        _progress = 0;
      });
      return;
    }

    final map = {
      Prayer.fajr: pt.fajr.toLocal(),
      Prayer.sunrise: pt.sunrise.toLocal(),
      Prayer.dhuhr: pt.dhuhr.toLocal(),
      Prayer.asr: pt.asr.toLocal(),
      Prayer.maghrib: pt.maghrib.toLocal(),
      Prayer.isha: pt.isha.toLocal(),
    };

    final now = DateTime.now();
    DateTime? nextTime;
    late Prayer nextPrayer;

    for (final p in [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha
    ]) {
      if (now.isBefore(map[p]!)) {
        nextTime = map[p];
        nextPrayer = p;
        break;
      }
    }

    DateTime currentStart;
    if (nextTime == null) {
      nextTime = pt.fajr.add(const Duration(days: 1)).toLocal();
      nextPrayer = Prayer.fajr;
      currentStart = map[Prayer.isha]!;
    } else {
      const order = [
        Prayer.fajr,
        Prayer.dhuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha
      ];
      final idx = order.indexOf(nextPrayer);
      currentStart = idx == 0 ? map[Prayer.isha]! : map[order[idx - 1]]!;
    }

    final until = nextTime.difference(now);
    final total = nextTime.difference(currentStart);
    setState(() {
      _untilNext = until;
      _nextName = nextPrayer.name.toUpperCase();
      _progress = 1 - (until.inSeconds / total.inSeconds);
    });
  }

  // —————————————————— notifications
  Future<void> _scheduleToday() async {
    final pt = _cachedTimes[0];
    if (pt == null) return;

    await NotificationService().cancelAllNotifications();
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    const ids = {
      Prayer.fajr: 0,
      Prayer.dhuhr: 1,
      Prayer.asr: 2,
      Prayer.maghrib: 3,
      Prayer.isha: 4,
    };

    final times = {
      Prayer.fajr: pt.fajr,
      Prayer.dhuhr: pt.dhuhr,
      Prayer.asr: pt.asr,
      Prayer.maghrib: pt.maghrib,
      Prayer.isha: pt.isha,
    };

    for (final e in times.entries) {
      final t = e.value.toLocal();
      if (t.isAfter(now)) {
        await NotificationService().scheduleNotification(
          id: ids[e.key]!,
          title: l10n.prayerTimeTitle,
          body:
              l10n.prayerNotificationBody(e.key.name.toUpperCase(), _city),
          scheduledDate: t,
        );
      }
    }
  }

  // —————————————————— UI
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedWaveBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_city),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_active),
              tooltip: l10n.testNotification,
              onPressed: () => NotificationService().sendTestNotification(),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.reload,
              onPressed: _initLocation,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: l10n.statisticsTooltip,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const StatisticsPage())),
          child: const Icon(Icons.insert_chart_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _pos == null
            ? _loadingView(l10n)
            : Column(
                children: [
                  _nextPrayerCard(context, l10n),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.today),
                      label: Text(l10n.returnToToday,
                          style: const TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() => _currentIndex = _pageCenterIndex);
                        _pager.jumpToPage(_pageCenterIndex);
                      },
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pager,
                      itemCount: _daysRange * 2 + 1,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (_, idx) =>
                          _dayView(idx - _pageCenterIndex, l10n),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _loadingView(AppLocalizations l10n) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            IconButton(
              icon: const Icon(Icons.refresh, size: 30),
              tooltip: l10n.reload,
              onPressed: _initLocation,
            ),
          ],
        ),
      );

  Widget _nextPrayerCard(BuildContext ctx, AppLocalizations l10n) {
    final h = _untilNext.inHours;
    final m = _untilNext.inMinutes % 60;
    final s = _untilNext.inSeconds % 60;
    final countdown =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(ctx).colorScheme.primary.withOpacity(.9),
            Theme.of(ctx).colorScheme.secondary.withOpacity(.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(
            l10n.nextPrayerLabel(_nextName),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(l10n.startsIn(countdown),
              style: const TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white.withOpacity(.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayView(int offset, AppLocalizations l10n) {
    final pt = _cachedTimes[offset];
    final st = _cachedSunnah[offset];
    if (pt == null || st == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final date = DateTime.now().add(Duration(days: offset));
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat.yMMMMEEEEd(locale).format(date);

    final prefs = Provider.of<PrayerSettingsProvider>(context, listen: false);
    final fmt = prefs.use24hFormat ? 'HH:mm' : 'hh:mm a';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row(l10n.prayerFajr, pt.fajr, fmt, Icons.wb_twighlight),
          _row(l10n.prayerSunrise, pt.sunrise, fmt, Icons.wb_sunny),
          _row(l10n.prayerDhuhr, pt.dhuhr, fmt, Icons.wb_sunny_outlined),
          _row(l10n.prayerAsr, pt.asr, fmt, Icons.filter_drama),
          _row(l10n.prayerMaghrib, pt.maghrib, fmt, Icons.nightlight_round),
          _row(l10n.prayerIsha, pt.isha, fmt, Icons.nightlight),
          const Divider(height: 32),
          Text(l10n.sunnahTimes, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _row(l10n.middleNight, st.middleOfTheNight, fmt, Icons.dark_mode),
          _row(l10n.lastThirdNight, st.lastThirdOfTheNight, fmt, Icons.mode_night),
          const SizedBox(height: 24),
          Text(l10n.tipOfDay, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(_randomTip,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _row(String label, DateTime t, String fmt, IconData icon) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
            Text(DateFormat(fmt).format(t.toLocal())),
          ],
        ),
      );
}
