import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({Key? key}) : super(key: key);

  @override
  QuranPageState createState() => QuranPageState();
}

class QuranPageState extends State<QuranPage> with TickerProviderStateMixin {
  /* ───────────────  STATE  ─────────────── */

  // loading / playback
  late bool isLoading, isPlaying, isPlayingWholeSurah;

  // audio
  late final AudioPlayer audioPlayer;
  late final StreamSubscription onCompleteSubscription;

  // data
  late final List<int> allJuzNumbers;
  late final List<int> allSurahNumbers;
  late List<int> surahsInJuz;
  late int currentJuz, currentSurah, verseCountForSurah, totalSurahCount;
  late int selectedJuzForSurahs, selectedSurahForVerses;

  // navigation flags
  late bool showSurahSelection, showVerseSelection;

  // full‑surah queue
  late int currentVerseInQueue;
  late bool entireSurahQueued;

  // scroll
  late final ScrollController scrollControllerJuz,
      scrollControllerSurah,
      scrollControllerVerse;

  // animations
  late final AnimationController juzAnimationController,
      surahAnimationController,
      verseAnimationController;
  late final Animation<double> juzAnimation,
      surahAnimation,
      verseAnimation;

  /* ───────────────  INIT  ─────────────── */

  @override
  void initState() {
    super.initState();

    isLoading = true;
    isPlaying = false;
    isPlayingWholeSurah = false;
    entireSurahQueued = false;

    // audio
    audioPlayer = AudioPlayer();
    onCompleteSubscription =
        audioPlayer.onPlayerComplete.listen((event) async {
      if (entireSurahQueued && currentVerseInQueue < verseCountForSurah) {
        currentVerseInQueue++;
        await playAudioQueueVerse();
      } else {
        isPlaying = isPlayingWholeSurah = entireSurahQueued = false;
        setState(() {});
      }
    });

    // data
    allJuzNumbers = List.generate(30, (i) => i + 1);
    allSurahNumbers =
        List.generate(quran.totalSurahCount, (i) => i + 1); // 1‑114
    totalSurahCount = quran.totalSurahCount;

    currentJuz = 1;
    currentSurah = 1;
    verseCountForSurah = quran.getVerseCount(currentSurah);
    selectedJuzForSurahs = 1;
    selectedSurahForVerses = 1;
    showSurahSelection = showVerseSelection = false;

    // scroll
    scrollControllerJuz = ScrollController();
    scrollControllerSurah = ScrollController();
    scrollControllerVerse = ScrollController();

    // animations
    juzAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    surahAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    verseAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    juzAnimation =
        CurvedAnimation(parent: juzAnimationController, curve: Curves.easeInOut);
    surahAnimation =
        CurvedAnimation(parent: surahAnimationController, curve: Curves.easeInOut);
    verseAnimation =
        CurvedAnimation(parent: verseAnimationController, curve: Curves.easeInOut);

    // tiny fake load
    Future.delayed(const Duration(milliseconds: 300), () {
      isLoading = false;
      setState(() {});
      juzAnimationController.forward();
    });
  }

  /* ───────────────  DISPOSE  ─────────────── */

  @override
  void dispose() {
    onCompleteSubscription.cancel();
    audioPlayer.dispose();

    scrollControllerJuz.dispose();
    scrollControllerSurah.dispose();
    scrollControllerVerse.dispose();

    juzAnimationController.dispose();
    surahAnimationController.dispose();
    verseAnimationController.dispose();
    super.dispose();
  }

  /* ───────────────  NAV HELPERS  ─────────────── */

  void selectJuz(int juzNumber) {
    currentJuz = juzNumber;
    surahsInJuz = [];

    final data = quran.getSurahAndVersesFromJuz(juzNumber);
    for (final e in data.entries) {
      surahsInJuz.add(e.key);
    }
    surahsInJuz = surahsInJuz.toSet().toList();

    selectedJuzForSurahs = juzNumber;
    showSurahSelection = true;
    showVerseSelection = false;

    surahAnimationController.reset();
    verseAnimationController.reset();
    surahAnimationController.forward();
    setState(() {});
  }

