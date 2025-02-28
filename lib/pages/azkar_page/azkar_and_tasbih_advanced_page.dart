import 'package:flutter/material.dart';
import 'package:prayer/models/azakdata.dart'; // Example data import
import 'package:prayer/widgets/animated_wave_background.dart';
import 'tasbih_azkar_reading_page.dart';      // To reference TasbihAdvancedPage, etc.

/// 
/// AZKAR & TASBIH ADVANCED PAGE
/// 
class AzkarAndTasbihAdvancedPage extends StatefulWidget {
  const AzkarAndTasbihAdvancedPage({Key? key}) : super(key: key);

  @override
  State<AzkarAndTasbihAdvancedPage> createState() =>
      _AzkarAndTasbihAdvancedPageState();
}

class _AzkarAndTasbihAdvancedPageState
    extends State<AzkarAndTasbihAdvancedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Two tabs: "Azkar" & "Tasbih"
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Azkar & Tasbih'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.white, 
            tabs: const [
              Tab(icon: Icon(Icons.menu_book), text: 'Azkar'),
              Tab(icon: Icon(Icons.fingerprint), text: 'Tasbih'),
            ],
          ),
        ),
        body: AnimatedWaveBackground(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _AzkarMenuPage(),
              TasbihAdvancedPage(),
            ],
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
    );
  }
}

/// 
/// AZKAR MENU PAGE
/// 
class _AzkarMenuPage extends StatefulWidget {
  const _AzkarMenuPage();

  @override
  State<_AzkarMenuPage> createState() => _AzkarMenuPageState();
}

class _AzkarMenuPageState extends State<_AzkarMenuPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _AzkarCard(
            title: 'Morning Azkar',
            subtitle: 'أذكار الصباح',
            color: theme.colorScheme.primary,
            icon: Icons.sunny_snowing,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Morning Azkar',
                    items: morningAdhkar, // from azakdata.dart
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _AzkarCard(
            title: 'Evening Azkar',
            subtitle: 'أذكار المساء',
            color: theme.colorScheme.secondary,
            icon: Icons.nights_stay_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Evening Azkar',
                    items: eveningAdhkar, // from azakdata.dart
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _AzkarCard(
            title: 'Sleep Azkar',
            subtitle: 'أذكار النوم',
            color: Colors.teal,
            icon: Icons.bed,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Sleep Azkar',
                    items: sleepAzkar, // from azakdata.dart
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _AzkarCard(
            title: 'Waking Up Azkar',
            subtitle: 'أذكار الاستيقاظ',
            color: Colors.deepPurple,
            icon: Icons.wb_sunny_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Waking Up Azkar',
                    items: wakingUpAzkar, // from azakdata.dart
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _AzkarCard(
            title: 'After Prayers',
            subtitle: 'أذكار بعد الصلاة',
            color: Colors.indigo,
            icon: Icons.done_all,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'After Prayers Azkar',
                    items: afterPrayersAzkar, // from azakdata.dart
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _AzkarCard(
            title: 'Surah Al-Mulk',
            subtitle: 'سورة الملك',
            color: Colors.redAccent,
            icon: Icons.book_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Surah Al-Mulk',
                    items: surahAlMulkAzkar, // from azakdata.dart
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _AzkarCard(
            title: 'Surah Yaseen',
            subtitle: 'سورة يس',
            color: Colors.orange,
            icon: Icons.book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Surah Yaseen',
                    items: surahYaseenAzkar, // from azakdata.dart
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A neat card for "Morning" / "Evening" / Sleep, etc.
class _AzkarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AzkarCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
