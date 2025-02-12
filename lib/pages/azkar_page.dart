import 'package:flutter/material.dart';
import 'package:adhkar/adhkar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azkar_model.dart';
import '../widgets/azkar_card.dart';
import 'settings_page.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({Key? key}) : super(key: key);

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<AzkarModel> morningAzkar = [];
  final List<AzkarModel> eveningAzkar = [];
  final List<AzkarModel> afterPrayerAzkar = [];
  final List<AzkarModel> miscAzkar = [];
  List<AzkarModel> allAzkar = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAzkarData();
  }

  void _loadAzkarData() {
    // Fetch Adhkar data using the Adhkar package
    List<String> allAdhkarIds = AdhkarFactory.getAllAdhkarId();
    List<Adhkar> adhkarList = AdhkarFactory.getAdhkar();
    // Example data loading
    for (int i = 1; i <= 5; i++) {
      morningAzkar.add(
        AzkarModel(
          category: 'Morning',
          title: 'Morning Azkar #$i',
          arabic: 'اللّهـمَّ أَصْبَحْنا وَبِكَ ... ($i)',
          transliteration: 'Allahumma asbahna... ($i)',
          translation: 'O Allah, by Your leave we enter the morning...($i)',
          reference: 'Ref #$i for Morning',
          audioUrl: '',
        ),
      );
    }
    for (int i = 1; i <= 5; i++) {
      eveningAzkar.add(
        AzkarModel(
          category: 'Evening',
          title: 'Evening Azkar #$i',
          arabic: 'اللّهـمَّ أَمْسَيْنا... ($i)',
          transliteration: 'Allahumma amsayna... ($i)',
          translation: 'O Allah, by Your leave we enter the evening...($i)',
          reference: 'Ref #$i for Evening',
          audioUrl: '',
        ),
      );
    }
    for (int i = 1; i <= 3; i++) {
      afterPrayerAzkar.add(
        AzkarModel(
          category: 'AfterPrayer',
          title: 'After Prayer Azkar #$i',
          arabic: 'أَسْتَغْفِرُكَ ... ($i)',
          transliteration: 'Astaghfiruka...($i)',
          translation: 'I seek Your forgiveness...($i)',
          reference: 'Ref #$i for AfterPrayer',
          audioUrl: '',
        ),
      );
    }
    for (int i = 1; i <= 3; i++) {
      miscAzkar.add(
        AzkarModel(
          category: 'Misc',
          title: 'Miscellaneous Azkar #$i',
          arabic: 'بِسْمِ اللهِ ... ($i)',
          transliteration: 'Bismillah...($i)',
          translation: 'In the name of Allah...($i)',
          reference: 'Ref #$i for Misc',
          audioUrl: '',
        ),
      );
    }

    // Combine all
    allAzkar
      ..addAll(morningAzkar)
      ..addAll(eveningAzkar)
      ..addAll(afterPrayerAzkar)
      ..addAll(miscAzkar);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Azkār'),
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
              showSearch(
                context: context,
                delegate: AzkarSearchDelegate(allAzkar: allAzkar),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
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
            children: const [
              Text('An advanced Azkār app with counters, search, favorites, etc.'),
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

/// Implements search functionality for Azkār.
class AzkarSearchDelegate extends SearchDelegate {
  final List<AzkarModel> allAzkar;

  AzkarSearchDelegate({required this.allAzkar});

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = allAzkar.where((azkar) {
      return azkar.title.toLowerCase().contains(query.toLowerCase()) ||
          azkar.arabic.contains(query) ||
          azkar.translation.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return AzkarCard(azkar: results[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allAzkar.where((azkar) {
      return azkar.title.toLowerCase().contains(query.toLowerCase()) ||
          azkar.arabic.contains(query);
    }).toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text('No suggestions.'));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return AzkarCard(azkar: suggestions[index]);
      },
    );
      }
}
