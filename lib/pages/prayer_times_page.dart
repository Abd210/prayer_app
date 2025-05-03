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
        /*  🔹 NEW — re‑schedule notifications so they
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
            PrayerAdjustments(fajr: 0, dhuhr: 0, asr: 0, maghrib: 0, isha: 0);
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
    if (kIsWeb) return; // Skip on web platform
    
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
        final prayerName = e.key.name.toUpperCase();
        await NotificationService().scheduleNotification(
          id: ids[e.key]!,
          title: l10n.prayerTimeTitle,
          body: l10n.prayerNotificationBody(prayerName, _city),
          scheduledDate: t,
          prayerName: prayerName,
        );
      }
    }
  }

  // —————————————————— UI
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 360;

    return AnimatedWaveBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_city, style: TextStyle(fontSize: isSmallScreen ? 16 : 18)),
          actions: [
            if (!kIsWeb) IconButton(
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
            : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        _nextPrayerCard(context, l10n, constraints.maxWidth),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 4 : 8,
                            horizontal: isSmallScreen ? 8 : 16,
                          ),
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.today, size: isSmallScreen ? 18 : 24),
                            label: Text(l10n.returnToToday,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 12 : 14,
                                )),
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
                                _dayView(idx - _pageCenterIndex, l10n, constraints.maxWidth),
                          ),
                        ),
                      ],
                    );
                  }
                ),
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

  Widget _nextPrayerCard(BuildContext ctx, AppLocalizations l10n, double maxWidth) {
    final isSmallScreen = maxWidth < 360;
    final h = _untilNext.inHours;
    final m = _untilNext.inMinutes % 60;
    final s = _untilNext.inSeconds % 60;
    final countdown =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(ctx).colorScheme.primary.withOpacity(.9),
            Theme.of(ctx).colorScheme.secondary.withOpacity(.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: "${l10n.nextPrayerLabel(_nextName)}",
            child: Text(
              l10n.nextPrayerLabel(_nextName),
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Semantics(
            label: l10n.startsIn(countdown),
            child: Text(
              l10n.startsIn(countdown),
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.white)
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Semantics(
              label: "Prayer countdown progress: ${(_progress * 100).toInt()}%",
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white.withOpacity(.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: isSmallScreen ? 4 : 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayView(int offset, AppLocalizations l10n, double maxWidth) {
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
    
    // Adjust sizes based on screen width
    final isSmallScreen = maxWidth < 360;
    final double titleFontSize = isSmallScreen ? 15.0 : 17.0;
    final double bodyFontSize = isSmallScreen ? 13.0 : 15.0;
    final double padding = isSmallScreen ? 12.0 : 16.0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // This ensures the content takes at least the full height of the container
          minHeight: MediaQuery.of(context).size.height - (isSmallScreen ? 200 : 220),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr, 
                style: TextStyle(
                  fontSize: bodyFontSize, 
                  fontWeight: FontWeight.bold
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              _row(l10n.prayerFajr, pt.fajr, fmt, Icons.wb_twighlight, maxWidth),
              _row(l10n.prayerSunrise, pt.sunrise, fmt, Icons.wb_sunny, maxWidth),
              _row(l10n.prayerDhuhr, pt.dhuhr, fmt, Icons.wb_sunny_outlined, maxWidth),
              _row(l10n.prayerAsr, pt.asr, fmt, Icons.filter_drama, maxWidth),
              _row(l10n.prayerMaghrib, pt.maghrib, fmt, Icons.nightlight_round, maxWidth),
              _row(l10n.prayerIsha, pt.isha, fmt, Icons.nightlight, maxWidth),
              Divider(height: isSmallScreen ? 24 : 32),
              Text(l10n.sunnahTimes, 
                style: TextStyle(
                  fontSize: titleFontSize, 
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              _row(l10n.middleNight, st.middleOfTheNight, fmt, Icons.dark_mode, maxWidth),
              _row(l10n.lastThirdNight, st.lastThirdOfTheNight, fmt, Icons.mode_night, maxWidth),
              SizedBox(height: isSmallScreen ? 16 : 24),
              Text(l10n.tipOfDay, 
                style: TextStyle(
                  fontSize: bodyFontSize, 
                  fontWeight: FontWeight.w500
                )
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(_randomTip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14, 
                    fontStyle: FontStyle.italic
                  )
              ),
              // Add bottom padding for scrolling
              SizedBox(height: isSmallScreen ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, DateTime t, String fmt, IconData icon, double maxWidth) {
    final isSmallScreen = maxWidth < 360;
    final textSize = isSmallScreen ? 13.0 : 15.0;
    final iconSize = isSmallScreen ? 18.0 : 22.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 3 : 5),
      child: Row(
        children: [
          Icon(icon, 
            color: Theme.of(context).colorScheme.primary, 
            size: iconSize
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Expanded(
            child: Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.w500, 
                fontSize: textSize
              ),
              overflow: TextOverflow.ellipsis,
            )
          ),
          Text(
            DateFormat(fmt).format(t.toLocal()), 
            style: TextStyle(fontSize: textSize),
          ),
        ],
      ),
    );
  }

  // Helper method to get day offset for page index
  int _dayOffset(int pageIndex) {
    return pageIndex - _pageCenterIndex;
  }

  Future<void> _updatePrayerTimes() async {
    Position? position;
    
    // Try getting manual location first if enabled
    position = await LocationService.getManualLocationIfEnabled();
    
    // If no manual location is set or it's not enabled, get current location
    if (position == null) {
      // Use frequent updates if enabled in settings
      final prefs = await SharedPreferences.getInstance();
      final frequentUpdates = prefs.getBool('frequentLocationUpdates') ?? false;
      position = await LocationService.determinePosition(frequentUpdates: frequentUpdates);
    }

    if (position == null) {
      setState(() {
        _permissionError = true;
      });
      return;
    }

    // Clear any permission errors if we got here
    if (_permissionError) {
      setState(() {
        _permissionError = false;
      });
    }
    
    // Update position and refresh calculations
    _pos = position;
    
    // Clear cached prayer times to force recalculation with new settings
    _cachedTimes.clear();
    _cachedSunnah.clear();
    
    // Use existing methods to update calculations
    _preload();
    _updateNext();
    
    // Schedule notifications
    _scheduleToday();
    
    setState(() {});
  }
}
