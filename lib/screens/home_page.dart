import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  Map<String, String>? _prayerTimes;
  String? _currentAddress;
  Timer? _updateTimer;
  final List<String> _hadithList = [
    '“Actions are by intentions.” [Bukhari & Muslim]',
    '“Make things easy, do not make things difficult.” [Bukhari]',
    '“None of you truly believes until he loves for his brother what he loves for himself.” [Bukhari]',
    '“Allah does not look at your appearance or wealth but looks at your hearts and deeds.” [Muslim]',
    '“The best of you are those who learn the Qur’an and teach it.” [Bukhari]',
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _startPeriodicUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    _currentPosition = await LocationService.determinePosition();
    if (_currentPosition != null) {
      _prayerTimes = PrayerTimeService.calculatePrayerTimes(_currentPosition!);
      _currentAddress = await LocationService.getAddressFromPosition(_currentPosition!);
      setState(() {});
    }
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextPrayerInfo = PrayerTimeService.getNextPrayerTime(_prayerTimes);
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(nextPrayerInfo),
                Expanded(
                  child: _prayerTimes == null
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPrayerTimesCard(),
                ),
              ],
            ),
          ),
          _buildDailyHadithButton(),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      return Container(color: theme.scaffoldBackgroundColor);
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              theme.colorScheme.surface.withOpacity(0.7),
              theme.colorScheme.background
            ],
            center: const Alignment(-0.5, -0.6),
            radius: 1.2,
          ),
        ),
      );
    }
  }

  Widget _buildHeader(Map<String, String>? nextPrayerInfo) {
    final theme = Theme.of(context);
    final hijriDate = _getHijriDate();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _currentAddress ?? 'Fetching location...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hijri Date: $hijriDate',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          if (nextPrayerInfo != null)
            Column(
              children: [
                Text(
                  'Next Prayer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${nextPrayerInfo['name']} at ${nextPrayerInfo['time']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            )
          else
            Text(
              'Loading next prayer...',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesCard() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onBackground.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Today\'s Prayer Times',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildPrayerTimeTable(_prayerTimes!)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeTable(Map<String, String> times) {
    final theme = Theme.of(context);
    final entries = times.entries.toList();
    return GridView.builder(
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (ctx, i) {
        final prayerName = entries[i].key;
        final prayerTime = entries[i].value;
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onBackground.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(prayerName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(prayerTime, style: TextStyle(color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyHadithButton() {
    final theme = Theme.of(context);
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: _showDailyHadith,
        icon: const Icon(Icons.menu_book),
        label: const Text('Daily Hadith'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  void _showDailyHadith() {
    final random = math.Random();
    final hadith = _hadithList[random.nextInt(_hadithList.length)];
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Daily Hadith', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 16),
              Text(hadith, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getHijriDate() {
    final now = DateTime.now();
    final approximateHijriMonth = (now.month + 1) % 12;
    final approximateHijriDay = (now.day + 2) % 30;
    final approximateHijriYear = (now.year - 622) + 1;
    return '$approximateHijriDay/$approximateHijriMonth/$approximateHijriYear (Hijri)';
  }
}