  void selectSurah(int surahNumber) {
    currentSurah = surahNumber;
    verseCountForSurah = quran.getVerseCount(surahNumber);
    selectedSurahForVerses = surahNumber;

    showVerseSelection = true;
    verseAnimationController.reset();
    verseAnimationController.forward();
    setState(() {});
  }

  /* ───────────────  AUDIO  ─────────────── */

  Future<void> playAudio(int surah, int ayah) async {
    final url = quran.getAudioURLByVerse(surah, ayah);
    await audioPlayer.play(UrlSource(url));
    isPlaying = true;
    setState(() {});
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
    isPlaying = isPlayingWholeSurah = false;
    setState(() {});
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    isPlaying = isPlayingWholeSurah = entireSurahQueued = false;
    setState(() {});
  }

  void playEntireSurah(int surahNumber) {
    currentSurah = surahNumber;
    verseCountForSurah = quran.getVerseCount(surahNumber);
    currentVerseInQueue = 1;

    entireSurahQueued = isPlayingWholeSurah = true;
    playAudioQueueVerse();
  }

  Future<void> playAudioQueueVerse() async {
    final url = quran.getAudioURLByVerse(currentSurah, currentVerseInQueue);
    await audioPlayer.play(UrlSource(url));
    isPlaying = true;
    setState(() {});
  }

  /* ───────────────  UI BUILD HELPERS  ─────────────── */

  Widget buildJuzList(BuildContext ctx) {
    final loc = AppLocalizations.of(ctx)!;
    return FadeTransition(
      opacity: juzAnimation,
      child: ListView.builder(
        controller: scrollControllerJuz,
        physics: const BouncingScrollPhysics(),
        itemCount: allJuzNumbers.length,
        itemBuilder: (_, i) {
          final n = allJuzNumbers[i];
          return GestureDetector(
            onTap: () => selectJuz(n),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(ctx).colorScheme.primary),
              ),
              child: ListTile(
                title: Text(loc.juzLabel(n),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: Theme.of(ctx).colorScheme.onBackground),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSurahListForJuz(BuildContext ctx) {
    final loc = AppLocalizations.of(ctx)!;
    return FadeTransition(
      opacity: surahAnimation,
      child: Column(
        children: [
          // header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(ctx).colorScheme.primary.withOpacity(.9),
                  Theme.of(ctx).colorScheme.secondary.withOpacity(.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories,
                    size: 28, color: Theme.of(ctx).colorScheme.onPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(loc.juzSurahHeader(selectedJuzForSurahs),
                      style: TextStyle(
                          color: Theme.of(ctx).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon:
                      Icon(Icons.close, color: Theme.of(ctx).colorScheme.onPrimary),
                  onPressed: () {
                    showSurahSelection = false;
                    showVerseSelection = false;
                    juzAnimationController
                      ..reset()
                      ..forward();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          // list
          Expanded(
            child: ListView.builder(
              controller: scrollControllerSurah,
              physics: const BouncingScrollPhysics(),
              itemCount: surahsInJuz.length,
              itemBuilder: (_, i) {
                final s = surahsInJuz[i];
                return GestureDetector(
                  onTap: () => selectSurah(s),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Theme.of(ctx).colorScheme.primary),
                    ),
                    child: ListTile(
                      title: Text(quran.getSurahName(s),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(loc.versesLabel(quran.getVerseCount(s)),
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(ctx).colorScheme.onBackground)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Theme.of(ctx).colorScheme.onBackground),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerseListForSurah(BuildContext ctx) {
    final loc = AppLocalizations.of(ctx)!;
    return FadeTransition(
      opacity: verseAnimation,
      child: Column(
        children: [
          // header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(ctx).colorScheme.primary.withOpacity(.9),
                  Theme.of(ctx).colorScheme.secondary.withOpacity(.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.library_books,
                    size: 28, color: Theme.of(ctx).colorScheme.onPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(quran.getSurahName(selectedSurahForVerses),
                      style: TextStyle(
                          color: Theme.of(ctx).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon:
                      Icon(Icons.close, color: Theme.of(ctx).colorScheme.onPrimary),
                  onPressed: () {
                    showVerseSelection = false;
                    surahAnimationController
                      ..reset()
                      ..forward();
                    setState(() {});
                  },
                )
              ],
            ),
          ),
          // play full surah
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Theme.of(ctx).colorScheme.secondary, width: 1),
            ),
            child: ListTile(
              title: Text(loc.playEntireSurah,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.play_arrow_rounded,
                  color: Theme.of(ctx).colorScheme.onBackground),
              onTap: () => playEntireSurah(selectedSurahForVerses),
            ),
          ),
          // verses
          Expanded(
            child: ListView.builder(
              controller: scrollControllerVerse,
              physics: const BouncingScrollPhysics(),
              itemCount: verseCountForSurah,
              itemBuilder: (_, i) {
                final v = i + 1;
                final txt = quran.getVerse(selectedSurahForVerses, v);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Theme.of(ctx).colorScheme.primary, width: .5),
                  ),
                  child: ListTile(
                    title: Text('$v. $txt',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    onTap: () => playAudio(selectedSurahForVerses, v),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAudioPlayerControls(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.primary.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () =>
              isPlaying ? pauseAudio() : playAudio(currentSurah, 1),
        ),
        IconButton(icon: const Icon(Icons.stop), onPressed: stopAudio),
      ]),
    );
  }

  /* ───────────────  MAIN BUILD  ─────────────── */

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.book, size: 28),
          const SizedBox(width: 8),
          Text(loc.quranTitle),
        ]),
        toolbarHeight: 80,
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => showSearch(
                  context: context, delegate: QuranSearchDelegate(loc))),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: SimpleQuranBackgroundPainter())),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(children: [
                Expanded(
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: !showSurahSelection
                            ? buildJuzList(context)
                            : !showVerseSelection
                                ? buildSurahListForJuz(context)
                                : buildVerseListForSurah(context))),
                buildAudioPlayerControls(context),
                const SizedBox(height: 8),
              ]),
      ]),
    );
  }
}

/* ───────────────  SIMPLE BG  ─────────────── */

class SimpleQuranBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final bg = Paint()..color = Colors.blueGrey.withOpacity(.03);
    c.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), bg);

