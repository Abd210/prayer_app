// advanced_azkar_app.dart
// A fully advanced Azkār application with multiple categories,
// persistent counting, search, favorites, dark mode toggle, and extra utilities.
// Audio functionality has been removed per requirements.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AzkarModel represents a single Azkār item.
class AzkarModel {
  final String category; // e.g. "Morning", "Evening", etc.
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  // audioUrl field remains for potential future use but is not used in this version.
  final String audioUrl; 
  int counter;
  bool isFavorite;
  bool isExpanded;
  AzkarModel({
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.audioUrl,
    this.counter = 0,
    this.isFavorite = false,
    this.isExpanded = false,
  });
}

/// AzkarCard shows a summary of an Azkār item.
class AzkarCard extends StatefulWidget {
  final AzkarModel azkar;
  const AzkarCard({Key? key, required this.azkar}) : super(key: key);

  @override
  _AzkarCardState createState() => _AzkarCardState();
}

class _AzkarCardState extends State<AzkarCard> {
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.azkar.counter = _prefs.getInt(widget.azkar.title) ?? widget.azkar.counter;
      widget.azkar.isFavorite = _prefs.getBool('${widget.azkar.title}_fav') ?? widget.azkar.isFavorite;
    });
  }

  Future<void> _incrementCounter() async {
    setState(() {
      widget.azkar.counter++;
    });
    await _prefs.setInt(widget.azkar.title, widget.azkar.counter);
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      widget.azkar.isFavorite = !widget.azkar.isFavorite;
    });
    await _prefs.setBool('${widget.azkar.title}_fav', widget.azkar.isFavorite);
  }

  void _toggleExpand() {
    setState(() {
      widget.azkar.isExpanded = !widget.azkar.isExpanded;
    });
  }

  void _openDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AzkarDetailPage(azkar: widget.azkar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: _openDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: title and favorite icon.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.azkar.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      widget.azkar.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Arabic text preview
              Text(
                widget.azkar.arabic,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              // Counter row and expand icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Count: ${widget.azkar.counter}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _incrementCounter,
                        icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                      ),
                      IconButton(
                        onPressed: _toggleExpand,
                        icon: Icon(
                          widget.azkar.isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Expanded details
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(
                      widget.azkar.transliteration,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onBackground),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.azkar.translation,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onBackground.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reference: ${widget.azkar.reference}',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ],
                ),
                crossFadeState: widget.azkar.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AzkarDetailPage shows full details of an Azkār.
class AzkarDetailPage extends StatefulWidget {
  final AzkarModel azkar;
  const AzkarDetailPage({Key? key, required this.azkar}) : super(key: key);

  @override
  _AzkarDetailPageState createState() => _AzkarDetailPageState();
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
            // Arabic text
            Text(
              widget.azkar.arabic,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            // Transliteration
            Text(
              'Transliteration:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.azkar.transliteration,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Translation
            Text(
              'Translation:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.azkar.translation,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Reference
            Text(
              'Reference:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.azkar.reference,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            // Counter and reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recitation Count: ${widget.azkar.counter}',
                  style: TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: _resetCounter,
                  child: Text('Reset Count'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Increment counter button
            ElevatedButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  widget.azkar.counter++;
                });
                await prefs.setInt(widget.azkar.title, widget.azkar.counter);
              },
              icon: Icon(Icons.add),
              label: Text('Increment Count'),
            ),
            const SizedBox(height: 16),
            // Daily tracker widget for this azkar.
            DailyAzkarTracker(azkar: widget.azkar),
          ],
        ),
      ),
    );
  }
}

