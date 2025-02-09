import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import '../services/location_service.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  _QiblaPageState createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage>
    with SingleTickerProviderStateMixin {
  double _qiblaAngle = 0.0;
  bool _isLoading = true;
  Position? _currentPosition;
  late AnimationController _animController;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _rotationAnim = Tween<double>(begin: 0, end: 0).animate(_animController);
    _calculateQibla();
  }

  Future<void> _calculateQibla() async {
    try {
      final position = await LocationService.determinePosition();
      if (position != null) {
        final qibla = Qibla(Coordinates(position.latitude, position.longitude));
        double newAngle = qibla.direction;
        _rotationAnim = Tween<double>(begin: _qiblaAngle, end: newAngle).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );
        _animController.forward(from: 0.0);
        setState(() {
          _qiblaAngle = newAngle;
          _currentPosition = position;
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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define color constants for the gradient background.
    const kMintGreen = Color(0xFF98FF98);
    const kLightGreen = Color(0xFF90EE90);

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
                            child: Container(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Qibla: ${_rotationAnim.value.toStringAsFixed(2)}°',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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
          });
          _calculateQibla();
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
  bool shouldRepaint(covariant QiblaDialPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
