import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:confetti/confetti.dart';

import 'package:prayer/models/azakdata.dart';
import 'package:prayer/widgets/animated_wave_background.dart';
import 'package:prayer/utils/azkar_storage.dart';

import 'package:prayer/generated/l10n/app_localizations.dart';

/* ────────────────────────────────────────────────────────────────────────────
   TASBIH PAGE - Clean & Modern Design
   ───────────────────────────────────────────────────────────────────────── */

class TasbihAdvancedPage extends StatefulWidget {
  const TasbihAdvancedPage({Key? key}) : super(key: key);

  @override
  State<TasbihAdvancedPage> createState() => _TasbihAdvancedPageState();
}

class _TasbihAdvancedPageState extends State<TasbihAdvancedPage> {
  /* ────────── counters ────────── */
  int _mainCount = 0;
  int _subhanallahCount = 0;
  int _alhamdulillahCount = 0;
  int _allahuAkbarCount = 0;
  

  final int _subTarget = 33;
  
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /* ────────── counter methods ────────── */
  void _incrementMain() {
    setState(() {
      _mainCount++;
    });
  }

  void _incrementSubhanallah() {
    setState(() {
      if (_subhanallahCount < _subTarget) {
        _subhanallahCount++;
        if (_subhanallahCount == _subTarget) {
          _confettiController.play();
        }
      }
    });
  }

  void _incrementAlhamdulillah() {
    setState(() {
      if (_alhamdulillahCount < _subTarget) {
        _alhamdulillahCount++;
        if (_alhamdulillahCount == _subTarget) {
          _confettiController.play();
        }
      }
    });
  }

  void _incrementAllahuAkbar() {
    setState(() {
      if (_allahuAkbarCount < _subTarget) {
        _allahuAkbarCount++;
        if (_allahuAkbarCount == _subTarget) {
          _confettiController.play();
        }
      }
    });
  }

  void _resetAll() {
    setState(() {
      _mainCount = 0;
      _subhanallahCount = 0;
      _alhamdulillahCount = 0;
      _allahuAkbarCount = 0;
    });
  }

