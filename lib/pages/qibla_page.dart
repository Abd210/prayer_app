import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/location_service.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with SingleTickerProviderStateMixin {
  /// The Qibla angle from North (0-360) using Adhan's calculation.
  double _qiblaAngle = 0.0;

  /// The device heading (0-360 from North) from the magnetometer.
  double _deviceAngle = 0.0;

  /// Current location. Null while we haven't got it or error.
  Position? _currentPosition;

  /// Whether we’re still fetching location/Qibla or not.
  bool _isLoading = true;

  /// For smoothly animating Qibla angle changes if we recalc.
  late AnimationController _animController;
  late Animation<double> _qiblaAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // smooth anim
    );
    _qiblaAnim = Tween<double>(begin: 0, end: 0).animate(_animController);

    _initQibla();
    _listenToCompass();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Recalculate the Qibla based on current location
  Future<void> _initQibla() async {
    setState(() => _isLoading = true);

    final position = await LocationService.determinePosition();
    if (!mounted) return;

    if (position != null) {
      final qiblaCalc = Qibla(Coordinates(position.latitude, position.longitude));
      final newQiblaAngle = qiblaCalc.direction; // 0-360 from North

      // Animate from old angle => new angle
      _qiblaAnim = Tween<double>(begin: _qiblaAngle, end: newQiblaAngle).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
      );
      _animController.forward(from: 0);

      setState(() {
        _qiblaAngle = newQiblaAngle;
        _currentPosition = position;
        _isLoading = false;
      });
    } else {
      // if location is null
      setState(() {
        _currentPosition = null;
        _isLoading = false;
      });
    }
  }

  /// Listen to magnetometer to track phone orientation (device heading).
  void _listenToCompass() {
    magnetometerEvents.listen((MagnetometerEvent event) {
      final double x = event.x;
      final double y = event.y;

      // heading angle from the phone's perspective
      double headingRadians = math.atan2(y, x);
      double headingDeg = headingRadians * 180 / math.pi;
      // convert [-180, 180) to [0, 360)
      if (headingDeg < 0) headingDeg += 360;

      setState(() {
        _deviceAngle = headingDeg;
      });
    });
  }

  /// Refresh the Qibla angle
  void _refresh() => _initQibla();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Direction')),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AnimatedBuilder(
                animation: _qiblaAnim,
                builder: (context, child) {
                  // Qibla angle (0-360) that we animate from old->new
                  final double qiblaAngleDisplay = _qiblaAnim.value;

                  return _QiblaCompass(
                    deviceAngle: _deviceAngle,
                    qiblaAngle: qiblaAngleDisplay,
                    position: _currentPosition,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  final double deviceAngle;
  final double qiblaAngle;
  final Position? position;

  const _QiblaCompass({
    Key? key,
    required this.deviceAngle,
    required this.qiblaAngle,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Difference between device & qibla
    double diff = (qiblaAngle - deviceAngle) % 360;
    if (diff > 180) diff -= 360; // so that -179 < diff <= 180
    final diffAbs = diff.abs();

    // If user is within 5 deg => highlight Qibla arrow in green
    final bool isCloseToQibla = diffAbs < 5;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: _CompassDialPainter(theme: theme),
                  size: const Size(300, 300),
                ),
                _ArrowWidget(
                  angle: deviceAngle,
                  length: 120,
                  color: Colors.blueAccent,
                  thickness: 4,
                  icon: Icons.navigation,
                  iconColor: Colors.blueAccent,
                  label: 'Device',
                ),
                _ArrowWidget(
                  angle: qiblaAngle,
                  length: 100,
                  color: isCloseToQibla ? Colors.green : Colors.redAccent,
                  thickness: 4,
                  icon: Icons.star,
                  iconColor: isCloseToQibla ? Colors.green : Colors.redAccent,
                  label: 'Qibla',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isCloseToQibla 
              ? 'You Are Facing Qibla (±5°)!' 
              : 'Turn to align with Qibla.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCloseToQibla 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            position == null
                ? 'Location unavailable'
                : 'Lat: ${position!.latitude.toStringAsFixed(5)}, '
                  'Lon: ${position!.longitude.toStringAsFixed(5)}',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowWidget extends StatelessWidget {
  final double angle;
  final double length;
  final double thickness;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String label;

  const _ArrowWidget({
    Key? key,
    required this.angle,
    required this.length,
    required this.thickness,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double turns = angle / 360.0;

    return AnimatedRotation(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      turns: turns,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: thickness,
            height: length,
            color: color.withOpacity(0.7),
          ),
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final ThemeData theme;

  _CompassDialPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final circlePaint = Paint()
      ..color = theme.colorScheme.onBackground.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 8, circlePaint);

    final tickPaint = Paint()
      ..color = theme.colorScheme.onBackground.withOpacity(0.6)
      ..strokeWidth = 2;
    const divisions = 24;
    for (int i = 0; i < divisions; i++) {
      final tickAngle = (2 * math.pi / divisions) * i;
      final start = Offset(
        center.dx + (radius - 18) * math.cos(tickAngle),
        center.dy + (radius - 18) * math.sin(tickAngle),
      );
      final end = Offset(
        center.dx + (radius - 8) * math.cos(tickAngle),
        center.dy + (radius - 8) * math.sin(tickAngle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    _drawDirectionLabel(canvas, center, radius, 0, 'N');
    _drawDirectionLabel(canvas, center, radius, math.pi / 2, 'E');
    _drawDirectionLabel(canvas, center, radius, math.pi, 'S');
    _drawDirectionLabel(canvas, center, radius, 3 * math.pi / 2, 'W');
  }

  void _drawDirectionLabel(Canvas canvas, Offset center, double radius, double angle, String letter) {
    const textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrange,
    );
    final textSpan = TextSpan(text: letter, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final labelRadius = radius - 40;
    final dx = center.dx + labelRadius * math.cos(angle) - textPainter.width / 2;
    final dy = center.dy + labelRadius * math.sin(angle) - textPainter.height / 2;
    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_CompassDialPainter oldDelegate) => false;
}
