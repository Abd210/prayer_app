import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';         // for jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // for fallback IP-based geolocation
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';

import '../services/location_service.dart';
import '../services/prayer_settings_provider.dart';

/// An advanced prayer times page with:
///  - SliverAppBar showing actual city name via geocoding or IP fallback.
///  - PageView for ±7 days with left-right swiping.
///  - "Return to Today" button to jump back to current date.
///  - Fallback method for city name if geocoding fails.
///  - Extra UI: random tip at bottom, fancy card for next prayer countdown, etc.
class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({Key? key}) : super(key: key);

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage>
    with SingleTickerProviderStateMixin {
  Position? _currentPosition;
  String _cityName = '...'; // Will update once we get a result

  // For storing day-by-day prayer times in a range from -7..+7
  final Map<int, PrayerTimes?> _cachedTimes = {};
  final Map<int, SunnahTimes?> _cachedSunnah = {};
  final int _daysRange = 7;

  // The PageView that can swipe between [-7..+7] => total 15 pages
  late PageController _pageController;
  final int _pageCenterIndex = 7; // so index=7 => offset=0 (today)
  int _currentIndex = 7;          // track which page is displayed

  // Next Prayer countdown
  Timer? _countdownTimer;
  Duration _timeUntilNext = Duration.zero;
  String _nextPrayerName = '-';
  double _prayerProgress = 0.0;

  // For a random tip or hadith at bottom
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
    _pageController = PageController(initialPage: _pageCenterIndex);

    _initLocation();
    _startCountdown();
    _randomTip = _tips[math.Random().nextInt(_tips.length)];
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Acquire user location, attempt geocoding, fallback to IP-based if needed,
  /// then preload day-by-day prayer times, and set next prayer info.
  Future<void> _initLocation() async {
    final pos = await LocationService.determinePosition();
    if (pos != null) {
      _currentPosition = pos;
      // Attempt standard geocoding first
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final pm = placemarks.first;
          _cityName = pm.locality ?? pm.administrativeArea ?? pm.country ?? 'Unknown';
        } else {
          // fallback
          await _getCityFromIP();
        }
      } catch (_) {
        // fallback
        await _getCityFromIP();
      }
      setState(() {});
      _preloadPrayerTimes();
      _updateNextPrayer();
    } else {
      // Could also fallback to IP city if location fails entirely
      await _getCityFromIP();
    }
  }

  /// Fallback method: uses a public IP-based geolocation API
  /// This is just a basic example. In production, use a secure & reliable service.
  Future<void> _getCityFromIP() async {
    try {
      final url = Uri.parse('https://ip-api.com/json/'); // or another free geolocation API
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final city = data['city'] as String?;
        final country = data['country'] as String?;
        if (city != null && city.isNotEmpty) {
          _cityName = city;
        } else if (country != null && country.isNotEmpty) {
          _cityName = country;
        } else {
          _cityName = 'Unknown via IP';
        }
      } else {
        _cityName = 'IP API Error';
      }
    } catch (e) {
      _cityName = 'IP Fallback Failed';
    }
    setState(() {});
  }

  /// Precompute PrayerTimes for each day in [-7..+7], calling Adhan for each date
  void _preloadPrayerTimes() {
    if (_currentPosition == null) return;
    final provider = Provider.of<PrayerSettingsProvider>(context, listen: false);
    final now = DateTime.now();

    for (int offset = -_daysRange; offset <= _daysRange; offset++) {
      final date = now.add(Duration(days: offset));
      final comps = DateComponents.from(date);

      final params = provider.calculationMethod.getParameters();
      params.madhab = provider.madhab;
      // Example adjustments
      params.adjustments.fajr = 2;
      params.adjustments.dhuhr = 2;
      params.adjustments.asr = 2;
      params.adjustments.maghrib = 2;
      params.adjustments.isha = 2;

      final coords = Coordinates(_currentPosition!.latitude, _currentPosition!.longitude);

      final pt = PrayerTimes(coords, comps, params);
      final st = SunnahTimes(pt);

      _cachedTimes[offset] = pt;
      _cachedSunnah[offset] = st;
    }
    setState(() {});
  }

  /// Timer for updating the next prayer each second
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNextPrayer();
    });
  }

  /// Next prayer is always from "today" offset=0
  /// if after Isha, we do tomorrow Fajr
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

    for (final prayer in [Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha]) {
      final pTime = timesLocal[prayer]!;
      if (now.isBefore(pTime)) {
        nextTime = pTime;
        nextName = prayer.name.toUpperCase();
        currentPrayerTime = _previousPrayerTime(prayer, timesLocal);
        break;
      }
    }

    // if none found, next is tomorrow fajr
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

  /// Quick helper: convert pageIndex -> dayOffset
  int _offsetFromIndex(int index) => (index - _pageCenterIndex);

  /// Quick helper: convert dayOffset -> pageIndex
  int _indexFromOffset(int offset) => (offset + _pageCenterIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We’ll use a CustomScrollView with Slivers so we can have a fancy pinned SliverAppBar
      body: CustomScrollView(
        slivers: [
          // SliverAppBar pinned at top showing the city
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(_cityName),
            ),
          ),

          // Next Prayer Card
          SliverToBoxAdapter(
            child: _buildNextPrayerCard(context),
          ),

          // The PageView in a Sliver fill area for swiping day by day
          SliverFillRemaining(
            child: Column(
              children: [
                // Controls: Return to Today
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex = _pageCenterIndex; // jump to today's index
                        });
                        _pageController.jumpToPage(_pageCenterIndex);
                      },
                      icon: const Icon(Icons.today),
                      label: const Text('Return to Today'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: (_daysRange * 2) + 1, // from -7..+7 => 15 total
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showRandomTip();
        },
        child: const Icon(Icons.lightbulb),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

  /// The single-day card for a given offset
  Widget _buildDayView(int offset) {
    final pt = _cachedTimes[offset];
    final st = _cachedSunnah[offset];
    if (pt == null || st == null) {
      return Center(child: CircularProgressIndicator());
    }

    final date = DateTime.now().add(Duration(days: offset));
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(date);

    final provider = Provider.of<PrayerSettingsProvider>(context, listen: false);
    final format = provider.use24hFormat ? 'HH:mm' : 'hh:mm a';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          // A random helpful note
          Text('Tip of the Day:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            _randomTip,
            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
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
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(display),
        ],
      ),
    );
  }

  /// Called by the FAB to show a new random tip
  void _showRandomTip() {
    setState(() {
      _randomTip = _tips[math.Random().nextInt(_tips.length)];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('New Tip: $_randomTip')),
    );
  }
}
