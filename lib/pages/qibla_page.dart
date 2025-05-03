import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/location_service.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => QiblaPageState();
}

class QiblaPageState extends State<QiblaPage> {
  String _cityName = 'Locating...';
  bool _isLoading = false;

  double? _deviceHeading; // from FlutterCompass
  double? _qiblaDirection; // from Adhan

  @override
  void initState() {
    super.initState();
    refreshPage(); // attempt location
    _listenHeading();
  }

  /// Called by the MainNavScreen or from the Refresh button
  Future<void> refreshPage() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _cityName = l10n.locating;
      _qiblaDirection = null;
    });

    final position = await LocationService.determinePosition();
    if (!mounted) return;

    if (position == null) {
      setState(() {
        _cityName = l10n.locationUnavailable;
        _isLoading = false;
      });
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

      // Qibla
      final coords = Coordinates(position.latitude, position.longitude);
      final qibla = Qibla(coords);
      _qiblaDirection = qibla.direction;
    } catch (_) {
      _cityName = 'Location error';
    }

    setState(() => _isLoading = false);
  }

  void _listenHeading() {
    FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      setState(() {
        _deviceHeading = event.heading ?? 0;
      });
    });
  }

  double _calculateDifference() {
    if (_deviceHeading == null || _qiblaDirection == null) return 999.0;
    double diff = (_deviceHeading! - _qiblaDirection!).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;

    final diff = _calculateDifference();
    final isFacingQibla = diff <= 5;
    final heading = _deviceHeading ?? 0.0;
    final qibla = _qiblaDirection ?? 0.0;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent
      appBar: AppBar(
        title: Text(
          _cityName,
          style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: l10n.refreshCompass,
            icon: const Icon(Icons.refresh),
            onPressed: refreshPage,
          ),
        ],
      ),
      body: AnimatedWaveBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_qiblaDirection == null)
                ? Center(
                    child: Text(l10n.locationUnavailable,
                        textAlign: TextAlign.center),
                  )
                : SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate sizes based on available width
                        final availableHeight = constraints.maxHeight;
                        final availableWidth = constraints.maxWidth;
                        
                        // Scale compass based on available space
                        final compassSize = availableWidth < 360 
                          ? availableWidth * 0.8 
                          : availableWidth < 600 
                              ? math.min(availableWidth * 0.7, availableHeight * 0.5)
                              : math.min(400.0, availableHeight * 0.6);
                        
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: isSmallScreen ? 8 : 16),
                                  // Heading & Qibla
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildReading(l10n.headingLabel, heading, theme, isSmallScreen),
                                      SizedBox(width: isSmallScreen ? 12 : 20),
                                      _buildReading(l10n.qiblaLabel, qibla, theme, isSmallScreen),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),

                                  // Warning banners - adjusted for small screens
                                  WarningBanner(
                                    message: l10n.compassWarnInterference,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                  WarningBanner(
                                    message: l10n.compassWarnNeedle,
                                    isSmallScreen: isSmallScreen,
                                  ),

                                  SizedBox(height: isSmallScreen ? 4 : 8),

                                  // Facing / difference text
                                  Text(
                                    isFacingQibla
                                        ? l10n.facingQibla
                                        : 'Δ  ${diff.toStringAsFixed(1)}°  from Qibla',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight:
                                          isFacingQibla ? FontWeight.bold : FontWeight.w500,
                                      color: isFacingQibla
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isSmallScreen ? 16 : 28),

                                  // Rotate the entire compass
                                  Transform.rotate(
                                    angle: -heading * (math.pi / 180),
                                    child: CustomPaint(
                                      size: Size(compassSize, compassSize),
                                      painter: QiblaCompassPainter(
                                        qiblaOffset: qibla,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 16 : 24),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
      ),
    );
  }

  Widget _buildReading(String label, double value, ThemeData theme, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 20, 
          vertical: isSmallScreen ? 10 : 14
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label, 
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: isSmallScreen ? 11 : 13
              )
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Text(
              '${value.toStringAsFixed(1)}°',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 18 : 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightweight warning banner used in the UI
class WarningBanner extends StatelessWidget {
  final String message;
  final bool isSmallScreen;
  
  const WarningBanner({
    Key? key, 
    required this.message,
    this.isSmallScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 24, 
        vertical: isSmallScreen ? 2 : 4
      ),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
      decoration: BoxDecoration(
        color: scheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: isSmallScreen ? 16 : 18, 
            color: scheme.error
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: scheme.error, 
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 11 : 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// QiblaCompassPainter draws the ring, cardinal directions, main "North" needle, etc.
class QiblaCompassPainter extends CustomPainter {
  final double qiblaOffset;
  final bool isSmallScreen;

  QiblaCompassPainter({
    required this.qiblaOffset,
    this.isSmallScreen = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const ringColor = Colors.deepPurple;
    const tickColor = Colors.deepPurpleAccent;
    const mainNeedleColor = Colors.deepPurple;
    const qiblaNeedleColor = Colors.orangeAccent;
    const cardinalColor = Colors.deepPurple;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Scale stroke widths based on device size
    final ringStrokeWidth = isSmallScreen ? 2.0 : 3.0;
    final tickStrokeWidth = isSmallScreen ? 1.5 : 2.0;
    final cardinalFontSize = isSmallScreen ? 18.0 : 22.0;

    // Outer ring
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStrokeWidth;
    canvas.drawCircle(center, radius - 10, ringPaint);

    // Tick marks (every 15°)
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = tickStrokeWidth;
    const tickCount = 24;
    for (int i = 0; i < tickCount; i++) {
      final angle = (2 * math.pi / tickCount) * i;
      final tickLength = i % 2 == 0 
          ? (isSmallScreen ? 8 : 10) 
          : (isSmallScreen ? 6 : 8);
      
      final outer = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 10 - tickLength) * math.cos(angle),
        center.dy + (radius - 10 - tickLength) * math.sin(angle),
      );
      canvas.drawLine(outer, inner, tickPaint);
    }

    // Cardinal directions
    _drawCardinal(canvas, center, radius, 'N', -math.pi / 2, cardinalColor, cardinalFontSize);
    _drawCardinal(canvas, center, radius, 'E', 0, cardinalColor, cardinalFontSize);
    _drawCardinal(canvas, center, radius, 'S', math.pi / 2, cardinalColor, cardinalFontSize);
    _drawCardinal(canvas, center, radius, 'W', math.pi, cardinalColor, cardinalFontSize);

    // Scale needle sizes
    final needleSize = isSmallScreen ? radius * 0.6 : radius * 0.7;
    final needleWidth = isSmallScreen ? 6.0 : 8.0;
    
    // Main needle (North)
    final needlePaint = Paint()..color = mainNeedleColor;
    final needlePath = Path()
      ..moveTo(center.dx, center.dy - needleSize)
      ..lineTo(center.dx - needleWidth, center.dy + needleWidth)
      ..lineTo(center.dx + needleWidth, center.dy + needleWidth)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // Qibla pointer
    canvas.save();
    final rad = qiblaOffset * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rad);
    canvas.translate(-center.dx, -center.dy);

    final qiblaSize = isSmallScreen ? radius * 0.5 : radius * 0.5;
    final qiblaWidth = isSmallScreen ? 5.0 : 6.0;
    
    final qiblaPaint = Paint()..color = qiblaNeedleColor;
    final qiblaPath = Path()
      ..moveTo(center.dx, center.dy - qiblaSize)
      ..lineTo(center.dx - qiblaWidth, center.dy + qiblaWidth)
      ..lineTo(center.dx + qiblaWidth, center.dy + qiblaWidth)
      ..close();
    canvas.drawPath(qiblaPath, qiblaPaint);

    canvas.restore();

    // Center dot
    final centerDotSize = isSmallScreen ? 4.0 : 5.0;
    canvas.drawCircle(center, centerDotSize, Paint()..color = ringColor);
  }

  void _drawCardinal(
    Canvas canvas,
    Offset center,
    double r,
    String dir,
    double angle,
    Color color,
    double fontSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: dir,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = isSmallScreen ? 32.0 : 38.0;
    final x = center.dx + (r - offset) * math.cos(angle) - textPainter.width / 2;
    final y = center.dy + (r - offset) * math.sin(angle) - textPainter.height / 2;
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(QiblaCompassPainter oldDelegate) => true;
}

/// The wave background
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
    // Repeats indefinitely
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
        return Container(
          // Make sure container covers the full screen
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor, // Use scaffold color
          child: CustomPaint(
            painter: _WavePainter(
              animationValue: _waveController.value,
              waveColor: theme.colorScheme.primary.withOpacity(0.15),
            ),
            // Cover the entire area
            size: Size.infinite,
            child: widget.child,
          ),
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
    final paint = Paint()..color = waveColor;
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