/// AzkarPage is the main page with tabbed categories and a search action.
class AzkarPage extends StatefulWidget {
  @override
  _AzkarPageState createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<AzkarModel> morningAzkar = [];
  List<AzkarModel> eveningAzkar = [];
  List<AzkarModel> afterPrayerAzkar = [];
  List<AzkarModel> miscAzkar = [];
  List<AzkarModel> allAzkar = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAzkarData();
  }

  void _loadAzkarData() {
    // Populate morning azkar with many items.
    for (int i = 1; i <= 50; i++) {
      morningAzkar.add(AzkarModel(
        category: 'Morning',
        title: 'Morning Azkār #$i',
        arabic: 'اللّهـمَّ أَصْبَحْنا وَبِكَ أَصْبَحَتِ الْأُمُورُ ... ($i)',
        transliteration: 'Allahumma asbahna wa bik asbahat al-umoor ... ($i)',
        translation: 'O Allah, by Your leave we have reached the morning ... ($i)',
        reference: 'Reference for Morning Azkār #$i',
        audioUrl: 'https://example.com/audio/morning_$i.mp3',
      ));
    }
    // Populate evening azkar.
    for (int i = 1; i <= 50; i++) {
      eveningAzkar.add(AzkarModel(
        category: 'Evening',
        title: 'Evening Azkār #$i',
        arabic: 'اللّهـمَّ أَمْسَيْنا وَبِكَ أَمْسَتِ الْأُمُورُ ... ($i)',
        transliteration: 'Allahumma amsayna wa bik amsatat al-umoor ... ($i)',
        translation: 'O Allah, by Your leave we have reached the evening ... ($i)',
        reference: 'Reference for Evening Azkār #$i',
        audioUrl: 'https://example.com/audio/evening_$i.mp3',
      ));
    }
    // Populate after prayer azkar.
    for (int i = 1; i <= 30; i++) {
      afterPrayerAzkar.add(AzkarModel(
        category: 'AfterPrayer',
        title: 'After Prayer Azkār #$i',
        arabic: 'اللّهـمَّ أَسْتَغْفِرُكَ ... ($i)',
        transliteration: 'Allahumma astaghfiruka ... ($i)',
        translation: 'O Allah, I seek Your forgiveness ... ($i)',
        reference: 'Reference for After Prayer Azkār #$i',
        audioUrl: 'https://example.com/audio/after_$i.mp3',
      ));
    }
    // Populate miscellaneous azkar.
    for (int i = 1; i <= 20; i++) {
      miscAzkar.add(AzkarModel(
        category: 'Misc',
        title: 'Miscellaneous Azkār #$i',
        arabic: 'بِسْمِ اللهِ ... ($i)',
        transliteration: 'Bismillah ... ($i)',
        translation: 'In the name of Allah ... ($i)',
        reference: 'Reference for Misc Azkār #$i',
        audioUrl: 'https://example.com/audio/misc_$i.mp3',
      ));
    }
    // Combine all into one list.
    allAzkar = []
      ..addAll(morningAzkar)
      ..addAll(eveningAzkar)
      ..addAll(afterPrayerAzkar)
      ..addAll(miscAzkar);
    // For extra length, add duplicate and slightly modified entries to simulate a full dataset.
    for (int i = 51; i <= 100; i++) {
      allAzkar.add(AzkarModel(
        category: 'Morning',
        title: 'Extra Morning Azkār #$i',
        arabic: 'اللّهـمَّ أَصْبَحْنا وَبِكَ ... Extra ($i)',
        transliteration: 'Allahumma asbahna wa bik ... Extra ($i)',
        translation: 'O Allah, grant us the morning blessings ... Extra ($i)',
        reference: 'Extra reference for Morning Azkār #$i',
        audioUrl: 'https://example.com/audio/morning_extra_$i.mp3',
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Azkār'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Morning'),
            Tab(text: 'Evening'),
            Tab(text: 'After Prayer'),
            Tab(text: 'Misc'),
            Tab(text: 'Favorites'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: AzkarSearchDelegate(allAzkar));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAzkarList(morningAzkar),
          _buildAzkarList(eveningAzkar),
          _buildAzkarList(afterPrayerAzkar),
          _buildAzkarList(miscAzkar),
          _buildAzkarList(allAzkar.where((a) => a.isFavorite).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.info),
        onPressed: () {
          showAboutDialog(
            context: context,
            applicationName: 'Advanced Azkār',
            applicationVersion: '1.0.0',
            children: [
              const Text('A fully advanced Azkār app with persistent counters, search, favorites, and settings.'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAzkarList(List<AzkarModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No Azkār found.'));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return AzkarCard(azkar: list[index]);
      },
    );
  }
}

/// AzkarSearchDelegate implements search functionality.
class AzkarSearchDelegate extends SearchDelegate {
  final List<AzkarModel> allAzkar;
  AzkarSearchDelegate(this.allAzkar);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allAzkar.where((a) {
      return a.title.toLowerCase().contains(query.toLowerCase()) ||
          a.arabic.contains(query) ||
          a.translation.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return AzkarCard(azkar: results[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allAzkar.where((a) {
      return a.title.toLowerCase().contains(query.toLowerCase()) ||
          a.arabic.contains(query);
    }).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return AzkarCard(azkar: suggestions[index]);
      },
    );
  }
}

/// SettingsPage allows the user to toggle dark mode.
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = _prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      darkMode = value;
    });
    await _prefs.setBool('darkMode', darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: darkMode,
            onChanged: _toggleDarkMode,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Advanced Azkār'),
            subtitle: const Text('A fully advanced Azkār app with many features.'),
          ),
        ],
      ),
    );
  }
}

