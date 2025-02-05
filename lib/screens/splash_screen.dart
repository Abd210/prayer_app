import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'; // for ImageFilter

import 'package:flutter/material.dart';
import '../theme/theme_notifier.dart';
import 'main_screen.dart';

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
          // Wave layers
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
