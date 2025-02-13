import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({Key? key}) : super(key: key);

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _count = 0;
  late Timer _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _count++;
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  void _startAutoIncrement() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _count++;
      });
    });
  }

  void _stopAutoIncrement() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('About Tasbih'),
                    content: const Text(
                        'This is a simple Tasbih counter app. Tap on the screen to increment the count or press the reset button to start over.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap to Increase Count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _increment,
              onLongPress: _isRunning ? _stopAutoIncrement : _startAutoIncrement,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '$_count',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Counter'),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSecondary, backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopAutoIncrement : _startAutoIncrement,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: _isRunning ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isRunning ? 'Stop Auto Count' : 'Start Auto Count'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Press and hold to automatically increment the count.',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