  /* ────────── UI ────────── */
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Fill the whole screen with the animated background
          Positioned.fill(
            child: AnimatedWaveBackground(
              child: const SizedBox.expand(),
            ),
          ),
          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildMainCounter(theme),
                const SizedBox(height: 40),
                _buildSubCountersSection(theme),
                const SizedBox(height: 40),
                _buildResetButton(theme, loc),
              ],
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              shouldLoop: false,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                Colors.amber,
                Colors.teal,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCounter(ThemeData theme) {
    return GestureDetector(
      onTap: _incrementMain,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Main Counter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  '$_mainCount',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to count',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCountersSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Daily Dhikr',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildSubCounter(
                theme,
                'SubḥānAllāh',
                _subhanallahCount,
                _subTarget,
                theme.colorScheme.primary,
                _incrementSubhanallah,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSubCounter(
                theme,
                'Al-ḥamdu lillāh',
                _alhamdulillahCount,
                _subTarget,
                theme.colorScheme.secondary,
                _incrementAlhamdulillah,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSubCounter(
                theme,
                'Allāhu Akbar',
                _allahuAkbarCount,
                _subTarget,
                Colors.teal,
                _incrementAllahuAkbar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubCounter(
    ThemeData theme,
    String title,
    int count,
    int target,
    Color color,
    VoidCallback onTap,
  ) {
    final progress = (count / target).clamp(0.0, 1.0);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 35,
              lineWidth: 6,
              animation: true,
              animationDuration: 300,
              animateFromLastPercent: true,
              percent: progress,
              center: Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              progressColor: color,
              backgroundColor: color.withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '/ $target',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(ThemeData theme, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _resetAll,
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: Text(
          loc.resetAll,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }


}

/* ────────────────────────────────────────────────────────────────────────────
   AZKAR READING PAGE  (Persists progress + daily stats)
   ───────────────────────────────────────────────────────────────────────── */

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

  bool _compactView = false;
  bool _autoAdvance = true; // New: auto-advance toggle

  /* ──────────  INIT & DISPOSE  ────────── */

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    currentCounts = List.filled(widget.items.length, 0);
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));

    _restoreProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  /* ──────────  Progress Helpers  ────────── */

  Future<void> _restoreProgress() async {
    final saved = await AzkarStorage.loadProgress(widget.title);
    if (saved == null || !mounted) return;

    setState(() => currentCounts = saved.$2);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _pageController.jumpToPage(saved.$1));
  }

  Future<void> _persistProgress() async {
    await AzkarStorage.saveProgress(
      title: widget.title,
      pageIndex: _pageController.page?.round() ?? 0,
      counts: currentCounts,
    );
  }

  /* ──────────  Derived Getters  ────────── */

  int get completedItemsCount => currentCounts
      .asMap()
      .entries
      .where((e) => e.value >= widget.items[e.key].repeat)
      .length;

  double get overallFraction =>
      (completedItemsCount / widget.items.length).clamp(0.0, 1.0);

  /* ──────────  Logic  ────────── */

  void _incrementCount(int index) {
    setState(() {
      currentCounts[index]++;
    });
    _persistProgress();

    final required = widget.items[index].repeat;
    final count = currentCounts[index];
    if (_autoAdvance) {
      if (count == required) {
        if (index < widget.items.length - 1) {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut);
        } else {
          _confettiCtrl.play();
          AzkarStorage.markFinished(widget.title);
          AzkarStorage.clearProgress(widget.title);
          Future.delayed(const Duration(milliseconds: 1500), _showCompletionDialog);
        }
      }
    } else {
      // In manual mode, only show confetti and completion dialog on the last azkar
      if (count == required && index == widget.items.length - 1) {
        _confettiCtrl.play();
        AzkarStorage.markFinished(widget.title);
        AzkarStorage.clearProgress(widget.title);
        Future.delayed(const Duration(milliseconds: 1500), _showCompletionDialog);
      }
    }
  }

  void _showCompletionDialog() async {
    final loc = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.azkarCompletedTitle(widget.title)),
        content: Text(loc.azkarCompletedContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.ok)),
        ],
      ),
    );
    Navigator.pop(context);
  }

  /* ──────────  Copy helper  ────────── */

  void _copyAzkarText(String text) {
    final loc = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.azkarCopied)));
  }

  /* ──────────  BUILD  ────────── */

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_list_outlined),
            onSelected: (value) {
              if (value == 'compact' || value == 'expanded') {
                setState(() => _compactView = (value == 'compact'));
              } else if (value == 'auto') {
                setState(() => _autoAdvance = true);
              } else if (value == 'manual') {
                setState(() => _autoAdvance = false);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'compact', child: Text(loc.compactView)),
              PopupMenuItem(value: 'expanded', child: Text(loc.expandedView)),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'auto',
                child: Row(
                  children: [
                    Icon(_autoAdvance ? Icons.check : null, size: 18),
                    const SizedBox(width: 8),
                    Text('Auto Next'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'manual',
                child: Row(
                  children: [
                    Icon(!_autoAdvance ? Icons.check : null, size: 18),
                    const SizedBox(width: 8),
                    Text('Manual Next'),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          AnimatedWaveBackground(
            child: Column(
              children: [
                LinearPercentIndicator(
                  lineHeight: 6,
                  animation: true,
                  animationDuration: 300,
                  animateFromLastPercent: true,
                  percent: overallFraction,
                  progressColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  padding: EdgeInsets.zero,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (_) => _persistProgress(),
                    itemCount: widget.items.length,
                    itemBuilder: (_, index) {
                      final item = widget.items[index];
                      final count = currentCounts[index];
                      final required = item.repeat;
                      final fraction = (count / required).clamp(0.0, 1.0);

                      return GestureDetector(
                        onTap: () => _incrementCount(index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding:
                              EdgeInsets.all(_compactView ? 8.0 : 16.0),
                          child: Center(
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
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
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          item.arabic,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                _compactView ? 18 : 20,
                                            height: 1.6,
                                            color:
                                                theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item.translation,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontSize:
                                              _compactView ? 14 : 15,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      CircularPercentIndicator(
                                        radius:
                                            _compactView ? 50 : 60,
                                        lineWidth:
                                            _compactView ? 6 : 8,
                                        animation: true,
                                        animationDuration: 300,
                                        animateFromLastPercent: true,
                                        percent: fraction,
                                        center: Text(
                                          '$count / $required',
                                          style: TextStyle(
                                            fontSize: _compactView
                                                ? 16
                                                : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        progressColor:
                                            theme.colorScheme.primary,
                                        backgroundColor: theme
                                            .colorScheme.primary
                                            .withOpacity(0.2),
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                      ),
                                      const SizedBox(height: 10),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _copyAzkarText(item.arabic),
                                        icon: const Icon(Icons.copy),
                                        label: Text(loc.azkarCopy),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(loc.tapAnywhere,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                      const SizedBox(height: 10),
                                      if (!_compactView)
                                        Text(
                                          loc.azkarReminder,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey),
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
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              shouldLoop: false,
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
