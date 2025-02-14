import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quran/quran.dart' as quran;

class QuranPage extends StatefulWidget {
  const QuranPage({Key? key}) : super(key: key);
  @override
  QuranPageState createState() => QuranPageState();
}

class QuranPageState extends State<QuranPage> with TickerProviderStateMixin {
  late List<int> allJuzNumbers;
  late List<int> allSurahNumbers;
  late int currentJuz;
  late int currentSurah;
  late bool isLoading;
  late bool isPlaying;
  late AudioPlayer audioPlayer;
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
  late bool showSurahSelection;
  late bool showVerseSelection;
  late int selectedJuzForSurahs;
  late int selectedSurahForVerses;
  late int totalSurahCount;
  late int verseCountForSurah;
  late List<int> surahsInJuz;
  late PageController pageController;
  late int currentPageIndex;

  @override
  void initState() {
    super.initState();
    allJuzNumbers = List.generate(30, (index) => index + 1);
    allSurahNumbers = List.generate(quran.totalSurahCount, (index) => index + 1);
    currentJuz = 1;
    currentSurah = 1;
    isLoading = true;
    isPlaying = false;
    audioPlayer = AudioPlayer();
    searchQuery = "";
    searchController = TextEditingController();
    scrollControllerJuz = ScrollController();
    scrollControllerSurah = ScrollController();
    scrollControllerVerse = ScrollController();
    juzAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    surahAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    verseAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    juzAnimation = CurvedAnimation(parent: juzAnimationController, curve: Curves.easeInOut);
    surahAnimation = CurvedAnimation(parent: surahAnimationController, curve: Curves.easeInOut);
    verseAnimation = CurvedAnimation(parent: verseAnimationController, curve: Curves.easeInOut);
    showSurahSelection = false;
    showVerseSelection = false;
    selectedJuzForSurahs = 1;
    selectedSurahForVerses = 1;
    totalSurahCount = quran.totalSurahCount;
    verseCountForSurah = quran.getVerseCount(currentSurah);
    surahsInJuz = [];
    pageController = PageController();
    currentPageIndex = 0;
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        isLoading = false;
      });
      juzAnimationController.forward();
    });
  }

  @override
  void dispose() {
    scrollControllerJuz.dispose();
    scrollControllerSurah.dispose();
    scrollControllerVerse.dispose();
    searchController.dispose();
    juzAnimationController.dispose();
    surahAnimationController.dispose();
    verseAnimationController.dispose();
    audioPlayer.dispose();
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
    setState(() {});
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    isPlaying = false;
    setState(() {});
  }

  Widget buildJuzList() {
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
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent, width: 1),
              ),
              child: ListTile(
                title: Text(
                  'Juz $juzNumber',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSurahListForJuz() {
    return FadeTransition(
      opacity: surahAnimation,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Juz $selectedJuzForSurahs Surahs',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.close, color: Colors.white),
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
                      color: Colors.purpleAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purpleAccent, width: 1),
                    ),
                    child: ListTile(
                      title: Text(
                        quran.getSurahName(sNumber),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${quran.getVerseCount(sNumber)} Verses',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
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

  Widget buildVerseListForSurah() {
    return FadeTransition(
      opacity: verseAnimation,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.library_books, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quran.getSurahName(selectedSurahForVerses),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showVerseSelection = false;
                    surahAnimationController.reset();
                    surahAnimationController.forward();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
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
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: ListTile(
                    title: Text(
                      '$verseNumber. $verseText',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

  Widget buildAudioPlayerControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
            onPressed: () {
              stopAudio();
            },
          ),
        ],
      ),
    );
  }

  Widget buildMainBody() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: QuranBackgroundPainter(),
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
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Quran',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showSearch(context: context, delegate: QuranSearchDelegate());
                          },
                          icon: const Icon(Icons.search, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: !showSurahSelection
                          ? buildJuzList()
                          : !showVerseSelection
                              ? buildSurahListForJuz()
                              : buildVerseListForSurah(),
                    ),
                  ),
                  buildAudioPlayerControls(),
                  const SizedBox(height: 8),
                ],
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildMainBody());
  }
}

class QuranBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint1 = Paint()..color = Colors.blueAccent.withOpacity(0.2);
    Paint paint2 = Paint()..color = Colors.lightBlueAccent.withOpacity(0.2);
    Paint paint3 = Paint()..color = Colors.indigo.withOpacity(0.2);
    Path path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.35, size.width * 0.5, size.height * 0.3);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.25, size.width, size.height * 0.3);
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint1);
    Path path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.75, size.width * 0.5, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
    Path path3 = Path();
    path3.moveTo(0, size.height * 0.5);
    path3.quadraticBezierTo(size.width * 0.25, size.height * 0.55, size.width * 0.5, size.height * 0.5);
    path3.quadraticBezierTo(size.width * 0.75, size.height * 0.45, size.width, size.height * 0.5);
    path3.lineTo(size.width, size.height * 0.3);
    path3.quadraticBezierTo(size.width * 0.75, size.height * 0.35, size.width * 0.5, size.height * 0.4);
    path3.quadraticBezierTo(size.width * 0.25, size.height * 0.45, 0, size.height * 0.4);
    path3.close();
    canvas.drawPath(path3, paint3);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
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
