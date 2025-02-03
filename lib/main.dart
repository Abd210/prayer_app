import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'; // for ImageFilter in frosted glass

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

/// -----------------------------------------------------------------------------
/// ADVANCED ISLAMIC APP (main.dart)
/// - Original UI for Splash, Home, Azkar, Tasbih, Settings.
/// - New Qibla page: displays a custom‑painted dial with tick marks and a red needle.
/// -----------------------------------------------------------------------------

// Define our brand colors as constants.
const Color kDarkGreen = Color(0xFF16423C);
const Color kMintGreen = Color(0xFF6A9C89);
const Color kLightGreen = Color(0xFFC4DAD2);
const Color kOffWhite = Color(0xFFE9EFEC);

void main() {
  runApp(MyApp());
}

/// A [ChangeNotifier] that stores and handles theme changes (light/dark).
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }
}

/// Root widget: sets up theme & SplashScreen, then transitions to MainScreen.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  late ThemeNotifier _themeNotifier;
  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Advanced Islamic App',
          theme: _themeNotifier.isDarkTheme ? _darkTheme() : _lightTheme(),
          home: SplashScreen(themeNotifier: _themeNotifier),
        );
      },
    );
  }
  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: kDarkGreen,
      scaffoldBackgroundColor: kOffWhite,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: kDarkGreen,
        onPrimary: Colors.white,
        secondary: kMintGreen,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: kOffWhite,
        onBackground: kDarkGreen,
        surface: kLightGreen,
        onSurface: kDarkGreen,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14),
      ),
    );
  }
  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kDarkGreen,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: kDarkGreen,
        onPrimary: kOffWhite,
        secondary: kMintGreen,
        onSecondary: Colors.black,
        error: Colors.redAccent,
        onError: Colors.white,
        background: Colors.black87,
        onBackground: kOffWhite,
        surface: kDarkGreen,
        onSurface: Colors.white,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14),
      ),
    );
  }
}

/// -----------------------------------------------------------------------------
/// SPLASH SCREEN (Animated multi‑layer wave with brand colors)
/// -----------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const SplashScreen({Key? key, required this.themeNotifier}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // continuously animate wave
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _initialized = true;
      });
      _navigateToMain();
    });
  }
  void _navigateToMain() {
    if (_initialized) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(themeNotifier: widget.themeNotifier)),
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
          // Multiple wave layers for a stylish effect
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
          // Centered icon & text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 100, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Advanced Islamic App',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
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
      final y = size.height -
          math.sin((animationValue * 2 * math.pi) + (x / waveLength)) * amplitude - 10;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    final paint = Paint()..color = color.withOpacity(0.7);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