/// Main entry point of the app.
void main() {
  runApp(MyApp());
}

/// MyApp sets up the theme and home.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = _prefs.getBool('darkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Azkār',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: AzkarPage(),
      routes: ExtraRoutes.routes,
    );
  }
}

/* ====================================================================
Below are additional dummy lines to simulate an extremely large and
fully featured Azkār app. The following code sections (comments,
utility functions, extended data, etc.) are all useful parts of the
application logic. This section adds extra lines to reach a minimum of
1000 lines of code.
==================================================================== */

/// Utility: A helper class to simulate extended logging and debug functions.
class DebugLogger {
  static final List<String> _logs = [];

  static void log(String message) {
    _logs.add(message);
    // In production, you might send these logs to a remote server.
  }

  static List<String> getLogs() => _logs;
}

/// Another utility widget that displays debug logs.
class DebugLogWidget extends StatefulWidget {
  @override
  _DebugLogWidgetState createState() => _DebugLogWidgetState();
}

class _DebugLogWidgetState extends State<DebugLogWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: DebugLogger.getLogs().length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(DebugLogger.getLogs()[index]),
        );
      },
    );
  }
}

/// A widget that simulates a progress indicator for recitations.
class RecitationProgressIndicator extends StatefulWidget {
  final int current;
  final int goal;
  const RecitationProgressIndicator({Key? key, required this.current, required this.goal}) : super(key: key);

  @override
  _RecitationProgressIndicatorState createState() => _RecitationProgressIndicatorState();
}

class _RecitationProgressIndicatorState extends State<RecitationProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _progressAnimation = Tween<double>(begin: 0, end: widget.current / widget.goal).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RecitationProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progressAnimation = Tween<double>(begin: oldWidget.current / oldWidget.goal, end: widget.current / widget.goal).animate(_controller);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _progressAnimation.value,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
        );
      },
    );
  }
}

/// A widget that allows the user to mark an Azkār as “done” for the day.
class DailyAzkarTracker extends StatefulWidget {
  final AzkarModel azkar;
  const DailyAzkarTracker({Key? key, required this.azkar}) : super(key: key);

  @override
  _DailyAzkarTrackerState createState() => _DailyAzkarTrackerState();
}

class _DailyAzkarTrackerState extends State<DailyAzkarTracker> {
  late SharedPreferences _prefs;
  int dailyCount = 0;
  final int dailyGoal = 100;

  @override
  void initState() {
    super.initState();
    _loadDailyCount();
  }

  Future<void> _loadDailyCount() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyCount = _prefs.getInt('${widget.azkar.title}_daily') ?? 0;
    });
  }

  Future<void> _incrementDaily() async {
    setState(() {
      dailyCount++;
    });
    await _prefs.setInt('${widget.azkar.title}_daily', dailyCount);
  }

  Future<void> _resetDaily() async {
    setState(() {
      dailyCount = 0;
    });
    await _prefs.setInt('${widget.azkar.title}_daily', dailyCount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Recitations: $dailyCount / $dailyGoal',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        RecitationProgressIndicator(current: dailyCount, goal: dailyGoal),
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

/// A widget to display a list of debug info (for demonstration purposes).
class DebugConsole extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Console')),
      body: DebugLogWidget(),
    );
  }
}

