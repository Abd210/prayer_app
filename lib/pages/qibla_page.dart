
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';

/// QiblaPage: Uses the same color scheme as PrayerTimesPage for a consistent UI.
class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  Position? _currentPosition;
  String _cityName = 'Locating...';

  // Compass headings
  double? _deviceHeading;   // from FlutterCompass (0–360)
  double? _qiblaDirection;  // from Adhan (0–360, clockwise from North)

  @override
  void initState() {
    super.initState();
    _initLocation();
    _listenHeading();
  }

  /// Get user location, then compute Qibla direction
  Future<void> _initLocation() async {
    try {
      final position = await _determinePosition();
      setState(() => _currentPosition = position);

      // Reverse-geocode for a friendly city name
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String city = p.locality ??
            p.subLocality ??
            p.administrativeArea ??
            p.country ??
            '';
        if (city.isEmpty) {
          city = '${position.latitude.toStringAsFixed(2)}, '
                  '${position.longitude.toStringAsFixed(2)}';
        }
        _cityName = city;
      } else {
        _cityName = '${position.latitude.toStringAsFixed(2)}, '
                    '${position.longitude.toStringAsFixed(2)}';
      }

      // Calculate Qibla direction
      final coords = Coordinates(position.latitude, position.longitude);
      final qibla = Qibla(coords);
      _qiblaDirection = qibla.direction;

      setState(() {});
    } catch (e) {
      // If location or geocoding fails
      setState(() => _cityName = 'Location unavailable');
    }
  }

  /// Listen to compass heading via FlutterCompass
  void _listenHeading() {
    FlutterCompass.events?.listen((event) {
      setState(() {
        _deviceHeading = event.heading ?? 0;
      });
    });
  }

  /// Determine position with geolocator
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    // If we’re here, permission is granted
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// How close user heading is to Qibla
  double _calculateDifference() {
    if (_deviceHeading == null || _qiblaDirection == null) {
      return 999.0;
    }
    double diff = (_deviceHeading! - _qiblaDirection!).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final diff = _calculateDifference();
    final isFacingQibla = diff <= 5; // ±5° threshold
    final heading = _deviceHeading ?? 0.0;
    final qibla = _qiblaDirection ?? 0.0;

    return Scaffold(
      // Use the same AppBar style as in your PrayerTimesPage
      appBar: AppBar(
        title: Text(_cityName),
      ),
      // Background with a subtle wave effect in the same color scheme
      body: AnimatedWaveBackground(
        child: _currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top row: device heading & qibla
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildReading('Heading', heading),
                        _buildReading('Qibla', qibla),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Facing Qibla or difference
                    Text(
                      isFacingQibla
                          ? 'You are facing the Qibla!'
                          : 'Diff: ${diff.toStringAsFixed(1)}° from Qibla',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isFacingQibla ? FontWeight.bold : FontWeight.normal,
                        color: isFacingQibla
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Advanced Compass
                    // Rotate entire widget by -heading so north needle remains up
                    Transform.rotate(
                      angle: -heading * (math.pi / 180),
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: QiblaCompassPainter(
                          qiblaOffset: qibla,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildReading(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// Subtle wave background, tinted using your color scheme
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
            // Use your colorScheme's primary color as the wave tint
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
    // Base background: white
    canvas.drawColor(Colors.white, BlendMode.srcOver);

    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    // Draw multiple wave layers
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
    final width = size.width;
    final height = size.height;

    path.moveTo(0, height);
    for (double x = 0; x <= width; x++) {
      final y = amplitude *
              math.sin((x / width * 2 * math.pi * speed) +
                  (animationValue * 2 * math.pi * speed)) +
          (height - 120 - yOffset);
      path.lineTo(x, y);
    }
    path.lineTo(width, height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}

/// QiblaCompassPainter
///  - Uses Theme.of(context).colorScheme for consistency with PrayerTimesPage
class QiblaCompassPainter extends CustomPainter {
  final double qiblaOffset; // Qibla angle in degrees from North

  QiblaCompassPainter({required this.qiblaOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // Because we need theme, we can’t call Theme.of(context) here directly.
    // We'll pick some default color placeholders, but in practice, the wave
    // background helps unify color usage with the rest of the app.
    const ringColor = Colors.deepPurple; 
    const tickColor = Colors.deepPurpleAccent; 
    const mainNeedleColor = Colors.deepPurple; 
    const qiblaNeedleColor = Colors.orangeAccent; 
    const cardinalColor = Colors.deepPurple; 

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 10, ringPaint);

    // Tick marks (every 15°)
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2;
    const tickCount = 24; // 360/15
    for (int i = 0; i < tickCount; i++) {
      final angle = (2 * math.pi / tickCount) * i;
      final outer = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - (i % 2 == 0 ? 20 : 16)) * math.cos(angle),
        center.dy + (radius - (i % 2 == 0 ? 20 : 16)) * math.sin(angle),
      );
      canvas.drawLine(outer, inner, tickPaint);
    }

    // Cardinal directions: N, E, S, W
    _drawCardinal(canvas, center, radius, 'N', -math.pi / 2, cardinalColor);
    _drawCardinal(canvas, center, radius, 'E', 0, cardinalColor);
    _drawCardinal(canvas, center, radius, 'S', math.pi / 2, cardinalColor);
    _drawCardinal(canvas, center, radius, 'W', math.pi, cardinalColor);

    // Main needle (device "north" pointer, drawn pointing up)
    final needlePaint = Paint()
      ..color = mainNeedleColor
      ..style = PaintingStyle.fill;
    final needlePath = Path()
      ..moveTo(center.dx, center.dy - (radius * 0.7))
      ..lineTo(center.dx - 8, center.dy + 8)
      ..lineTo(center.dx + 8, center.dy + 8)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // Qibla pointer
    // We'll rotate the canvas by qiblaOffset (in radians), then draw a pointer
    canvas.save();
    final rad = qiblaOffset * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rad);
    canvas.translate(-center.dx, -center.dy);

    final qiblaPaint = Paint()
      ..color = qiblaNeedleColor
      ..style = PaintingStyle.fill;
    final qiblaPath = Path()
      ..moveTo(center.dx, center.dy - (radius * 0.5))
      ..lineTo(center.dx - 6, center.dy + 6)
      ..lineTo(center.dx + 6, center.dy + 6)
      ..close();
    canvas.drawPath(qiblaPath, qiblaPaint);

    canvas.restore();

    // Center dot
    canvas.drawCircle(center, 5, Paint()..color = ringColor);
  }

  void _drawCardinal(Canvas canvas, Offset center, double r, String dir, double angle, Color textColor) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: dir,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = center.dx + (r - 38) * math.cos(angle) - textPainter.width / 2;
    final y = center.dy + (r - 38) * math.sin(angle) - textPainter.height / 2;
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(QiblaCompassPainter oldDelegate) => true;
}