import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:prayer/pages/azkar_page.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';
import 'tasbih_page.dart';
import 'settings_page.dart';
import 'QuranPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Simple splash screen with an animated wave, then navigates to MainNavScreen
/// after a set duration.
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    Timer(const Duration(seconds: 3), () {
      setState(() => _initialized = true);
      _navigateToMain();
    });
  }

  void _navigateToMain() {
    if (_initialized) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color1 = theme.colorScheme.primary;
    final color2 = theme.colorScheme.secondary;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Animated waves at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPaint(
                      painter: WavePainter(_waveController.value, color2, 20.0, 1.2),
                      size: Size(MediaQuery.of(context).size.width, 60),
                    ),
                    CustomPaint(
                      painter: WavePainter(_waveController.value, color2, 30.0, 0.8),
                      size: Size(MediaQuery.of(context).size.width, 80),
                    ),
                    CustomPaint(
                      painter: WavePainter(_waveController.value, color2, 40.0, 0.5),
                      size: Size(MediaQuery.of(context).size.width, 100),
                    ),
                  ],
                );
              },
            ),
          ),
          // Center icon & text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 100, color: Colors.white.withOpacity(0.9)),
                const SizedBox(height: 16),
                Text(
                  'Advanced Islamic App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Main navigation screen with 6 tabs:
/// 0) PrayerTimesPage
/// 1) AzkarAndTasbihAdvancedPage (merged Azkar & Tasbih)
/// 2) QiblaPage
/// 3) TasbihPage
/// 4) QuranPage
/// 5) SettingsPage
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final _pages = const [
    PrayerTimesPage(),
    AzkarAndTasbihAdvancedPage(),
    QiblaPage(),
    QuranPage(),
    SettingsPage(),
  ];

  final _labels = const [
    'Prayers',
    'Azkār',
    'Qibla',
    'Quran',
    'Settings',
  ];

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
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: List.generate(_pages.length, (index) {
            IconData icon;
            switch (index) {
              case 0:
                icon = Icons.access_time; // Prayers
                break;
              case 1:
                icon = Icons.book; // Azkār merged with Tasbih
                break;
              case 2:
                icon = Icons.compass_calibration; // Qibla
                break;
              case 4:
                icon = Icons.menu_book; // Quran
                break;
              case 5:
                icon = Icons.settings; // Settings
                break;
              default:
                icon = Icons.home;
                break;
            }
            return BottomNavigationBarItem(
              icon: Icon(icon),
              label: _labels[index],
            );
          }),
        ),
      ),
    );
  }
}

/// Painter for the animated waves in the SplashScreen
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double amplitude;
  final double waveSpeed;

  WavePainter(this.animationValue, this.color, this.amplitude, this.waveSpeed);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final waveLength = size.width / waveSpeed;
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height
          - math.sin((animationValue * 2 * math.pi) + (x / waveLength)) * amplitude
          - 10;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()..color = color.withOpacity(0.75);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