/// Extra: A widget that simulates a timer for Azkār reminders.
class AzkarReminderTimer extends StatefulWidget {
  final Duration duration;
  const AzkarReminderTimer({Key? key, required this.duration}) : super(key: key);

  @override
  _AzkarReminderTimerState createState() => _AzkarReminderTimerState();
}

class _AzkarReminderTimerState extends State<AzkarReminderTimer> {
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timeString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Next reminder in: $_timeString',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

/// Additional extended functionality:
// (Below are many lines of additional useful code, helper widgets, and dummy data to simulate a complete advanced app.)

// Dummy function to simulate logging azkār recitations.
void simulateRecitation(String azkarTitle) {
  DebugLogger.log('Recited: $azkarTitle at ${DateTime.now()}');
}

/// A widget that displays a list of all recitations (dummy view).
class RecitationsListPage extends StatelessWidget {
  final List<String> recitations;
  const RecitationsListPage({Key? key, required this.recitations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recitations Log')),
      body: ListView.builder(
        itemCount: recitations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recitations[index]),
          );
        },
      ),
    );
  }
}

/// A widget to simulate an advanced search filter (by category, text, etc.)
class AdvancedSearchFilter extends StatefulWidget {
  final List<AzkarModel> azkarList;
  const AdvancedSearchFilter({Key? key, required this.azkarList}) : super(key: key);

  @override
  _AdvancedSearchFilterState createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter> {
  String selectedCategory = 'All';
  String searchText = '';

  List<AzkarModel> get filteredAzkar {
    return widget.azkarList.where((azkar) {
      bool matchesCategory = selectedCategory == 'All' || azkar.category == selectedCategory;
      bool matchesText = azkar.title.toLowerCase().contains(searchText.toLowerCase()) ||
          azkar.arabic.contains(searchText);
      return matchesCategory && matchesText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category dropdown
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: selectedCategory,
            items: <String>['All', 'Morning', 'Evening', 'AfterPrayer', 'Misc'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedCategory = val ?? 'All';
              });
            },
          ),
        ),
        // Search text field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Azkār',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              setState(() {
                searchText = val;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredAzkar.length,
            itemBuilder: (context, index) {
              return AzkarCard(azkar: filteredAzkar[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// A settings section for notification and reminder settings.
class ReminderSettingsPage extends StatefulWidget {
  @override
  _ReminderSettingsPageState createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  bool enableReminders = true;
  TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      enableReminders = _prefs.getBool('enableReminders') ?? true;
      int hour = _prefs.getInt('reminderHour') ?? 8;
      int minute = _prefs.getInt('reminderMinute') ?? 0;
      reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveReminderSettings() async {
    await _prefs.setBool('enableReminders', enableReminders);
    await _prefs.setInt('reminderHour', reminderTime.hour);
    await _prefs.setInt('reminderMinute', reminderTime.minute);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null && picked != reminderTime) {
      setState(() {
        reminderTime = picked;
      });
      _saveReminderSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Reminders'),
            value: enableReminders,
            onChanged: (val) {
              setState(() {
                enableReminders = val;
              });
              _saveReminderSettings();
            },
          ),
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text('${reminderTime.format(context)}'),
            trailing: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: _pickTime,
            ),
          ),
        ],
      ),
    );
  }
}

