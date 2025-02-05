import 'package:flutter/material.dart';
import 'dart:math' as math;

class AzkarPage extends StatefulWidget {
  @override
  _AzkarPageState createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<AzkarModel> _morningAzkar = [
    AzkarModel(
      arabic: 'اللّهـمَّ أَنْتَ رَبِّي لا إلهَ إلاّ أَنْتَ ...',
      translation: 'O Allah, You are my Lord...',
      reference: 'Morning Azkar #1',
    ),
    AzkarModel(
      arabic: 'أَصْـبَحْنَا وَأَصْبَحَ المُلْكُ لِلهِ ...',
      translation: 'We have entered a new morning...',
      reference: 'Morning Azkar #2',
    ),
  ];
  final List<AzkarModel> _eveningAzkar = [
    AzkarModel(
      arabic: 'أَمْسَيْنَا وَأَمْسَى المُـلْكُ لِلَّـهِ ...',
      translation: 'We have entered the evening...',
      reference: 'Evening Azkar #1',
    ),
    AzkarModel(
      arabic: 'اللَّهُمَّ إِنِّي أَمْسَيْتُ مِنْكَ فِي نِعْمَةٍ ...',
      translation: 'O Allah, I have entered this evening...',
      reference: 'Evening Azkar #2',
    ),
  ];
  final List<AzkarModel> _afterPrayerAzkar = [
    AzkarModel(
      arabic: 'أَسْتَغْفِرُ اللَّهَ (3 times)',
      translation: 'I seek forgiveness from Allah...',
      reference: 'After Prayer #1',
    ),
    AzkarModel(
      arabic: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ ...',
      translation: 'O Allah, You are Peace...',
      reference: 'After Prayer #2',
    ),
  ];
  final List<AzkarModel> _miscAzkar = [
    AzkarModel(
      arabic: 'بِسْمِ اللهِ (before eating)',
      translation: 'In the name of Allah.',
      reference: 'Misc #1',
    ),
    AzkarModel(
      arabic: 'الْحَمْدُ للّهِ (after eating)',
      translation: 'All praise is due to Allah.',
      reference: 'Misc #2',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              title: Text('Azkar', style: TextStyle(color: theme.colorScheme.onPrimary)),
              pinned: true,
              floating: true,
              backgroundColor: theme.colorScheme.primary,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: theme.colorScheme.onPrimary,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
                tabs: const [
                  Tab(text: 'Morning'),
                  Tab(text: 'Evening'),
                  Tab(text: 'AfterPrayer'),
                  Tab(text: 'Misc'),
                ],
              ),
            ),
          ],
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.surface, theme.colorScheme.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAzkarList(_morningAzkar),
                _buildAzkarList(_eveningAzkar),
                _buildAzkarList(_afterPrayerAzkar),
                _buildAzkarList(_miscAzkar),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAzkarList(List<AzkarModel> azkarList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: azkarList.length,
      itemBuilder: (context, index) {
        return AzkarCard(azkar: azkarList[index]);
      },
    );
  }
}

class AzkarModel {
  final String arabic;
  final String translation;
  final String reference;
  int counter;
  bool isExpanded;
  AzkarModel({
    required this.arabic,
    required this.translation,
    required this.reference,
    this.counter = 0,
    this.isExpanded = false,
  });
}

class AzkarCard extends StatefulWidget {
  final AzkarModel azkar;
  const AzkarCard({Key? key, required this.azkar}) : super(key: key);

  @override
  _AzkarCardState createState() => _AzkarCardState();
}

class _AzkarCardState extends State<AzkarCard> {
  void _toggleExpand() {
    setState(() {
      widget.azkar.isExpanded = !widget.azkar.isExpanded;
    });
  }

  void _incrementCounter() {
    setState(() {
      widget.azkar.counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final azkar = widget.azkar;
    return Card(
      color: theme.colorScheme.background.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  azkar.arabic,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 16, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      azkar.translation,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onBackground),
                    ),
                    if (azkar.reference.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        azkar.reference,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7), fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Count: ${azkar.counter}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onBackground),
                        ),
                        IconButton(
                          onPressed: _incrementCounter,
                          icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: azkar.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(azkar.isExpanded ? Icons.expand_less : Icons.expand_more, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
