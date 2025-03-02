import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:prayer/pages/azkar_page/azkar_and_tasbih_advanced_page.dart';
import 'package:provider/provider.dart';

// Your pages:
import 'prayer_times_page.dart';
import 'qibla_page.dart';
import 'QuranPage.dart';
import 'settings_page.dart';

/// Example main nav screen with 5 tabs:
/// 0) PrayerTimesPage
/// 1) AzkarAndTasbihAdvancedPage
/// 2) QiblaPage
/// 3) QuranPage
/// 4) SettingsPage
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  // Create global keys for the two pages that need "refreshPage()" calls
  final GlobalKey<PrayerTimesPageState> _prayerKey = GlobalKey();
  final GlobalKey<QiblaPageState> _qiblaKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Build your actual pages (with keys attached to the ones that need refresh).
    _pages = [
      PrayerTimesPage(key: _prayerKey),
      const AzkarAndTasbihAdvancedPage(),
      QiblaPage(key: _qiblaKey),
      const QuranPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: theme.colorScheme.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (idx) {
            setState(() => _currentIndex = idx);

            // If user taps PrayerTimes (index=0), refresh that page
            if (idx == 0) {
              _prayerKey.currentState?.refreshPage();
            }
            // If user taps Qibla (index=2), refresh that page
            else if (idx == 2) {
              _qiblaKey.currentState?.refreshPage();
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Prayers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Azkār',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compass_calibration),
              label: 'Qibla',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Quran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