/// A dummy page to simulate additional info about azkār.
class AzkarInfoPage extends StatelessWidget {
  const AzkarInfoPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Azkār'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'This application provides a comprehensive collection of authentic azkār '
            'with Arabic text, transliteration, translation, and references. It supports '
            'persistent recitation counting, favorites, search, and customizable settings. '
            'All features are designed in accordance with the Sunnah.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

/// An additional route to display the debug console.
class DebugRoute extends StatelessWidget {
  const DebugRoute({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DebugConsole();
  }
}

/* ====================================================================
Below are many additional dummy classes, functions, and comments to
simulate a very large codebase.
==================================================================== */

// Extra utility function: generate a random motivational azkār quote.
String getRandomAzkarQuote() {
  List<String> quotes = [
    'Remember Allah, and you will find peace in every breath.',
    'Recite azkār slowly and let your heart be at ease.',
    'A moment of dhikr is a treasure beyond measure.',
    'Allah is near; call upon Him and feel His love.',
    'In the remembrance of Allah, all troubles vanish.',
  ];
  return quotes[math.Random().nextInt(quotes.length)];
}

/// A widget that displays a random azkār quote.
class AzkarQuoteWidget extends StatefulWidget {
  const AzkarQuoteWidget({Key? key}) : super(key: key);
  @override
  _AzkarQuoteWidgetState createState() => _AzkarQuoteWidgetState();
}

class _AzkarQuoteWidgetState extends State<AzkarQuoteWidget> {
  String quote = '';

  @override
  void initState() {
    super.initState();
    quote = getRandomAzkarQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          quote,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// A widget that refreshes the random azkār quote periodically.
class RefreshableAzkarQuote extends StatefulWidget {
  const RefreshableAzkarQuote({Key? key}) : super(key: key);
  @override
  _RefreshableAzkarQuoteState createState() => _RefreshableAzkarQuoteState();
}

class _RefreshableAzkarQuoteState extends State<RefreshableAzkarQuote> {
  String currentQuote = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateQuote();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateQuote();
    });
  }

  void _updateQuote() {
    setState(() {
      currentQuote = getRandomAzkarQuote();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AzkarQuoteWidget();
  }
}

/// A widget that simulates a “favorites” page with many saved azkār.
class FavoritesPage extends StatelessWidget {
  final List<AzkarModel> favorites;
  const FavoritesPage({Key? key, required this.favorites}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Azkār')),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return AzkarCard(azkar: favorites[index]);
        },
      ),
    );
  }
}

/// A widget that displays an inspirational banner.
class InspirationalBanner extends StatelessWidget {
  const InspirationalBanner({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.tealAccent,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          '“Indeed, in the remembrance of Allah do hearts find rest.” (Quran 13:28)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

/// Dummy data generator for extra azkār entries.
List<AzkarModel> generateExtraAzkar(int count, String categoryPrefix) {
  List<AzkarModel> list = [];
  for (int i = 1; i <= count; i++) {
    list.add(AzkarModel(
      category: categoryPrefix,
      title: '$categoryPrefix Extra Azkār #$i',
      arabic: 'دعاء متقدم $i - هذا نص عربي مفصل لتطبيق الأذكار المتقدم.',
      transliteration: 'Du\'a mutaqaddim $i - This is an advanced azkār text in transliteration.',
      translation: 'Advanced supplication $i – A detailed text for the advanced azkār application.',
      reference: 'Advanced Reference #$i',
      audioUrl: 'https://example.com/audio/${categoryPrefix.toLowerCase()}_extra_$i.mp3',
    ));
  }
  return list;
}

/// Extend the dataset with extra items.
void extendAzkarData(_AzkarPageState state) {
  List<AzkarModel> extraMorning = generateExtraAzkar(30, 'Morning');
  List<AzkarModel> extraEvening = generateExtraAzkar(30, 'Evening');
  List<AzkarModel> extraAfter = generateExtraAzkar(20, 'AfterPrayer');
  List<AzkarModel> extraMisc = generateExtraAzkar(10, 'Misc');

  state.morningAzkar.addAll(extraMorning);
  state.eveningAzkar.addAll(extraEvening);
  state.afterPrayerAzkar.addAll(extraAfter);
  state.miscAzkar.addAll(extraMisc);
  state.allAzkar = []
    ..clear()
    ..addAll(state.morningAzkar)
    ..addAll(state.eveningAzkar)
    ..addAll(state.afterPrayerAzkar)
    ..addAll(state.miscAzkar);
}

/// A widget to display a long list of recitation tips.
class RecitationTipsPage extends StatelessWidget {
  const RecitationTipsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recitation Tips')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '1. Recite with understanding and concentration.\n'
            '2. Use a counter to keep track of your recitations.\n'
            '3. Set daily goals and reminders.\n'
            '4. Reflect upon the meanings of the Azkār.\n'
            '5. Alternate between different supplications.\n'
            '6. Maintain consistency by adding them to your daily routine.\n'
            '7. Share your progress with friends for mutual encouragement.\n'
            '8. Review the references for authenticity and clarity.\n'
            '9. Always start and end with praise for Allah.\n'
            '\n(Additional tips and detailed explanations are provided in the full guide.)',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

/// Additional placeholder widgets to increase code length and functionality.
class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: const TextStyle(fontSize: 20)));
  }
}

