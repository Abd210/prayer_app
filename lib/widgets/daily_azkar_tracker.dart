import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azkar_model.dart';

class DailyAzkarTracker extends StatefulWidget {
  final AzkarModel azkar;
  const DailyAzkarTracker({Key? key, required this.azkar}) : super(key: key);

  @override
  State<DailyAzkarTracker> createState() => _DailyAzkarTrackerState();
}

class _DailyAzkarTrackerState extends State<DailyAzkarTracker>
    with SingleTickerProviderStateMixin {
  late SharedPreferences _prefs;
  int dailyCount = 0;
  final int dailyGoal = 100;

  late AnimationController _animController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(_animController);
    _loadDailyCount();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyCount() async {
    _prefs = await SharedPreferences.getInstance();
    final savedDaily = _prefs.getInt('${widget.azkar.title}_daily') ?? 0;
    setState(() {
      dailyCount = savedDaily;
    });
    _updateProgressAnimation(0, savedDaily / dailyGoal);
  }

  void _updateProgressAnimation(double from, double to) {
    _progressAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward(from: 0);
  }

  Future<void> _incrementDaily() async {
    final oldVal = dailyCount.toDouble();
    setState(() {
      dailyCount++;
    });
    await _prefs.setInt('${widget.azkar.title}_daily', dailyCount);
    _updateProgressAnimation(oldVal / dailyGoal, dailyCount / dailyGoal);
  }

  Future<void> _resetDaily() async {
    setState(() {
      dailyCount = 0;
    });
    await _prefs.setInt('${widget.azkar.title}_daily', 0);
    _updateProgressAnimation(_progressAnimation.value, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Recitations: $dailyCount / $dailyGoal'),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.secondary,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _incrementDaily,
              icon: const Icon(Icons.add),
              label: const Text('Recite Once'),
            ),
            ElevatedButton.icon(
              onPressed: _resetDaily,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Today'),
            ),
          ],
        ),
      ],
    );
  }
}
