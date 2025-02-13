import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:audioplayers/audioplayers.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({Key? key}) : super(key: key);

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late List<int> _surahNumbers;
  late List<int> _selectedJuzSurahs;
  late int _selectedSurahNumber;
  bool _isLoading = true;
  bool _isPlaying = false;
  late AudioPlayer _audioPlayer;
  late ScrollController _scrollController;
  String _searchQuery = "";
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _loadSurahs();
  }

  void _loadSurahs() async {
    setState(() {
      _surahNumbers = List.generate(quran.totalSurahCount, (index) => index + 1);
      _selectedSurahNumber = 1; // Default to the first Surah
      // _selectedJuzSurahs = List.generate(quran.getSurahAndVersesFromJuz(30).length, (index) => quran.getSurahAndVersesFromJuz(30)[index]);
      _isLoading = false;
    });
  }

  void _playAudio(int surah, int ayah) async {
    String url = quran.getAudioURLByVerse(surah, ayah);
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      _isPlaying = true;
    });
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  Widget _buildSurahList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _surahNumbers.length,
      itemBuilder: (context, index) {
        int surahNumber = _surahNumbers[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSurahNumber = surahNumber;
            });
          },
          child: SurahCard(surahNumber: surahNumber),
        );
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 30,  // 30 Juz in the Quran
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedJuzSurahs = quran.getSurahAndVersesFromJuz(index + 1) as List<int>;
              _selectedSurahNumber = _selectedJuzSurahs[0];
            });
          },
          child: JuzCard(juzNumber: index + 1),
        );
      },
    );
  }

  Widget _buildVerseList() {
    return ListView.builder(
      itemCount: quran.getVerseCount(_selectedSurahNumber),
      itemBuilder: (context, index) {
        final verseNumber = index + 1;
        final verseText = quran.getVerse(_selectedSurahNumber, verseNumber);
        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              '$verseNumber: $verseText',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              _playAudio(_selectedSurahNumber, verseNumber);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: QuranSearchDelegate());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 30, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          quran.getSurahName(_selectedSurahNumber),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildJuzList(),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildVerseList(),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAudioControls(),
              ],
            ),
    );
  }

  Widget _buildAudioControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isPlaying) {
                _pauseAudio();
              } else {
                _playAudio(_selectedSurahNumber, 1); // Play first verse
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _stopAudio,
          ),
        ],
      ),
    );
  }
}

class SurahCard extends StatelessWidget {
  final int surahNumber;

  const SurahCard({Key? key, required this.surahNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String surahName = quran.getSurahName(surahNumber);
    int verseCount = quran.getVerseCount(surahNumber);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          surahName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$verseCount Verses',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          // Navigate to verse list or highlight Surah
        },
      ),
    );
  }
}

class JuzCard extends StatelessWidget {
  final int juzNumber;

  const JuzCard({Key? key, required this.juzNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'Juz $juzNumber',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // Navigate to the Juz Surah list
        },
      ),
    );
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
    final List<int> results = [];
    for (int i = 1; i <= quran.totalSurahCount; i++) {
      for (int j = 1; j <= quran.getVerseCount(i); j++) {
        String verseText = quran.getVerse(i, j);
        if (verseText.contains(query)) {
          results.add(i);
        }
      }
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final surah = results[index];
        final ayah = quran.getVerse(surah, 1);
        return ListTile(
          title: Text('$surah: $ayah'),
          onTap: () {
            close(context, null);
            // Navigate to the surah page
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text(
        "Search for verses containing: $query",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