    final circ = Paint()..color = Colors.blueGrey.withOpacity(.08);
    c.drawCircle(Offset(s.width * .2, s.height * .25), 80, circ);
    c.drawCircle(Offset(s.width * .8, s.height * .6), 100, circ);
  }

  @override
  bool shouldRepaint(_) => false;
}

/* ───────────────  SEARCH DELEGATE  ─────────────── */

class QuranSearchDelegate extends SearchDelegate {
  QuranSearchDelegate(this.loc);
  final AppLocalizations loc;

  @override
  String get searchFieldLabel => loc.searchHint;

  @override
  List<Widget>? buildActions(BuildContext ctx) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
      ];

  @override
  Widget? buildLeading(BuildContext ctx) => IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(ctx, null));

  @override
  Widget buildResults(BuildContext ctx) {
    final results = <Map<String, dynamic>>[];
    for (int s = 1; s <= quran.totalSurahCount; s++) {
      final vc = quran.getVerseCount(s);
      for (int v = 1; v <= vc; v++) {
        final txt = quran.getVerse(s, v);
        if (txt.toLowerCase().contains(query.toLowerCase())) {
          results.add({"surah": s, "verse": v, "text": txt});
        }
      }
    }

    if (results.isEmpty) {
      return Center(child: Text(loc.searchNoResults(query)));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final s = results[i]['surah'] as int;
        final v = results[i]['verse'] as int;
        final txt = results[i]['text'] as String;
        return ListTile(
          title: Text(loc.searchResultTitle(s, v)),
          subtitle: Text(txt),
          onTap: () => close(ctx, null),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext ctx) => query.isEmpty
      ? Center(child: Text(loc.searchPrompt))
      : Center(child: Text(loc.searchSuggestions(query)));
}
