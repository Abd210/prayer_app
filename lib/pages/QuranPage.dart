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
  late bool isLoading;
  late bool isPlaying;
  late bool isPlayingWholeSurah;
  late AudioPlayer audioPlayer;
  late List<int> allJuzNumbers;
  late List<int> allSurahNumbers;
  late List<int> surahsInJuz;
  late int currentJuz;
  late int currentSurah;
  late int selectedJuzForSurahs;
  late int selectedSurahForVerses;
  late bool showSurahSelection;
  late bool showVerseSelection;
  late int verseCountForSurah;
  late String searchQuery;
  late TextEditingController searchController;
  late ScrollController scrollControllerJuz;
  late ScrollController scrollControllerSurah;
  late ScrollController scrollControllerVerse;
  late AnimationController juzAnimationController;
  late AnimationController surahAnimationController;
  late AnimationController verseAnimationController;
  late Animation<double> juzAnimation;
  late Animation<double> surahAnimation;
  late Animation<double> verseAnimation;
  late int totalSurahCount;
  late StreamSubscription onCompleteSubscription;
  late int currentVerseInQueue;
  late bool entireSurahQueued;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    isPlaying = false;
    isPlayingWholeSurah = false;
    entireSurahQueued = false;
    audioPlayer = AudioPlayer();
    onCompleteSubscription = audioPlayer.onPlayerComplete.listen((event) {
      if (entireSurahQueued && currentVerseInQueue < verseCountForSurah) {
        currentVerseInQueue++;
        playAudioQueueVerse();
      } else {
        isPlaying = false;
        isPlayingWholeSurah = false;
        entireSurahQueued = false;
        setState(() {});
      }
    });
    allJuzNumbers = List.generate(30, (index) => index + 1);
    allSurahNumbers = List.generate(quran.totalSurahCount, (index) => index + 1);
    currentJuz = 1;
    currentSurah = 1;
    showSurahSelection = false;
    showVerseSelection = false;
    selectedJuzForSurahs = 1;
    selectedSurahForVerses = 1;
    scrollControllerJuz = ScrollController();
    scrollControllerSurah = ScrollController();
    scrollControllerVerse = ScrollController();
    juzAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    surahAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    verseAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    juzAnimation = CurvedAnimation(parent: juzAnimationController, curve: Curves.easeInOut);
    surahAnimation = CurvedAnimation(parent: surahAnimationController, curve: Curves.easeInOut);
    verseAnimation = CurvedAnimation(parent: verseAnimationController, curve: Curves.easeInOut);
    searchQuery = "";
    searchController = TextEditingController();
    totalSurahCount = quran.totalSurahCount;
    verseCountForSurah = quran.getVerseCount(currentSurah);
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
    searchController.dispose();
    juzAnimationController.dispose();
    surahAnimationController.dispose();
    verseAnimationController.dispose();
    super.dispose();
  }

  void selectJuz(int juzNumber) {
    currentJuz = juzNumber;
    surahsInJuz = [];
    var data = quran.getSurahAndVersesFromJuz(juzNumber);
    for (var entry in data.entries) {
      surahsInJuz.add(entry.key);
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
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
              ),
              child: ListTile(
                title: Text(
                  'Juz $juzNumber',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Theme.of(context).colorScheme.onBackground),
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
                Icon(Icons.auto_stories, color: Theme.of(context).colorScheme.onPrimary, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Juz $selectedJuzForSurahs Surahs',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showSurahSelection = false;
                    showVerseSelection = false;
                    juzAnimationController.reset();
                    juzAnimationController.forward();
                    setState(() {});
                  },
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
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
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                    ),
                    child: ListTile(
                      title: Text(
                        quran.getSurahName(sNumber),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                      ),
                      subtitle: Text(
                        '${quran.getVerseCount(sNumber)} Verses',
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onBackground),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Theme.of(context).colorScheme.onBackground),
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
                Icon(Icons.library_books, color: Theme.of(context).colorScheme.onPrimary, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quran.getSurahName(selectedSurahForVerses),
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showVerseSelection = false;
                    surahAnimationController.reset();
                    surahAnimationController.forward();
                    setState(() {});
                  },
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1),
            ),
            child: ListTile(
              title: Text(
                'Play Entire Surah',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
              ),
              trailing: Icon(Icons.play_arrow_rounded, color: Theme.of(context).colorScheme.onBackground),
              onTap: () {
                playEntireSurah(selectedSurahForVerses);
              },
            ),
          ),
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
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.5),
                  ),
                  child: ListTile(
                    title: Text(
                      '$verseNumber. $verseText',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onBackground),
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
        Positioned.fill(
          child: CustomPaint(
            painter: SimpleQuranBackgroundPainter(),
          ),
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.9),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.menu_book, color: Theme.of(context).colorScheme.onPrimary, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Quran',
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showSearch(context: context, delegate: QuranSearchDelegate());
                          },
                          icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary, size: 28),
                        ),
                      ],
                    ),
                  ),
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: buildMainBody(context),
    );
  }
}

class SimpleQuranBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBg = Paint()..color = Colors.blueGrey.withOpacity(0.03);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBg);

    Paint circlePaint = Paint()..color = Colors.blueGrey.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.25), 80, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), 100, circlePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuranSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => "Search for a verse";
  @override
  List<Widget>? buildActions(BuildContext context) {
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
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> results = [];
    for (int i = 1; i <= quran.totalSurahCount; i++) {
      int versesCount = quran.getVerseCount(i);
      for (int j = 1; j <= versesCount; j++) {
        String verseText = quran.getVerse(i, j);
        if (verseText.contains(query)) {
          results.add({"surah": i, "verse": j, "text": verseText});
        }
      }
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
            close(context, null);
          },
        );
      },
    );
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text("Search for verses containing: $query", style: const TextStyle(fontSize: 18)),
    );
  }
}

class DummyWidgetOne extends StatelessWidget {
  final String text;
  const DummyWidgetOne({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwo extends StatelessWidget {
  final String text;
  const DummyWidgetTwo({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetThree extends StatefulWidget {
  final String text;
  const DummyWidgetThree({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetThreeState createState() => DummyWidgetThreeState();
}

class DummyWidgetThreeState extends State<DummyWidgetThree> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    scale = CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    controller.forward();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }
}

class DummyWidgetFour extends StatelessWidget {
  final String text;
  const DummyWidgetFour({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetFive extends StatelessWidget {
  final String text;
  const DummyWidgetFive({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetSix extends StatelessWidget {
  final String text;
  const DummyWidgetSix({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetSeven extends StatelessWidget {
  final String text;
  const DummyWidgetSeven({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetEight extends StatelessWidget {
  final String text;
  const DummyWidgetEight({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetNine extends StatelessWidget {
  final String text;
  const DummyWidgetNine({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTen extends StatelessWidget {
  final String text;
  const DummyWidgetTen({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetEleven extends StatefulWidget {
  final String text;
  const DummyWidgetEleven({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetElevenState createState() => DummyWidgetElevenState();
}

class DummyWidgetElevenState extends State<DummyWidgetEleven> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offsetAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    offsetAnimation = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    controller.forward();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offsetAnimation,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }
}

class DummyWidgetTwelve extends StatefulWidget {
  final String text;
  const DummyWidgetTwelve({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetTwelveState createState() => DummyWidgetTwelveState();
}

class DummyWidgetTwelveState extends State<DummyWidgetTwelve> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> rotationAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    rotationAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    controller.repeat(reverse: true);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: rotationAnimation,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.yellow.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }
}

class DummyWidgetThirteen extends StatefulWidget {
  final String text;
  const DummyWidgetThirteen({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetThirteenState createState() => DummyWidgetThirteenState();
}

class DummyWidgetThirteenState extends State<DummyWidgetThirteen> with TickerProviderStateMixin {
  late AnimationController controller1;
  late AnimationController controller2;
  late Animation<double> fadeIn;
  late Animation<double> fadeOut;
  bool showFirst = true;
  @override
  void initState() {
    super.initState();
    controller1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    controller2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller1, curve: Curves.easeIn));
    fadeOut = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: controller2, curve: Curves.easeOut));
    controller1.forward();
  }
  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }
  void toggle() {
    if (showFirst) {
      controller2.forward().then((_) {
        setState(() {
          showFirst = false;
        });
        controller1.forward(from: 0);
      });
    } else {
      controller2.forward().then((_) {
        setState(() {
          showFirst = true;
        });
        controller1.forward(from: 0);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: controller1,
            builder: (context, child) {
              return Opacity(
                opacity: showFirst ? fadeIn.value : 0,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: controller2,
            builder: (context, child) {
              return Opacity(
                opacity: showFirst ? 0 : 1 - fadeOut.value,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("${widget.text} (Alt)", style: const TextStyle(color: Colors.black, fontSize: 14)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DummyWidgetFourteen extends StatefulWidget {
  final String text;
  const DummyWidgetFourteen({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetFourteenState createState() => DummyWidgetFourteenState();
}

class DummyWidgetFourteenState extends State<DummyWidgetFourteen> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slide;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    controller.forward();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slide,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }
}

class DummyWidgetFifteen extends StatefulWidget {
  final String text;
  const DummyWidgetFifteen({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetFifteenState createState() => DummyWidgetFifteenState();
}

class DummyWidgetFifteenState extends State<DummyWidgetFifteen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceInOut);
    controller.forward();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.lime.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }
}

class DummyWidgetSixteen extends StatefulWidget {
  final String text;
  const DummyWidgetSixteen({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetSixteenState createState() => DummyWidgetSixteenState();
}

class DummyWidgetSixteenState extends State<DummyWidgetSixteen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    controller.forward();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.indigoAccent.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }
}

class DummyWidgetSeventeen extends StatefulWidget {
  final String text;
  const DummyWidgetSeventeen({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetSeventeenState createState() => DummyWidgetSeventeenState();
}

class DummyWidgetSeventeenState extends State<DummyWidgetSeventeen> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> rotateAnimation;
  bool flipped = false;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    rotateAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  void flipCard() {
    if (!flipped) {
      controller.forward();
    } else {
      controller.reverse();
    }
    flipped = !flipped;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          double rotationValue = rotateAnimation.value;
          double angle = rotationValue * 3.14159;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(angle),
            child: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: !flipped ? Colors.purple.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                !flipped ? widget.text : "${widget.text} (Flipped)",
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DummyWidgetEighteen extends StatelessWidget {
  final String text;
  const DummyWidgetEighteen({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetNineteen extends StatelessWidget {
  final String text;
  const DummyWidgetNineteen({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwenty extends StatelessWidget {
  final String text;
  const DummyWidgetTwenty({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueGrey, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentyOne extends StatelessWidget {
  final String text;
  const DummyWidgetTwentyOne({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellowAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentyTwo extends StatelessWidget {
  final String text;
  const DummyWidgetTwentyTwo({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeIn,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentyThree extends StatelessWidget {
  final String text;
  const DummyWidgetTwentyThree({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentyFour extends StatelessWidget {
  final String text;
  const DummyWidgetTwentyFour({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentyFive extends StatelessWidget {
  final String text;
  const DummyWidgetTwentyFive({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentySix extends StatelessWidget {
  final String text;
  const DummyWidgetTwentySix({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutBack,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentySeven extends StatelessWidget {
  final String text;
  const DummyWidgetTwentySeven({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetTwentyEight extends StatefulWidget {
  final String text;
  const DummyWidgetTwentyEight({Key? key, required this.text}) : super(key: key);
  @override
  DummyWidgetTwentyEightState createState() => DummyWidgetTwentyEightState();
}

class DummyWidgetTwentyEightState extends State<DummyWidgetTwentyEight> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeInOut;
  bool visible = true;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    fadeInOut = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  void toggle() {
    if (visible) {
      controller.forward();
    } else {
      controller.reverse();
    }
    visible = !visible;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Opacity(
            opacity: 1 - fadeInOut.value,
            child: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 14)),
            ),
          );
        },
      ),
    );
  }
}

class DummyWidgetTwentyNine extends StatelessWidget {
  final String text;
  const DummyWidgetTwentyNine({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}

class DummyWidgetThirty extends StatelessWidget {
  final String text;
  const DummyWidgetThirty({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}