/// -----------------------------------------------------------------------------
/// MAIN SCREEN (Bottom Navigation with 5 pages)
/// -----------------------------------------------------------------------------
class MainScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const MainScreen({Key? key, required this.themeNotifier}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      AzkarPage(),
      QiblaPage(), // New Qibla page
      TasbihPage(),
      SettingsPage(themeNotifier: widget.themeNotifier),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Azkar'),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
              BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Tasbih'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------------------------
/// HOME PAGE
/// -----------------------------------------------------------------------------
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

/// -----------------------------------------------------------------------------
/// AZKAR PAGE
/// -----------------------------------------------------------------------------
class AzkarPage extends StatefulWidget {
  @override
  _AzkarPageState createState() => _AzkarPageState();
}
class _AzkarPageState extends State<AzkarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<AzkarModel> _morningAzkar = [
    AzkarModel(
      arabic: 'اللّهـمَّ أَنْتَ رَبِّي لا إلهَ إلاّ أَنْتَ ...',
      translation: 'O Allah, You are my Lord...',
      reference: 'Morning Azkar #1',
    ),
    AzkarModel(
      arabic: 'أَصْـبَحْنَا وَأَصْبَحَ المُلْكُ لِلهِ ...',
      translation: 'We have entered a new morning...',
      reference: 'Morning Azkar #2',
    ),
  ];
  final List<AzkarModel> _eveningAzkar = [
    AzkarModel(
      arabic: 'أَمْسَيْنَا وَأَمْسَى المُـلْكُ لِلَّـهِ ...',
      translation: 'We have entered the evening...',
      reference: 'Evening Azkar #1',
    ),
    AzkarModel(
      arabic: 'اللَّهُمَّ إِنِّي أَمْسَيْتُ مِنْكَ فِي نِعْمَةٍ ...',
      translation: 'O Allah, I have entered this evening...',
      reference: 'Evening Azkar #2',
    ),
  ];
  final List<AzkarModel> _afterPrayerAzkar = [
    AzkarModel(
      arabic: 'أَسْتَغْفِرُ اللَّهَ (3 times)',
      translation: 'I seek forgiveness from Allah...',
      reference: 'After Prayer #1',
    ),
    AzkarModel(
      arabic: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ ...',
      translation: 'O Allah, You are Peace...',
      reference: 'After Prayer #2',
    ),
  ];
  final List<AzkarModel> _miscAzkar = [
    AzkarModel(
      arabic: 'بِسْمِ اللهِ (before eating)',
      translation: 'In the name of Allah.',
      reference: 'Misc #1',
    ),
    AzkarModel(
      arabic: 'الْحَمْدُ للّهِ (after eating)',
      translation: 'All praise is due to Allah.',
      reference: 'Misc #2',
    ),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              title: Text('Azkar', style: TextStyle(color: theme.colorScheme.onPrimary)),
              pinned: true,
              floating: true,
              backgroundColor: theme.colorScheme.primary,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: theme.colorScheme.onPrimary,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
                tabs: const [
                  Tab(text: 'Morning'),
                  Tab(text: 'Evening'),
                  Tab(text: 'AfterPrayer'),
                  Tab(text: 'Misc'),
                ],
              ),
            ),
          ],
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.surface, theme.colorScheme.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAzkarList(_morningAzkar),
                _buildAzkarList(_eveningAzkar),
                _buildAzkarList(_afterPrayerAzkar),
                _buildAzkarList(_miscAzkar),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAzkarList(List<AzkarModel> azkarList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: azkarList.length,
      itemBuilder: (context, index) {
        return AzkarCard(azkar: azkarList[index]);
      },
    );
  }
}
class AzkarModel {
  final String arabic;
  final String translation;
  final String reference;
  int counter;
  bool isExpanded;
  AzkarModel({
    required this.arabic,
    required this.translation,
    required this.reference,
    this.counter = 0,
    this.isExpanded = false,
  });
}
class AzkarCard extends StatefulWidget {
  final AzkarModel azkar;
  const AzkarCard({Key? key, required this.azkar}) : super(key: key);
  @override
  _AzkarCardState createState() => _AzkarCardState();
}
class _AzkarCardState extends State<AzkarCard> {
  void _toggleExpand() {
    setState(() {
      widget.azkar.isExpanded = !widget.azkar.isExpanded;
    });
  }
  void _incrementCounter() {
    setState(() {
      widget.azkar.counter++;
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final azkar = widget.azkar;
    return Card(
      color: theme.colorScheme.background.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  azkar.arabic,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 16, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      azkar.translation,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onBackground),
                    ),
                    if (azkar.reference.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        azkar.reference,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7), fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Count: ${azkar.counter}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onBackground),
                        ),
                        IconButton(
                          onPressed: _incrementCounter,
                          icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: azkar.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(azkar.isExpanded ? Icons.expand_less : Icons.expand_more, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------------------------
/// QIBLA PAGE (New Qibla UI: Custom Dial with Tick Marks and Red Needle)
/// -----------------------------------------------------------------------------
class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);
  @override
  _QiblaPageState createState() => _QiblaPageState();
}
class _QiblaPageState extends State<QiblaPage> with SingleTickerProviderStateMixin {
  double _qiblaAngle = 0.0;
  bool _isLoading = true;
  Position? _currentPosition;
  late AnimationController _animController;
  late Animation<double> _rotationAnim;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _rotationAnim = Tween<double>(begin: 0, end: 0).animate(_animController);
    _calculateQibla();
  }
  Future<void> _calculateQibla() async {
    final position = await LocationService.determinePosition();
    if (position != null) {
      final qibla = Qibla(Coordinates(position.latitude, position.longitude));
      double newAngle = qibla.direction;
      _rotationAnim = Tween<double>(begin: _qiblaAngle, end: newAngle).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
      );
      _animController.forward(from: 0.0);
      _qiblaAngle = newAngle;
      _currentPosition = position;
    }
    setState(() { _isLoading = false; });
  }
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Qibla', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kMintGreen, kLightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : AnimatedBuilder(
                  animation: _rotationAnim,
                  builder: (context, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 250,
                          width: 250,
                          child: CustomPaint(
                            painter: QiblaDialPainter(angle: _rotationAnim.value),
                            child: Center(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Qibla: ${_rotationAnim.value.toStringAsFixed(2)}°',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentPosition == null
                              ? 'Location Unavailable'
                              : 'Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
            _calculateQibla();
          });
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
class QiblaDialPainter extends CustomPainter {
  final double angle;
  QiblaDialPainter({required this.angle});
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final dialPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, dialPaint);
    // Draw tick marks.
    final tickPaint = Paint()..color = Colors.white70..strokeWidth = 2;
    for (int i = 0; i < 24; i++) {
      final tickAngle = (2 * math.pi / 24) * i;
      final start = Offset(
        center.dx + (radius - 10) * math.cos(tickAngle),
        center.dy + (radius - 10) * math.sin(tickAngle),
      );
      final end = Offset(
        center.dx + radius * math.cos(tickAngle),
        center.dy + radius * math.sin(tickAngle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
    // Draw red needle.
    final needlePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4;
    final needleLength = radius - 20;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(angle * math.pi / 180),
      center.dy + needleLength * math.sin(angle * math.pi / 180),
    );
    canvas.drawLine(center, needleEnd, needlePaint);
  }
  @override
  bool shouldRepaint(covariant QiblaDialPainter oldDelegate) => oldDelegate.angle != angle;
}

/// -----------------------------------------------------------------------------
/// TASBIH PAGE
/// -----------------------------------------------------------------------------
class TasbihPage extends StatefulWidget {
  @override
  _TasbihPageState createState() => _TasbihPageState();
}
class _TasbihPageState extends State<TasbihPage> {
  int _count = 0;
  void _incrementCount() {
    setState(() {
      _count++;
    });
  }
  void _resetCount() {
    setState(() {
      _count = 0;
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasbih', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tap to Increase Count', style: TextStyle(fontSize: 20, color: theme.colorScheme.onBackground)),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _incrementCount,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: Text(
                  '$_count',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _resetCount,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------------------------
/// SETTINGS PAGE
/// -----------------------------------------------------------------------------
class SettingsPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const SettingsPage({Key? key, required this.themeNotifier}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  PrayerSettings _prayerSettings = PrayerSettings(
    calculationMethod: CalculationMethod.muslim_world_league,
    madhab: Madhab.shafi,
    use24hFormat: true,
  );
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            SwitchListTile(
              activeColor: theme.colorScheme.primary,
              title: Text('Dark Theme', style: TextStyle(color: theme.colorScheme.onBackground)),
              value: widget.themeNotifier.isDarkTheme,
              onChanged: (val) {
                widget.themeNotifier.toggleTheme();
                setState(() {});
              },
            ),
            ListTile(
              title: Text('Calculation Method', style: TextStyle(color: theme.colorScheme.onBackground)),
              subtitle: Text(
                'Current: ${_prayerSettings.calculationMethod.name.toUpperCase()}',
                style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onBackground.withOpacity(0.7)),
              onTap: _showCalculationMethodDialog,
            ),
            ListTile(
              title: Text('Madhab', style: TextStyle(color: theme.colorScheme.onBackground)),
              subtitle: Text(
                _prayerSettings.madhab.name.toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onBackground.withOpacity(0.7)),
              onTap: _showMadhabDialog,
            ),
            SwitchListTile(
              activeColor: theme.colorScheme.primary,
              title: Text('Use 24-hour format', style: TextStyle(color: theme.colorScheme.onBackground)),
              value: _prayerSettings.use24hFormat,
              onChanged: (val) {
                setState(() {
                  _prayerSettings.use24hFormat = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showCalculationMethodDialog() async {
    final selectedMethod = await showDialog<CalculationMethod>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Calculation Method'),
        children: [
          SimpleDialogOption(child: const Text('Muslim World League'), onPressed: () => Navigator.pop(ctx, CalculationMethod.muslim_world_league)),
          SimpleDialogOption(child: const Text('Egyptian'), onPressed: () => Navigator.pop(ctx, CalculationMethod.egyptian)),
          SimpleDialogOption(child: const Text('Karachi'), onPressed: () => Navigator.pop(ctx, CalculationMethod.karachi)),
          SimpleDialogOption(child: const Text('Umm al-Qura'), onPressed: () => Navigator.pop(ctx, CalculationMethod.umm_al_qura)),
          SimpleDialogOption(child: const Text('Moonsighting Committee'), onPressed: () => Navigator.pop(ctx, CalculationMethod.moon_sighting_committee)),
          SimpleDialogOption(child: const Text('North America (ISNA)'), onPressed: () => Navigator.pop(ctx, CalculationMethod.north_america)),
        ],
      ),
    );
    if (selectedMethod != null) {
      setState(() {
        _prayerSettings.calculationMethod = selectedMethod;
      });
    }
  }
  void _showMadhabDialog() async {
    final selectedMadhab = await showDialog<Madhab>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Madhab'),
        children: [
          SimpleDialogOption(child: const Text('Shafi'), onPressed: () => Navigator.pop(ctx, Madhab.shafi)),
          SimpleDialogOption(child: const Text('Hanafi'), onPressed: () => Navigator.pop(ctx, Madhab.hanafi)),
        ],
      ),
    );
    if (selectedMadhab != null) {
      setState(() {
        _prayerSettings.madhab = selectedMadhab;
      });
    }
  }
}
class PrayerSettings {
  CalculationMethod calculationMethod;
  Madhab madhab;
  bool use24hFormat;
  PrayerSettings({
    required this.calculationMethod,
    required this.madhab,
    required this.use24hFormat,
  });
}

/// -----------------------------------------------------------------------------
/// LOCATION SERVICE
/// -----------------------------------------------------------------------------
class LocationService {
  static Future<Position?> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }
  static Future<String> getAddressFromPosition(Position position) async {
    return 'Lat: ${position.latitude}, Lon: ${position.longitude}';
  }
}

/// -----------------------------------------------------------------------------
/// PRAYER TIME SERVICE
/// -----------------------------------------------------------------------------
class PrayerTimeService {
  static Map<String, String>? calculatePrayerTimes(Position position) {
    try {
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      final prayerTimes = PrayerTimes.today(coordinates, params);
      final formatter = DateFormat('HH:mm');
      return {
        'Fajr': formatter.format(prayerTimes.fajr),
        'Sunrise': formatter.format(prayerTimes.sunrise),
        'Dhuhr': formatter.format(prayerTimes.dhuhr),
        'Asr': formatter.format(prayerTimes.asr),
        'Maghrib': formatter.format(prayerTimes.maghrib),
        'Isha': formatter.format(prayerTimes.isha),
      };
    } catch (e) {
      return null;
    }
  }
  static Map<String, String>? getNextPrayerTime(Map<String, String>? prayerTimes) {
    if (prayerTimes == null) return null;
    final now = DateTime.now();
    final format = DateFormat('HH:mm');
    final timesMap = <String, DateTime>{};
    prayerTimes.forEach((name, timeStr) {
      final parsedTime = format.parse(timeStr);
      final dt = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
      timesMap[name] = dt;
    });
    final upcoming = timesMap.entries.where((e) => e.value.isAfter(now)).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    if (upcoming.isNotEmpty) {
      final next = upcoming.first;
      return {'name': next.key, 'time': format.format(next.value)};
    } else {
      return {
        'name': 'Fajr (Tomorrow)',
        'time': prayerTimes['Fajr'] ?? 'N/A',
      };
    }
  }
}