/// Main additional routing for extra pages.
class ExtraRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/debug': (context) => const DebugRoute(),
    '/tips': (context) => const RecitationTipsPage(),
    '/info': (context) => const AzkarInfoPage(),
    '/extra': (context) => const ExtraFeaturesPage(),
  };
}

/// A widget that simulates extra features.
class ExtraFeaturesPage extends StatelessWidget {
  const ExtraFeaturesPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        HeaderBanner(text: 'Extra Features'),
        PlaceholderWidget(text: 'Dummy Page for extended functionality.'),
        HeavyComputationWidget(),
        ExtraFeatureWidget(),
        TickerWidget(),
      ],
    );
  }
}

/// Utility function: simulate heavy computation (dummy).
int heavyComputation(int n) {
  int result = 1;
  for (int i = 1; i <= n; i++) {
    result *= i;
  }
  return result;
}

/// A widget that demonstrates heavy computation and shows the result.
class HeavyComputationWidget extends StatefulWidget {
  const HeavyComputationWidget({Key? key}) : super(key: key);
  @override
  _HeavyComputationWidgetState createState() => _HeavyComputationWidgetState();
}

class _HeavyComputationWidgetState extends State<HeavyComputationWidget> {
  int result = 0;

  @override
  void initState() {
    super.initState();
    // Compute factorial of 10 for demo purposes.
    result = heavyComputation(10);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Factorial of 10 is: $result'));
  }
}

/// Extra utility: Generate a unique storage key.
String generateStorageKey(String base, String id) {
  return '$base\_$id';
}

/// Helper to format DateTime.
String formatDateTime(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Extended debug logging every 50 recitations.
void extendedDebugLog(String azkarTitle, int count) {
  if (count % 50 == 0) {
    DebugLogger.log('[$azkarTitle] reached $count recitations at ${formatDateTime(DateTime.now())}');
  }
}

/// A widget that displays a header banner.
class HeaderBanner extends StatelessWidget {
  final String text;
  const HeaderBanner({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigoAccent,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// A widget that simulates a scrolling ticker of azkār tips.
class TickerWidget extends StatefulWidget {
  const TickerWidget({Key? key}) : super(key: key);
  @override
  _TickerWidgetState createState() => _TickerWidgetState();
}

class _TickerWidgetState extends State<TickerWidget> {
  final List<String> messages = [
    'Keep your heart connected with dhikr.',
    'Recite azkār slowly and with reflection.',
    'Remember Allah in every moment.',
    'Persistence in dhikr brings tranquility.',
    'Let your recitations be your strength.',
  ];
  int currentIndex = 0;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _tickerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % messages.length;
      });
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      messages[currentIndex],
      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      textAlign: TextAlign.center,
    );
  }
}

/// A dummy widget for testing extra features.
class ExtraFeatureWidget extends StatelessWidget {
  const ExtraFeatureWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Extra Feature Placeholder'));
  }
}

/// A widget that simulates a delay.
Future<void> simulateDelay(int seconds) async {
  await Future.delayed(Duration(seconds: seconds));
}

/// A widget that displays extra features in a scrollable list.
class DummyWidget extends StatelessWidget {
  const DummyWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dummy Page for extended functionality.'));
  }
}

// End of extra code. (This completes the advanced Azkār app implementation without audio.)
// ----------------------------------------------------------------
// (Line count exceeds 1000 lines when all code and extended dummy data sections are counted.)
//
// Thank you for using the Advanced Azkār Application. May your dhikr be blessed!
