import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:prayer/models/azakdata.dart';
import 'package:prayer/widgets/animated_wave_background.dart'; // Example data import

///
/// TASBIH ADVANCED PAGE (with sub counters)
///
class TasbihAdvancedPage extends StatefulWidget {
  const TasbihAdvancedPage({Key? key}) : super(key: key);

  @override
  State<TasbihAdvancedPage> createState() => _TasbihAdvancedPageState();
}

class _TasbihAdvancedPageState extends State<TasbihAdvancedPage> {
  // Main “global” tasbih
  int globalCount = 0;
  final int globalTarget = 99; // for example

  // Additional counters
  int countSubhanallah = 0;
  int countAlhamdulillah = 0;
  int countAllahuAkbar = 0;
  final int eachTarget = 33; // typical tasbih counts

  void _incrementGlobal() {
    setState(() {
      if (globalCount < globalTarget) {
        globalCount++;
      }
    });
  }

  void _incrementSubhanallah() {
    setState(() {
      if (countSubhanallah < eachTarget) {
        countSubhanallah++;
      }
    });
  }

  void _incrementAlhamdulillah() {
    setState(() {
      if (countAlhamdulillah < eachTarget) {
        countAlhamdulillah++;
      }
    });
  }

  void _incrementAllahuAkbar() {
    setState(() {
      if (countAllahuAkbar < eachTarget) {
        countAllahuAkbar++;
      }
    });
  }

  void _resetAll() {
    setState(() {
      globalCount = 0;
      countSubhanallah = 0;
      countAlhamdulillah = 0;
      countAllahuAkbar = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainFraction = (globalCount / globalTarget).clamp(0.0, 1.0);
    final subFraction1 = (countSubhanallah / eachTarget).clamp(0.0, 1.0);
    final subFraction2 = (countAlhamdulillah / eachTarget).clamp(0.0, 1.0);
    final subFraction3 = (countAllahuAkbar / eachTarget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih Advanced')),
      body: AnimatedWaveBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                //
                // ────────── Global Tasbih ──────────
                //
                const Text(
                  'Global Tasbih',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _incrementGlobal,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    height: 270,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularPercentIndicator(
                        radius: 80.0,
                        lineWidth: 12.0,
                        animation: true,
                        animationDuration: 300,
                        animateFromLastPercent: true,
                        percent: mainFraction,
                        center: Text(
                          '$globalCount / $globalTarget',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        progressColor: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.2),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //
                // ────────── Sub Counters ──────────
                //
                const Text(
                  'Sub-Counters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSmallTasbihBox(
                      context,
                      title: 'SubḥānAllāh',
                      count: countSubhanallah,
                      target: eachTarget,
                      fraction: subFraction1,
                      onTap: _incrementSubhanallah,
                    ),
                    _buildSmallTasbihBox(
                      context,
                      title: 'Al-ḥamdu lillāh',
                      count: countAlhamdulillah,
                      target: eachTarget,
                      fraction: subFraction2,
                      onTap: _incrementAlhamdulillah,
                    ),
                    _buildSmallTasbihBox(
                      context,
                      title: 'Allāhu Akbar',
                      count: countAllahuAkbar,
                      target: eachTarget,
                      fraction: subFraction3,
                      onTap: _incrementAllahuAkbar,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _resetAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Reset All',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tap the main box for a global count.\n'
                  'Tap any sub box for specific counts (33 each).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallTasbihBox(
    BuildContext context, {
    required String title,
    required int count,
    required int target,
    required double fraction,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 110,
        height: 140,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 32.0,
              lineWidth: 6.0,
              animation: true,
              animationDuration: 300,
              animateFromLastPercent: true,
              percent: fraction,
              center: Text(
                '$count',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              progressColor: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///
/// AZKAR READING PAGE
///
class AzkarReadingPage extends StatefulWidget {
  final String title;
  final List<DhikrItem> items;

  const AzkarReadingPage({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  State<AzkarReadingPage> createState() => _AzkarReadingPageState();
}

class _AzkarReadingPageState extends State<AzkarReadingPage> {
  late PageController _pageController;
  late List<int> currentCounts;
  late ConfettiController _confettiCtrl;

  bool _compactView = false; // toggles card spacing / style

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    currentCounts = List.filled(widget.items.length, 0);
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  int get completedItemsCount {
    int c = 0;
    for (int i = 0; i < widget.items.length; i++) {
      if (currentCounts[i] == widget.items[i].repeat) {
        c++;
      }
    }
    return c;
  }

  double get overallFraction {
    return (completedItemsCount / widget.items.length).clamp(0.0, 1.0);
  }

  void _incrementCount(int index) {
    setState(() {
      if (currentCounts[index] < widget.items[index].repeat) {
        currentCounts[index]++;
      }
      if (currentCounts[index] == widget.items[index].repeat) {
        // If finished this dhikr
        if (index < widget.items.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          // last one
          _confettiCtrl.play();
          Future.delayed(const Duration(milliseconds: 1500), () {
            _showCompletionDialog();
          });
        }
      }
    });
  }

  void _showCompletionDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${widget.title} Completed!'),
        content: const Text('You have finished all azkār in this category.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    Navigator.pop(context);
  }

  // Copy to clipboard logic
  void _copyAzkarText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Azkar text copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _compactView = (value == 'Compact'));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Compact',
                child: Text('Compact View'),
              ),
              const PopupMenuItem(
                value: 'Expanded',
                child: Text('Expanded View'),
              ),
            ],
            icon: const Icon(Icons.view_list_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Wave background (adapted to theme)
          AnimatedWaveBackground(
            child: Column(
              children: [
                // Top linear progress
                LinearPercentIndicator(
                  lineHeight: 6.0,
                  animation: true,
                  animationDuration: 300,
                  animateFromLastPercent: true,
                  percent: overallFraction,
                  progressColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  padding: EdgeInsets.zero,
                ),
                // Main content: PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final count = currentCounts[index];
                      final required = item.repeat;
                      final fraction = (count / required).clamp(0.0, 1.0);

                      return GestureDetector(
                        onTap: () => _incrementCount(index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.all(_compactView ? 8.0 : 16.0),
                          child: Center(
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: _compactView ? 16 : 20,
                                  vertical: _compactView ? 20 : 30,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Arabic text
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          item.arabic,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _compactView ? 18 : 20,
                                            height: 1.6,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // translation or short note
                                      Text(
                                        item.translation,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontSize: _compactView ? 14 : 15,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // circular progress
                                      CircularPercentIndicator(
                                        radius: _compactView ? 50 : 60,
                                        lineWidth: _compactView ? 6 : 8,
                                        animation: true,
                                        animationDuration: 300,
                                        animateFromLastPercent: true,
                                        percent: fraction,
                                        center: Text(
                                          '$count / $required',
                                          style: TextStyle(
                                            fontSize: _compactView ? 16 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        progressColor: theme.colorScheme.primary,
                                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                        circularStrokeCap: CircularStrokeCap.round,
                                      ),
                                      const SizedBox(height: 10),
                                      // Copy to clipboard button
                                      TextButton.icon(
                                        onPressed: () => _copyAzkarText(item.arabic),
                                        icon: const Icon(Icons.copy),
                                        label: const Text('Copy'),
                                      ),
                                      const SizedBox(height: 8),
                                      // A small reminder
                                      const Text(
                                        'Tap Anywhere to Count',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (!_compactView)
                                        const Text(
                                          'Remembrance of Allah is the greatest (Qur\'an 29:45).',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange
              ],
            ),
          ),
        ],
      ),
    );
  }
}
