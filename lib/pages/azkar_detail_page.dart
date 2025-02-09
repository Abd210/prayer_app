import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azkar_model.dart';
import '../widgets/daily_azkar_tracker.dart';

class AzkarDetailPage extends StatefulWidget {
  final AzkarModel azkar;
  const AzkarDetailPage({Key? key, required this.azkar}) : super(key: key);

  @override
  State<AzkarDetailPage> createState() => _AzkarDetailPageState();
}

class _AzkarDetailPageState extends State<AzkarDetailPage> {
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _resetCounter() async {
    setState(() {
      widget.azkar.counter = 0;
    });
    await _prefs.setInt(widget.azkar.title, 0);
  }

  Future<void> _incrementCounter() async {
    setState(() {
      widget.azkar.counter++;
    });
    await _prefs.setInt(widget.azkar.title, widget.azkar.counter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.azkar.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Arabic text
            Text(
              widget.azkar.arabic,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            /// Transliteration
            Text(
              'Transliteration:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.azkar.transliteration,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            /// Translation
            Text(
              'Translation:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.azkar.translation,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            /// Reference
            Text(
              'Reference:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.azkar.reference,
              style: theme.textTheme.titleSmall?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),

            /// Counter & Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recitation Count: ${widget.azkar.counter}',
                  style: theme.textTheme.titleMedium,
                ),
                ElevatedButton(
                  onPressed: _resetCounter,
                  child: const Text('Reset Count'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// Increment counter button
            ElevatedButton.icon(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.add),
              label: const Text('Increment Count'),
            ),
            const SizedBox(height: 16),

            /// Daily tracker widget for this azkar
            DailyAzkarTracker(azkar: widget.azkar),
          ],
        ),
      ),
    );
  }
}
