import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quran/quran.dart' as quran;
import 'dart:math' as math;

class QuranPage extends StatefulWidget {
  const QuranPage({Key? key}) : super(key: key);

  @override
  QuranPageState createState() => QuranPageState();
}

class QuranPageState extends State<QuranPage> with TickerProviderStateMixin {
  // Loading and playback states
  late bool isLoading;
  late bool isPlaying;
  late bool isPlayingWholeSurah;

  // Audio
  late AudioPlayer audioPlayer;
  late StreamSubscription onCompleteSubscription;

  // Data
  late List<int> allJuzNumbers;
  late List<int> allSurahNumbers;
  late List<int> surahsInJuz;
  late int currentJuz;
  late int currentSurah;
  late int selectedJuzForSurahs;
  late int selectedSurahForVerses;
  late int verseCountForSurah;
  late int totalSurahCount;

  // Navigation booleans
  late bool showSurahSelection;
  late bool showVerseSelection;

  // Queue for entire surah playback
  late int currentVerseInQueue;
  late bool entireSurahQueued;

  // Scroll controllers
  late ScrollController scrollControllerJuz;
  late ScrollController scrollControllerSurah;
  late ScrollController scrollControllerVerse;

  // Animation controllers
  late AnimationController juzAnimationController;
  late AnimationController surahAnimationController;
  late AnimationController verseAnimationController;
  late Animation<double> juzAnimation;
  late Animation<double> surahAnimation;
  late Animation<double> verseAnimation;

  @override
  void initState() {
    super.initState();

    isLoading = true;
    isPlaying = false;
    isPlayingWholeSurah = false;
    entireSurahQueued = false;

    // Audio setup
    audioPlayer = AudioPlayer();
    onCompleteSubscription = audioPlayer.onPlayerComplete.listen((event) {
      // If we're playing an entire surah, move to the next verse automatically
      if (entireSurahQueued && currentVerseInQueue < verseCountForSurah) {
        currentVerseInQueue++;
        playAudioQueueVerse();
      } else {
        // End of surah or single verse finished
        isPlaying = false;
        isPlayingWholeSurah = false;
        entireSurahQueued = false;
        setState(() {});
      }
    });

    // Data setup
    allJuzNumbers = List.generate(30, (index) => index + 1);
    allSurahNumbers = List.generate(quran.totalSurahCount, (index) => index + 1);
    totalSurahCount = quran.totalSurahCount;

    // Default states
    currentJuz = 1;
    currentSurah = 1;
    verseCountForSurah = quran.getVerseCount(currentSurah);
    showSurahSelection = false;
    showVerseSelection = false;
    selectedJuzForSurahs = 1;
    selectedSurahForVerses = 1;

    // Scroll controllers
    scrollControllerJuz = ScrollController();
    scrollControllerSurah = ScrollController();
    scrollControllerVerse = ScrollController();

    // Animation controllers
    juzAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    surahAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    verseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Animations
    juzAnimation = CurvedAnimation(
      parent: juzAnimationController,
      curve: Curves.easeInOut,
    );
    surahAnimation = CurvedAnimation(
      parent: surahAnimationController,
      curve: Curves.easeInOut,
    );
    verseAnimation = CurvedAnimation(
      parent: verseAnimationController,
      curve: Curves.easeInOut,
    );

    // Simulate a brief loading
    Future.delayed(const Duration(milliseconds: 300), () {
      isLoading = false;
      setState(() {});
      juzAnimationController.forward();
    });
  }

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

  // ---------------------- Navigation Helpers ----------------------

