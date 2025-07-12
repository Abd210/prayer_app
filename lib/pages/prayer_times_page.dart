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
import 'package:flutter/animation.dart';

import 'package:prayer/generated/l10n/app_localizations.dart';

import 'statistcs.dart';
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
    with WidgetsBindingObserver, TickerProviderStateMixin {
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
  int _currentTipIndex = 0;
  Timer? _tipTimer;
  String get _currentTip =>
      _tips.isEmpty ? '...' : _tips[_currentTipIndex % _tips.length];

  // — weekly cache keys
  static const _locKey = 'WEEKLY_LOCATION_DATA';
  static const _tsKey = 'WEEKLY_LOCATION_TIMESTAMP';
  static const _weekMs = 7 * 24 * 60 * 60 * 1000;

  late AnimationController _cityFadeController;
  late Animation<double> _cityFadeAnimation;
  late AnimationController _tipFadeController;
  late Animation<double> _tipFadeAnimation;

  // —————————————————— init / dispose
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cityFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cityFadeAnimation = CurvedAnimation(parent: _cityFadeController, curve: Curves.easeIn);
    _tipFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _tipFadeAnimation = CurvedAnimation(parent: _tipFadeController, curve: Curves.easeIn);

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
      _currentTipIndex = _rand.nextInt(_tips.length);
      _tipTimer?.cancel();
      _tipTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        _tipFadeController.reverse().then((_) {
          setState(() {
            _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
          });
          _tipFadeController.forward();
        });
      });
      _tipFadeController.forward();
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
    _tipTimer?.cancel();
    _cityFadeController.dispose();
    _tipFadeController.dispose();
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
    _cityFadeController.forward(from: 0);
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
        ..adjustments = PrayerAdjustments(
          fajr: prefs.fajrAdjustment,
          dhuhr: prefs.dhuhrAdjustment,
          asr: prefs.asrAdjustment,
          maghrib: prefs.maghribAdjustment,
          isha: prefs.ishaAdjustment,
        );
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
          title: Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 22),
              const SizedBox(width: 6),
              FadeTransition(
                opacity: _cityFadeAnimation,
                child: Text(_city, style: TextStyle(fontSize: isSmallScreen ? 16 : 18)),
              ),
            ],
          ),
          actions: [
            if (!kIsWeb) IconButton(
              icon: const Icon(Icons.notifications_active),
              tooltip: l10n.testNotification,
              onPressed: () => NotificationService().sendTestNotification(),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.reload,
              onPressed: () async {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        const Text('Updating location...'),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                await LocationService.forceRefreshLocation();
                await _initLocation();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Location updated successfully!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
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

    // Pick an icon for the next prayer
    IconData prayerIcon;
    switch (_nextName.toLowerCase()) {
      case 'fajr':
        prayerIcon = Icons.wb_twighlight;
        break;
      case 'dhuhr':
        prayerIcon = Icons.wb_sunny_outlined;
        break;
      case 'asr':
        prayerIcon = Icons.filter_drama;
        break;
      case 'maghrib':
        prayerIcon = Icons.nightlight_round;
        break;
      case 'isha':
        prayerIcon = Icons.nightlight;
        break;
      default:
        prayerIcon = Icons.access_time;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _progress),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(ctx).colorScheme.primary.withOpacity(.95),
                Theme.of(ctx).colorScheme.secondary.withOpacity(.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 20),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: isSmallScreen ? 54 : 70,
                    height: isSmallScreen ? 54 : 70,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(.18),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Icon(prayerIcon, color: Colors.white, size: isSmallScreen ? 32 : 40),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nextPrayerLabel(_nextName),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 17 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.startsIn(countdown),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 22,
                        color: Colors.white,
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
    final double padding = isSmallScreen ? 8.0 : 12.0;

    // Find the next prayer for highlighting
    final now = DateTime.now();
    int? nextPrayerIdx;
    final prayerTimes = [pt.fajr, pt.dhuhr, pt.asr, pt.maghrib, pt.isha];
    for (int i = 0; i < prayerTimes.length; i++) {
      if (now.isBefore(prayerTimes[i])) {
        nextPrayerIdx = i;
        break;
      }
    }

    // Compare displayed date to today (ignore time)
    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - (isSmallScreen ? 180 : 180),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Return to Today button in one row
              Row(
                children: [
                  Icon(Icons.calendar_today, size: isSmallScreen ? 16 : 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dateStr, 
                      style: TextStyle(
                        fontSize: bodyFontSize, 
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isToday)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.today, color: Colors.white, size: isSmallScreen ? 16 : 18),
                        label: Text(l10n.returnToToday,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 11 : 13,
                            )),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          minimumSize: Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() => _currentIndex = _pageCenterIndex);
                          _pager.jumpToPage(_pageCenterIndex);
                        },
                      ),
                    ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              _prayerRow(l10n.prayerFajr, pt.fajr, fmt, Icons.wb_twighlight, maxWidth, nextPrayerIdx == 0),
              _prayerRow(l10n.prayerDhuhr, pt.dhuhr, fmt, Icons.wb_sunny_outlined, maxWidth, nextPrayerIdx == 1),
              _prayerRow(l10n.prayerAsr, pt.asr, fmt, Icons.filter_drama, maxWidth, nextPrayerIdx == 2),
              _prayerRow(l10n.prayerMaghrib, pt.maghrib, fmt, Icons.nightlight_round, maxWidth, nextPrayerIdx == 3),
              _prayerRow(l10n.prayerIsha, pt.isha, fmt, Icons.nightlight, maxWidth, nextPrayerIdx == 4),
              Divider(height: isSmallScreen ? 16 : 20),
              Text(l10n.sunnahTimes, 
                style: TextStyle(
                  fontSize: titleFontSize, 
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              _row(l10n.middleNight, st.middleOfTheNight, fmt, Icons.dark_mode, maxWidth),
              _row(l10n.lastThirdNight, st.lastThirdOfTheNight, fmt, Icons.mode_night, maxWidth),
              SizedBox(height: isSmallScreen ? 10 : 14),
              // --- Enhanced Tip of the Day Section ---
              FadeTransition(
                opacity: _tipFadeAnimation,
                child: Card(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4, horizontal: 0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12, horizontal: isSmallScreen ? 8 : 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                          child: Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary, size: isSmallScreen ? 18 : 22),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.tipOfDay, 
                                style: TextStyle(
                                  fontSize: bodyFontSize, 
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              ),
                              SizedBox(height: 3),
                              Text(
                                _currentTip,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 13, 
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // --- End Enhanced Tip Section ---
              SizedBox(height: isSmallScreen ? 8 : 12),
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

  Widget _prayerRow(String label, DateTime t, String fmt, IconData icon, double maxWidth, bool highlight) {
    final isSmallScreen = maxWidth < 360;
    final textSize = isSmallScreen ? 13.0 : 15.0;
    final iconSize = isSmallScreen ? 18.0 : 22.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 3 : 6),
      decoration: BoxDecoration(
        color: highlight ? Theme.of(context).colorScheme.primary.withOpacity(0.13) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 7 : 12, horizontal: isSmallScreen ? 8 : 16),
        child: Row(
          children: [
            Icon(icon, 
              color: Theme.of(context).colorScheme.primary, 
              size: iconSize
            ),
            SizedBox(width: isSmallScreen ? 6 : 12),
            Expanded(
              child: Text(
                label, 
                style: TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: textSize
                ),
                overflow: TextOverflow.ellipsis,
              )
            ),
            Text(
              DateFormat(fmt).format(t.toLocal()), 
              style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w500),
            ),
          ],
        ),
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
