import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that displays an animated wave background.
/// 
/// This widget can be used as a decorative background for various screens.
class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;
  
  /// Create an animated wave background
  /// 
  /// [child] is displayed on top of the animation
  const AnimatedWaveBackground({super.key, required this.child});

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _WavePainter(
              value: _ctrl.value,
              color: Theme.of(context).colorScheme.primary.withOpacity(.15)),
          child: widget.child,
        ),
      );
}

class _WavePainter extends CustomPainter {
  final double value;
  final Color color;
  
  const _WavePainter({required this.value, required this.color});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color;
    _wave(c, s, p, 18, 1.0, 0);
    _wave(c, s, p, 24, 1.4, 40);
    _wave(c, s, p, 16, 2.0, 70);
  }

  void _wave(Canvas c, Size s, Paint p, double amp, double speed, double off) {
    final path = Path()..moveTo(0, s.height);
    for (double x = 0; x <= s.width; x++) {
      final y = amp *
              math.sin((x / s.width * 2 * math.pi * speed) +
                  (value * 2 * math.pi * speed)) +
          (s.height - 120 - off);
      path.lineTo(x, y);
    }
    path
      ..lineTo(s.width, s.height)
      ..close();
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => true;
}
