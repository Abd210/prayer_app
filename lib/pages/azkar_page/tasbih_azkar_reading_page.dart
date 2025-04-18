import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:confetti/confetti.dart';

import 'package:prayer/models/azakdata.dart';
import 'package:prayer/widgets/animated_wave_background.dart';
import 'package:prayer/utils/azkar_storage.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/* ────────────────────────────────────────────────────────────────────────────
   TASBIH ADVANCED PAGE
   ───────────────────────────────────────────────────────────────────────── */

class TasbihAdvancedPage extends StatefulWidget {
  const TasbihAdvancedPage({Key? key}) : super(key: key);

  @override
  State<TasbihAdvancedPage> createState() => _TasbihAdvancedPageState();
}

class _TasbihAdvancedPageState extends State<TasbihAdvancedPage> {
  /* ────────── counters ────────── */

  int globalCount = 0;
  final int globalTarget = 99;

  int countSubhanallah = 0;
  int countAlhamdulillah = 0;
  int countAllahuAkbar = 0;
  final int eachTarget = 33;

  void _incrementGlobal() =>
      setState(() => globalCount = (globalCount < globalTarget)
          ? globalCount + 1
          : globalCount);

  void _incrementSubhanallah() =>
      setState(() => countSubhanallah = (countSubhanallah < eachTarget)
          ? countSubhanallah + 1
          : countSubhanallah);

  void _incrementAlhamdulillah() =>
      setState(() => countAlhamdulillah = (countAlhamdulillah < eachTarget)
          ? countAlhamdulillah + 1
          : countAlhamdulillah);

  void _incrementAllahuAkbar() =>
      setState(() => countAllahuAkbar = (countAllahuAkbar < eachTarget)
          ? countAllahuAkbar + 1
          : countAllahuAkbar);

  void _resetAll() => setState(() {
        globalCount = 0;
        countSubhanallah = 0;
        countAlhamdulillah = 0;
        countAllahuAkbar = 0;
      });

  /* ────────── UI ────────── */

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final mainFraction = (globalCount / globalTarget).clamp(0.0, 1.0);
    final subFraction1 = (countSubhanallah / eachTarget).clamp(0.0, 1.0);
    final subFraction2 = (countAlhamdulillah / eachTarget).clamp(0.0, 1.0);
    final subFraction3 = (countAllahuAkbar / eachTarget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: Text(loc.tasbihTitle)),
      body: AnimatedWaveBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(loc.globalTasbih,
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                      radius: 80,
                      lineWidth: 12,
                      animation: true,
                      animationDuration: 300,
                      animateFromLastPercent: true,
                      percent: mainFraction,
                      center: Text('$globalCount / $globalTarget',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      progressColor: theme.colorScheme.primary,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(loc.subCounters,
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
                    title: 'Al‑ḥamdu lillāh',
                    count: countAlhamdulillah,
                    target: eachTarget,
                    fraction: subFraction2,
                    onTap: _incrementAlhamdulillah,
                  ),
                  _buildSmallTasbihBox(
                    context,
                    title: 'Allāhu Akbar',
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
                label: Text(loc.resetAll,
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.tasbihHint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* small sub‑counter box */
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
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 32,
              lineWidth: 6,
              animation: true,
              animationDuration: 300,
              animateFromLastPercent: true,
              percent: fraction,
              center: Text('$count',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              progressColor: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, height: 1.3)),
          ],
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
      .where((e) => e.value == widget.items[e.key].repeat)
      .length;

  double get overallFraction =>
      (completedItemsCount / widget.items.length).clamp(0.0, 1.0);

  /* ──────────  Logic  ────────── */

  void _incrementCount(int index) {
    setState(() {
      if (currentCounts[index] < widget.items[index].repeat) {
        currentCounts[index]++;
      }
    });

    _persistProgress();

    if (currentCounts[index] == widget.items[index].repeat) {
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
            onSelected: (value) =>
                setState(() => _compactView = (value == 'compact')),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'compact', child: Text(loc.compactView)),
              PopupMenuItem(value: 'expanded', child: Text(loc.expandedView)),
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
