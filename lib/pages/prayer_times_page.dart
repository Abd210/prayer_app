import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:prayer/pages/statistcs.dart';
import 'package:provider/provider.dart';

import '../services/location_service.dart';
import '../services/prayer_settings_provider.dart';

/// Animated wave background for matching the Qibla style
class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;
  const AnimatedWaveBackground({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedWaveBackgroundState createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _waveController,
      builder: (_, __) {
        return CustomPaint(
          painter: _WavePainter(
            animationValue: _waveController.value,
            waveColor: theme.colorScheme.primary.withOpacity(0.15),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  _WavePainter({required this.animationValue, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint background white first
    canvas.drawColor(Colors.white, BlendMode.srcOver);

    final paint = Paint()..color = waveColor;
    _drawWave(canvas, size, paint, amplitude: 18, speed: 1.0, yOffset: 0);
    _drawWave(canvas, size, paint, amplitude: 24, speed: 1.4, yOffset: 40);
    _drawWave(canvas, size, paint, amplitude: 16, speed: 2.0, yOffset: 70);
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double amplitude,
    required double speed,
    required double yOffset,
  }) {
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = amplitude *
              math.sin((x / size.width * 2 * math.pi * speed) +
                  (animationValue * 2 * math.pi * speed)) +
          (size.height - 120 - yOffset);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({Key? key}) : super(key: key);

  @override
  State<PrayerTimesPage> createState() => PrayerTimesPageState();
}

/// We'll detect app lifecycle changes (auto-refresh on resume) + wave background
class PrayerTimesPageState extends State<PrayerTimesPage>
    with WidgetsBindingObserver {
  Position? _currentPosition;
  String _cityName = '...';

  final Map<int, PrayerTimes?> _cachedTimes = {};
  final Map<int, SunnahTimes?> _cachedSunnah = {};
  final int _daysRange = 7;

  late PageController _pageController;
  final int _pageCenterIndex = 7;
  int _currentIndex = 7;

  Timer? _countdownTimer;
  Duration _timeUntilNext = Duration.zero;
  String _nextPrayerName = '-';
  double _prayerProgress = 0.0;

  final List<String> _tips = [
    '“Establish prayer and give charity.”',
    '“Prayer is better than sleep.”',
    '“Call upon Me, I will respond.”',
    'Reflect upon the Quran daily for spiritual growth.',
    'Strive for khushū` (humility) in prayer.',
    'Share your knowledge of prayer times with friends.',
    'Keep consistent with Sunnah prayers for extra reward.',
  ];
  String _randomTip = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // observe app lifecycle
    _pageController = PageController(initialPage: _pageCenterIndex);
    _randomTip = _tips[math.Random().nextInt(_tips.length)];

    _initLocation();
    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerSettingsProvider>(context, listen: false)
          .addListener(_onPrayerSettingsChanged);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<PrayerSettingsProvider>(context, listen: false)
        .removeListener(_onPrayerSettingsChanged);
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Called automatically when app is resumed from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Auto-refresh
      refreshPage();
    }
  }

  /// Called by MainNavScreen or from the refresh icon
  void refreshPage() {
    _initLocation();
  }

  void _onPrayerSettingsChanged() {
    _cachedTimes.clear();
    _cachedSunnah.clear();
    _preloadPrayerTimes();
    _updateNextPrayer();
  }

  Future<void> _initLocation() async {
    final pos = await LocationService.determinePosition();
    if (!mounted) return;

    if (pos == null) {
      setState(() {
        _currentPosition = null;
        _cityName = 'Location unavailable';
      });
      return;
    }

    _currentPosition = pos;
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.firstWhere(
          (p) =>
              (p.locality != null && p.locality!.isNotEmpty) ||
              (p.subLocality != null && p.subLocality!.isNotEmpty) ||
              (p.subAdministrativeArea != null &&
                  p.subAdministrativeArea!.isNotEmpty) ||
              (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) ||
              (p.country != null && p.country!.isNotEmpty) ||
              (p.name != null && p.name!.isNotEmpty),
          orElse: () => placemarks.first,
        );
        String city = placemark.locality ??
            placemark.subLocality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea ??
            placemark.country ??
            placemark.name ??
            '';
        if (city.isEmpty) {
          city =
              '${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}';
        }
        _cityName = city;
      } else {
        _cityName =
            '${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}';
      }
    } catch (e) {
      _cityName =
          '${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}';
    }

    setState(() {});
    _preloadPrayerTimes();
    _updateNextPrayer();
  }

  void _preloadPrayerTimes() {
    if (_currentPosition == null) return;
    final provider =
        Provider.of<PrayerSettingsProvider>(context, listen: false);
    final now = DateTime.now();

    for (int offset = -_daysRange; offset <= _daysRange; offset++) {
      final date = now.add(Duration(days: offset));
      final comps = DateComponents.from(date);

      final params = provider.calculationMethod.getParameters();
      params.madhab = provider.madhab;
      params.adjustments.fajr = 2;
      params.adjustments.dhuhr = 2;
      params.adjustments.asr = 2;
      params.adjustments.maghrib = 2;
      params.adjustments.isha = 2;

      final coords = Coordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final pt = PrayerTimes(coords, comps, params);
      final st = SunnahTimes(pt);

      _cachedTimes[offset] = pt;
      _cachedSunnah[offset] = st;
    }
    setState(() {});
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNextPrayer();
    });
  }

  void _updateNextPrayer() {
    final pt = _cachedTimes[0];
    if (pt == null) {
      _timeUntilNext = Duration.zero;
      _nextPrayerName = '-';
      _prayerProgress = 0.0;
      setState(() {});
      return;
    }
    final now = DateTime.now();
    final timesLocal = <Prayer, DateTime>{
      Prayer.fajr: pt.fajr.toLocal(),
      Prayer.sunrise: pt.sunrise.toLocal(),
      Prayer.dhuhr: pt.dhuhr.toLocal(),
      Prayer.asr: pt.asr.toLocal(),
      Prayer.maghrib: pt.maghrib.toLocal(),
      Prayer.isha: pt.isha.toLocal(),
    };

    DateTime? nextTime;
    String? nextName;
    DateTime? currentPrayerTime;

    for (final prayer in [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha
    ]) {
      final pTime = timesLocal[prayer]!;
      if (now.isBefore(pTime)) {
        nextTime = pTime;
        nextName = prayer.name.toUpperCase();
        currentPrayerTime = _previousPrayerTime(prayer, timesLocal);
        break;
      }
    }

    if (nextTime == null) {
      final tomorrowFajr = pt.fajr.add(const Duration(days: 1)).toLocal();
      nextTime = tomorrowFajr;
      nextName = 'FAJR (TOMORROW)';
      currentPrayerTime = timesLocal[Prayer.isha];
    }

    final untilNext = nextTime!.difference(now);
    final totalRange = nextTime.difference(currentPrayerTime!);
    final progress = 1.0 - (untilNext.inSeconds / totalRange.inSeconds);

    setState(() {
      _timeUntilNext = untilNext;
      _nextPrayerName = nextName!;
      _prayerProgress = progress.clamp(0.0, 1.0);
    });
  }

  DateTime _previousPrayerTime(Prayer prayer, Map<Prayer, DateTime> times) {
    if (prayer == Prayer.fajr) {
      return times[Prayer.isha]!;
    }
    final order = [Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];
    final idx = order.indexOf(prayer);
    return times[order[idx - 1]]!;
  }

  int _offsetFromIndex(int index) => index - _pageCenterIndex;

  @override
  Widget build(BuildContext context) {
    // We wrap the entire content in AnimatedWaveBackground
    return AnimatedWaveBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_cityName),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: refreshPage,
            ),
          ],
        ),
        // Add the floating action button with a "statistics" icon
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the placeholder statistics page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            );
          },
          tooltip: 'Statistics',
          child: const Icon(Icons.insert_chart_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        body: _currentPosition == null
            ? const Center(
                child: Text(
                  'Location unavailable.\nPlease enable GPS/Permissions.',
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: [
                  _buildNextPrayerCard(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex = _pageCenterIndex;
                        });
                        _pageController.jumpToPage(_pageCenterIndex);
                      },
                      icon: const Icon(Icons.today),
                      label: const Text('Return to Today'),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: (_daysRange * 2) + 1,
                      onPageChanged: (idx) {
                        setState(() => _currentIndex = idx);
                      },
                      itemBuilder: (context, idx) {
                        final offset = _offsetFromIndex(idx);
                        return _buildDayView(offset);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNextPrayerCard(BuildContext context) {
    final hh = _timeUntilNext.inHours;
    final mm = _timeUntilNext.inMinutes % 60;
    final ss = _timeUntilNext.inSeconds % 60;
    final countdown = '${hh.toString().padLeft(2, '0')}:'
        '${mm.toString().padLeft(2, '0')}:'
        '${ss.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Next Prayer: $_nextPrayerName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Starts in $countdown',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _prayerProgress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(int offset) {
    final pt = _cachedTimes[offset];
    final st = _cachedSunnah[offset];
    if (pt == null || st == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final date = DateTime.now().add(Duration(days: offset));
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(date);

    final provider =
        Provider.of<PrayerSettingsProvider>(context, listen: false);
    final format = provider.use24hFormat ? 'HH:mm' : 'hh:mm a';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _prayerRow('Fajr', pt.fajr, format, Icons.wb_twighlight),
          _prayerRow('Sunrise', pt.sunrise, format, Icons.wb_sunny),
          _prayerRow('Dhuhr', pt.dhuhr, format, Icons.wb_sunny_outlined),
          _prayerRow('Asr', pt.asr, format, Icons.filter_drama),
          _prayerRow('Maghrib', pt.maghrib, format, Icons.nightlight_round),
          _prayerRow('Isha', pt.isha, format, Icons.nightlight),
          const Divider(height: 32),
          Text('Sunnah Times', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _prayerRow('Middle of Night', st.middleOfTheNight, format, Icons.dark_mode),
          _prayerRow('Last Third of Night', st.lastThirdOfTheNight, format, Icons.mode_night),
          const SizedBox(height: 24),
          Text('Tip of the Day:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            _randomTip,
            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _prayerRow(String label, DateTime time, String format, IconData icon) {
    final localTime = time.toLocal();
    final display = DateFormat(format).format(localTime);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(display),
        ],
      ),
    );
  }
}
