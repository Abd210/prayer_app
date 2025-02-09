import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import '../services/location_service.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _calculateQibla() async {
    final position = await LocationService.determinePosition();
    if (position != null) {
      final qibla = Qibla(Coordinates(position.latitude, position.longitude));
      final newAngle = qibla.direction; // in degrees

      _rotationAnim = Tween<double>(begin: _qiblaAngle, end: newAngle).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
      );
      _animController.forward(from: 0);

      setState(() {
        _qiblaAngle = newAngle;
        _currentPosition = position;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refresh() {
    setState(() => _isLoading = true);
    _calculateQibla();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
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
                              ? 'Location unavailable'
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
        onPressed: _refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/// Custom painter for the Qibla dial
class QiblaDialPainter extends CustomPainter {
  final double angle;
  QiblaDialPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw outer circle
    final dialPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, dialPaint);

    // Draw tick marks
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

    // Draw red needle
    final needlePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4;
    final needleLength = radius - 20;
    final radAngle = angle * math.pi / 180.0;
    final endNeedle = Offset(
      center.dx + needleLength * math.cos(radAngle),
      center.dy + needleLength * math.sin(radAngle),
    );
    canvas.drawLine(center, endNeedle, needlePaint);
  }

  @override
  bool shouldRepaint(covariant QiblaDialPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
