import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

/// Main Application with two routes:
/// - HomePage: Displays prayer times, sunnah times, next prayer info, hadith button, and options to choose calculation method/madhab.
/// - QiblaPage: Displays an animated Qibla compass using the Adhan Qibla calculation.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adhan Advanced App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/qibla': (context) => QiblaPage(),
      },
    );
  }
}

/// HomePage integrates all prayer time features:
/// - Retrieves the user’s location using Geolocator (with permission and error handling).
/// - Uses Adhan’s Coordinates, DateComponents, CalculationMethod, and PrayerTimes APIs.
/// - Also calculates SunnahTimes and displays both prayer and sunnah times.
/// - Offers dynamic selection of calculation method and madhab.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  PrayerTimes? _prayerTimes;
  SunnahTimes? _sunnahTimes;
  Timer? _updateTimer;

  // Default settings
  CalculationMethod _selectedMethod = CalculationMethod.karachi;
  Madhab _selectedMadhab = Madhab.hanafi;

  @override
  void initState() {
    super.initState();
    _initLocationAndPrayerTimes();
    _startPeriodicUpdates();
  }

  /// Initialize location and calculate prayer times for current coordinates
  Future<void> _initLocationAndPrayerTimes() async {
    try {
      final pos = await _determinePosition();
      setState(() {
        _currentPosition = pos;
      });
      _calculatePrayerTimes();
    } catch (e) {
      print('Error obtaining location: $e');
    }
  }

  /// Geolocator wrapper with permission checks
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }
    return await Geolocator.getCurrentPosition();
  }

  /// Uses Adhan to calculate prayer times and Sunnah times for today
  void _calculatePrayerTimes() {
    if (_currentPosition == null) return;
    // Create coordinates (with validate: false for production; set to true to throw on invalid coordinates)
    final coordinates = Coordinates(_currentPosition!.latitude, _currentPosition!.longitude, validate: false);
    final dateComponents = DateComponents.from(DateTime.now());
    // Get pre-populated calculation parameters and customize
    CalculationParameters params = _selectedMethod.getParameters();
    params.madhab = _selectedMadhab;
    // Example custom adjustments (in minutes)
    params.adjustments.fajr = 2;
    params.adjustments.dhuhr = 2;
    params.adjustments.asr = 2;
    params.adjustments.maghrib = 2;
    params.adjustments.isha = 2;

    // Calculate prayer times for today (local timezone conversion via .toLocal())
    PrayerTimes prayerTimes = PrayerTimes(coordinates, dateComponents, params);
    // Calculate Sunnah times (middle of the night, last third of the night)
    SunnahTimes sunnahTimes = SunnahTimes(prayerTimes);

    setState(() {
      _prayerTimes = prayerTimes;
      _sunnahTimes = sunnahTimes;
    });
  }

  /// Periodically update prayer times (every minute) to keep next-prayer info current
  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _calculatePrayerTimes();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  /// Build UI for prayer times and settings
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times'),
        actions: [
          // Navigate to Qibla page
          IconButton(
            icon: Icon(Icons.compass_calibration),
            onPressed: () => Navigator.pushNamed(context, '/qibla'),
          ),
        ],
      ),
      body: _prayerTimes == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown to select CalculationMethod (using its runtime values)
                  Text('Select Calculation Method:'),
                  DropdownButton<CalculationMethod>(
                    value: _selectedMethod,
                    onChanged: (newMethod) {
                      if (newMethod != null) {
                        setState(() {
                          _selectedMethod = newMethod;
                        });
                        _calculatePrayerTimes();
                      }
                    },
                    items: [
                      _buildDropdownItem('Muslim World League', CalculationMethod.muslim_world_league),
                      _buildDropdownItem('Egyptian', CalculationMethod.egyptian),
                      _buildDropdownItem('Karachi', CalculationMethod.karachi),
                      _buildDropdownItem('Umm al-Qura', CalculationMethod.umm_al_qura),
                      _buildDropdownItem('Dubai', CalculationMethod.dubai),
                      _buildDropdownItem('Qatar', CalculationMethod.qatar),
                      _buildDropdownItem('Kuwait', CalculationMethod.kuwait),
                      _buildDropdownItem('Moonsighting Committee', CalculationMethod.moon_sighting_committee),
                      _buildDropdownItem('Singapore', CalculationMethod.singapore),
                      _buildDropdownItem('North America', CalculationMethod.north_america),
                      _buildDropdownItem('Turkey', CalculationMethod.turkey),
                      _buildDropdownItem('Tehran', CalculationMethod.tehran),
                      _buildDropdownItem('Other', CalculationMethod.other),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Toggle between Hanafi and Shafi madhabs
                  Row(
                    children: [
                      Text('Madhab: '),
                      ChoiceChip(
                        label: Text('Hanafi'),
                        selected: _selectedMadhab == Madhab.hanafi,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMadhab = Madhab.hanafi;
                          });
                          _calculatePrayerTimes();
                        },
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Shafi'),
                        selected: _selectedMadhab == Madhab.shafi,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMadhab = Madhab.shafi;
                          });
                          _calculatePrayerTimes();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text("Today's Prayer Times:", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  _buildPrayerTimeRow('Fajr', _prayerTimes!.fajr),
                  _buildPrayerTimeRow('Sunrise', _prayerTimes!.sunrise),
                  _buildPrayerTimeRow('Dhuhr', _prayerTimes!.dhuhr),
                  _buildPrayerTimeRow('Asr', _prayerTimes!.asr),
                  _buildPrayerTimeRow('Maghrib', _prayerTimes!.maghrib),
                  _buildPrayerTimeRow('Isha', _prayerTimes!.isha),
                  Divider(height: 32),
                  Text('Sunnah Times:', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  _buildPrayerTimeRow('Middle of the Night', _sunnahTimes!.middleOfTheNight),
                  _buildPrayerTimeRow('Last Third of the Night', _sunnahTimes!.lastThirdOfTheNight),
                  Divider(height: 32),
                  _buildNextPrayerInfo(),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _showDailyHadith,
                      child: Text('Daily Hadith'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Helper: Build a dropdown menu item
  DropdownMenuItem<CalculationMethod> _buildDropdownItem(String text, CalculationMethod method) {
    return DropdownMenuItem<CalculationMethod>(
      value: method,
      child: Text(text),
    );
  }

  /// Helper: Display a prayer time row with the given name and time
  Widget _buildPrayerTimeRow(String prayerName, DateTime time) {
    String formattedTime = DateFormat.jm().format(time.toLocal());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(prayerName, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(formattedTime),
        ],
      ),
    );
  }

  /// Determine the next prayer based on current time and display its info
  Widget _buildNextPrayerInfo() {
    DateTime now = DateTime.now();
    String nextPrayerName = '';
    DateTime? nextPrayerTime;
    if (now.isBefore(_prayerTimes!.fajr)) {
      nextPrayerName = 'Fajr';
      nextPrayerTime = _prayerTimes!.fajr;
    } else if (now.isBefore(_prayerTimes!.dhuhr)) {
      nextPrayerName = 'Dhuhr';
      nextPrayerTime = _prayerTimes!.dhuhr;
    } else if (now.isBefore(_prayerTimes!.asr)) {
      nextPrayerName = 'Asr';
      nextPrayerTime = _prayerTimes!.asr;
    } else if (now.isBefore(_prayerTimes!.maghrib)) {
      nextPrayerName = 'Maghrib';
      nextPrayerTime = _prayerTimes!.maghrib;
    } else if (now.isBefore(_prayerTimes!.isha)) {
      nextPrayerName = 'Isha';
      nextPrayerTime = _prayerTimes!.isha;
    } else {
      // After Isha, assume next prayer is tomorrow’s Fajr.
      nextPrayerName = 'Fajr';
      nextPrayerTime = _prayerTimes!.fajr.add(Duration(days: 1));
    }
    String formattedNextTime = DateFormat.jm().format(nextPrayerTime!.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next Prayer:', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 8),
        Text('$nextPrayerName at $formattedNextTime', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  /// Show a bottom sheet with a randomly selected daily hadith.
  void _showDailyHadith() {
    final List<String> hadiths = [
      '“Actions are by intentions.” [Bukhari & Muslim]',
      '“Make things easy, do not make things difficult.” [Bukhari]',
      '“None of you truly believes until he loves for his brother what he loves for himself.” [Bukhari]',
      '“Allah does not look at your appearance or wealth but looks at your hearts and deeds.” [Muslim]',
      '“The best of you are those who learn the Qur’an and teach it.” [Bukhari]',
      '“The best of you are those who are best to their families.” [Tirmidhi]',
      '“The most beloved of deeds to Allah is the most regular and constant even if it were little.” [Bukhari]',
      '“He is not a believer whose stomach is filled while the neighbor to his side goes hungry.” [Bukhari]',
      '“The strongest among you is the one who controls his anger.” [Bukhari]',
      '“Seek knowledge from the cradle to the grave.” [Unknown]',
    ];
    final String hadith = hadiths[math.Random().nextInt(hadiths.length)];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Daily Hadith', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Text(hadith, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// QiblaPage uses Adhan’s Qibla API to determine the Qibla direction
/// and displays it in an animated, custom-painted dial.
class QiblaPage extends StatefulWidget {
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
    _animController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _rotationAnim = Tween<double>(begin: 0, end: 0).animate(_animController);
    _calculateQibla();
  }

  /// Calculate Qibla direction from the current location
  Future<void> _calculateQibla() async {
    try {
      final pos = await _determinePosition();
      if (pos != null) {
        final qibla = Qibla(Coordinates(pos.latitude, pos.longitude));
        double newAngle = qibla.direction;
        _rotationAnim = Tween<double>(begin: _qiblaAngle, end: newAngle).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );
        _animController.forward(from: 0.0);
        setState(() {
          _qiblaAngle = newAngle;
          _currentPosition = pos;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error calculating Qibla: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Similar location-determination as in HomePage
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Build the Qibla page UI with an animated dial
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Qibla Direction'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
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
                            child: Container(),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Qibla: ${_rotationAnim.value.toStringAsFixed(2)}°',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 6),
                        Text(
                          _currentPosition == null
                              ? 'Location unavailable'
                              : 'Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
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
          });
          _calculateQibla();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

/// Custom painter for the Qibla dial, drawing a circle, tick marks, and a red needle.
class QiblaDialPainter extends CustomPainter {
  final double angle;
  QiblaDialPainter({required this.angle});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw the dial circle
    final dialPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, dialPaint);
    
    // Draw tick marks around the dial
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
    
    // Draw the red needle indicating the Qibla direction
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