  void selectJuz(int juzNumber) {
    currentJuz = juzNumber;
    surahsInJuz = [];

    // Retrieve the surah-to-verse mapping from the quran package
    var data = quran.getSurahAndVersesFromJuz(juzNumber);
    for (var entry in data.entries) {
      surahsInJuz.add(entry.key);
    }

    // Remove duplicates
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

  // ---------------------- Audio Playback ----------------------

  Future<void> playAudio(int surah, int ayah) async {
    String url = quran.getAudioURLByVerse(surah, ayah);
    await audioPlayer.play(UrlSource(url));
    isPlaying = true;
    setState(() {});
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
    isPlaying = false;
    isPlayingWholeSurah = false;
    setState(() {});
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    isPlaying = false;
    isPlayingWholeSurah = false;
    entireSurahQueued = false;
    setState(() {});
  }

  void playEntireSurah(int surahNumber) {
    currentSurah = surahNumber;
    verseCountForSurah = quran.getVerseCount(surahNumber);
    currentVerseInQueue = 1;

    entireSurahQueued = true;
    isPlayingWholeSurah = true;
    playAudioQueueVerse();
  }

  Future<void> playAudioQueueVerse() async {
    String url = quran.getAudioURLByVerse(currentSurah, currentVerseInQueue);
    await audioPlayer.play(UrlSource(url));
    isPlaying = true;
    setState(() {});
  }

  // ---------------------- UI Builders ----------------------

  Widget buildJuzList(BuildContext context) {
    return FadeTransition(
      opacity: juzAnimation,
      child: ListView.builder(
        controller: scrollControllerJuz,
        physics: const BouncingScrollPhysics(),
        itemCount: allJuzNumbers.length,
        itemBuilder: (context, index) {
          int juzNumber = allJuzNumbers[index];
          return GestureDetector(
            onTap: () {
              selectJuz(juzNumber);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: ListTile(
                title: Text(
                  'Juz $juzNumber',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSurahListForJuz(BuildContext context) {
    return FadeTransition(
      opacity: surahAnimation,
      child: Column(
        children: [
          // Header for Surahs in this Juz
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Juz $selectedJuzForSurahs Surahs',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Go back to the Juz list
                    showSurahSelection = false;
                    showVerseSelection = false;
                    juzAnimationController.reset();
                    juzAnimationController.forward();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Surah list
          Expanded(
            child: ListView.builder(
              controller: scrollControllerSurah,
              physics: const BouncingScrollPhysics(),
              itemCount: surahsInJuz.length,
              itemBuilder: (context, index) {
                int sNumber = surahsInJuz[index];
                return GestureDetector(
                  onTap: () {
                    selectSurah(sNumber);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        quran.getSurahName(sNumber),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        '${quran.getVerseCount(sNumber)} Verses',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
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

  Widget buildVerseListForSurah(BuildContext context) {
    return FadeTransition(
      opacity: verseAnimation,
      child: Column(
        children: [
          // Header for Verses in this Surah
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.library_books,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quran.getSurahName(selectedSurahForVerses),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Go back to the Surah list
                    showVerseSelection = false;
                    surahAnimationController.reset();
                    surahAnimationController.forward();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Play Entire Surah
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            child: ListTile(
              title: Text(
                'Play Entire Surah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              trailing: Icon(
                Icons.play_arrow_rounded,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onTap: () {
                playEntireSurah(selectedSurahForVerses);
              },
            ),
          ),
          // Verse list
          Expanded(
            child: ListView.builder(
              controller: scrollControllerVerse,
              physics: const BouncingScrollPhysics(),
              itemCount: verseCountForSurah,
              itemBuilder: (context, index) {
                int verseNumber = index + 1;
                String verseText = quran.getVerse(selectedSurahForVerses, verseNumber);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      '$verseNumber. $verseText',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    onTap: () {
                      playAudio(selectedSurahForVerses, verseNumber);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAudioPlayerControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            color: Theme.of(context).colorScheme.onBackground,
            onPressed: () {
              if (isPlaying) {
                pauseAudio();
              } else {
                // If user presses play without selecting anything,
                // default to currentSurah, verse 1
                playAudio(currentSurah, 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            color: Theme.of(context).colorScheme.onBackground,
            onPressed: () {
              stopAudio();
            },
          ),
        ],
      ),
    );
  }

  Widget buildMainBody(BuildContext context) {
    return Stack(
      children: [
        // Light background pattern
        Positioned.fill(
          child: CustomPaint(
            painter: SimpleQuranBackgroundPainter(),
          ),
        ),
        // Main content
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // The main area with Juz, Surah, or Verse
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: !showSurahSelection
                          ? buildJuzList(context)
                          : !showVerseSelection
                              ? buildSurahListForJuz(context)
                              : buildVerseListForSurah(context),
                    ),
                  ),
                  // Audio controls at the bottom
                  buildAudioPlayerControls(context),
                  const SizedBox(height: 8),
                ],
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep the clean AppBar with a search icon
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.book, size: 28),  // Book icon added here
            const SizedBox(width: 8),
            const Text('Quran'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: QuranSearchDelegate());
            },
          ),
                      const SizedBox(width: 8),

        ],
        toolbarHeight: 80,  // Increased AppBar height

      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: buildMainBody(context),
    );
  }
}

// ---------------------- Custom Painter for Background ----------------------
class SimpleQuranBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBg = Paint()..color = Colors.blueGrey.withOpacity(0.03);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBg);

    Paint circlePaint = Paint()..color = Colors.blueGrey.withOpacity(0.08);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.25),
      80,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      100,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------- Quran Search Delegate ----------------------
class QuranSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => "Search for a verse";

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Clear search text
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Back button
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Simple text-based search across all verses
    List<Map<String, dynamic>> results = [];
    for (int i = 1; i <= quran.totalSurahCount; i++) {
      int versesCount = quran.getVerseCount(i);
      for (int j = 1; j <= versesCount; j++) {
        String verseText = quran.getVerse(i, j);
        if (verseText.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            "surah": i,
            "verse": j,
            "text": verseText,
          });
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Text("No verses found for '$query'"),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        int surah = results[index]["surah"];
        int verse = results[index]["verse"];
        String text = results[index]["text"];

        return ListTile(
          title: Text('Surah $surah: Verse $verse'),
          subtitle: Text(text),
          onTap: () {
            // Close the search; you could navigate to that verse if desired
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Provide suggestions as user types
    if (query.isEmpty) {
      return const Center(
        child: Text(
          "Type a word or phrase to search in the Quran",
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return Center(
      child: Text(
        "Search verses containing: $query",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
