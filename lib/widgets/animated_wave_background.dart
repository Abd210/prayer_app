import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that draws animated waves in the background.
class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;

  const AnimatedWaveBackground({Key? key, required this.child})
      : super(key: key);

  @override
  _AnimatedWaveBackgroundState createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // This controller will run indefinitely and rebuild the painter every frame
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(); // loop forever
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
      builder: (context, child) {
        return CustomPaint(
          painter: _GreenWavePainter(
            waveValue: _waveController.value,
            // Use the theme’s primary color at ~15% opacity:
            waveColor: theme.colorScheme.primary.withOpacity(0.15),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _GreenWavePainter extends CustomPainter {
  final double waveValue;
  final Color waveColor;

  _GreenWavePainter({
    required this.waveValue,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    // We will draw 2 or 3 waves at different phases or amplitudes
    _drawWave(canvas, size, paint, amplitude: 20, speed: 1.0, yOffset: 0);
    _drawWave(canvas, size, paint, amplitude: 25, speed: 1.5, yOffset: 30);
    _drawWave(canvas, size, paint, amplitude: 15, speed: 2.0, yOffset: 60);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint,
      {double amplitude = 20, double speed = 1.0, double yOffset = 0}) {
    final path = Path();
    final double waveWidth = size.width;
    final double waveHeight = size.height;

    // Start from bottom-left
    path.moveTo(0, waveHeight);
    // Create a wave from left to right
    for (double x = 0; x <= waveWidth; x++) {
      double y = amplitude *
              math.sin((x / waveWidth * 2 * math.pi * speed) +
                  (waveValue * 2 * math.pi * speed)) +
          (waveHeight - 100 - yOffset);
      path.lineTo(x, y);
    }
    // Down to bottom-right corner
    path.lineTo(waveWidth, waveHeight);
    // Close the shape
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GreenWavePainter oldDelegate) => true;
}
