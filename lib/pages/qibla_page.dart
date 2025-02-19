import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';

import '../services/location_service.dart';

/// QiblaPage: now reuses the same LocationService as PrayerTimesPage
/// so no double prompts and consistent behavior whichever is opened first.
class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  String _cityName = 'Locating...';

  double? _deviceHeading;   // from FlutterCompass (0..360)
  double? _qiblaDirection;  // from Adhan (0..360)

  @override
  void initState() {
    super.initState();
    _initLocation();
    _listenHeading();
  }

  Future<void> _initLocation() async {
    final position = await LocationService.determinePosition();
    if (!mounted) return;

    if (position == null) {
      // User denied or not available
      setState(() => _cityName = 'Location unavailable');
      return;
    }

    try {
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
          city =
              '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
        }
        _cityName = city;
      } else {
        _cityName =
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      }

      // Calculate Qibla direction (0..360 from North)
      final coords = Coordinates(position.latitude, position.longitude);
      final qibla = Qibla(coords);
      _qiblaDirection = qibla.direction;
    } catch (_) {
      _cityName = 'Location unavailable';
    }

    setState(() {});
  }

  void _listenHeading() {
    FlutterCompass.events?.listen((event) {
      setState(() {
        _deviceHeading = event.heading ?? 0;
      });
    });
  }

  /// Minimal angular difference [0..180] between heading & Qibla
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
    final isFacingQibla = diff <= 5;
    final heading = _deviceHeading ?? 0.0;
    final qibla = _qiblaDirection ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_cityName),
      ),
      body: AnimatedWaveBackground(
        child: (_qiblaDirection == null)
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row: heading & qibla
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildReading('Heading', heading),
                        _buildReading('Qibla', qibla),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // difference
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

                    // Rotate by -heading so the north arrow remains up
                    Transform.rotate(
                      angle: -heading * (math.pi / 180),
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: QiblaCompassPainter(qiblaOffset: qibla),
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

// Below is the same wave + painter logic, unchanged. 
// If you have it in a separate file, just keep it consistent.

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
    canvas.drawColor(Colors.white, BlendMode.srcOver);

    final paint = Paint()..color = waveColor;

    _drawWave(canvas, size, paint, amplitude: 18, speed: 1.0, yOffset: 0);
    _drawWave(canvas, size, paint, amplitude: 24, speed: 1.4, yOffset: 40);
    _drawWave(canvas, size, paint, amplitude: 16, speed: 2.0, yOffset: 70);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint,
      {required double amplitude, required double speed, required double yOffset}) {
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

class QiblaCompassPainter extends CustomPainter {
  final double qiblaOffset;

  QiblaCompassPainter({required this.qiblaOffset});

  @override
  void paint(Canvas canvas, Size size) {
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

    // Tick marks
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2;
    const tickCount = 24;
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

    // Cardinal directions
    _drawCardinal(canvas, center, radius, 'N', -math.pi / 2, cardinalColor);
    _drawCardinal(canvas, center, radius, 'E', 0, cardinalColor);
    _drawCardinal(canvas, center, radius, 'S', math.pi / 2, cardinalColor);
    _drawCardinal(canvas, center, radius, 'W', math.pi, cardinalColor);

    // Main needle
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
