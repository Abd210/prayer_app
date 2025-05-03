import 'package:flutter/material.dart';
import 'package:prayer/models/azakdata.dart';
import 'package:prayer/widgets/animated_wave_background.dart';
import 'package:prayer/utils/custom_azkar_service.dart';
import 'package:prayer/models/custom_azkar_model.dart';
import 'tasbih_azkar_reading_page.dart';
import 'custom_azkar_page.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///
/// AZKAR & TASBIH ADVANCED PAGE
///
class AzkarAndTasbihAdvancedPage extends StatefulWidget {
  const AzkarAndTasbihAdvancedPage({Key? key}) : super(key: key);

  @override
  State<AzkarAndTasbihAdvancedPage> createState() =>
      _AzkarAndTasbihAdvancedPageState();
}

class _AzkarAndTasbihAdvancedPageState extends State<AzkarAndTasbihAdvancedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.azkarTasbihTitle),          // ← localised
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: const Icon(Icons.menu_book), text: loc.azkarTab),
              Tab(icon: const Icon(Icons.fingerprint), text: loc.tasbihTab),
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
  List<CustomAzkar> _customAzkar = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadCustomAzkar();
  }
  
  Future<void> _loadCustomAzkar() async {
    setState(() {
      _isLoading = true;
    });
    
    final azkar = await CustomAzkarService.loadCustomAzkar();
    
    if (mounted) {
      setState(() {
        _customAzkar = azkar;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

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
                    items: morningAdhkar,
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
                    items: eveningAdhkar,
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
                    items: sleepAzkar,
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
                    items: wakingUpAzkar,
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
                    items: afterPrayersAzkar,
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
                    items: surahAlMulkAzkar,
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
                    items: surahYaseenAzkar,
                  ),
                ),
              );
            },
          ),
          
          // Divider to separate built-in and custom azkar
          if (_customAzkar.isNotEmpty) ... [
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    loc.customAzkar,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          
          // Custom Azkar Section
          ..._customAzkar.map((azkar) {
            // Parse the color if it exists
            Color cardColor = theme.colorScheme.primary;
            if (azkar.color != null) {
              try {
                cardColor = Color(int.parse(azkar.color!));
              } catch (e) {
                // Use default color if parsing fails
              }
            }
            
            // Parse the icon if it exists
            IconData cardIcon = Icons.menu_book;
            if (azkar.icon != null) {
              switch (azkar.icon) {
                case 'sunny_snowing':
                  cardIcon = Icons.sunny_snowing;
                  break;
                case 'nights_stay_outlined':
                  cardIcon = Icons.nights_stay_outlined;
                  break;
                case 'bed':
                  cardIcon = Icons.bed;
                  break;
                case 'wb_sunny_outlined':
                  cardIcon = Icons.wb_sunny_outlined;
                  break;
                case 'done_all':
                  cardIcon = Icons.done_all;
                  break;
                case 'book_outlined':
                  cardIcon = Icons.book_outlined;
                  break;
                case 'book':
                  cardIcon = Icons.book;
                  break;
                case 'favorite':
                  cardIcon = Icons.favorite;
                  break;
                case 'star':
                  cardIcon = Icons.star;
                  break;
                default:
                  cardIcon = Icons.menu_book;
              }
            }
            
            return Column(
              children: [
                _AzkarCard(
                  title: azkar.title,
                  subtitle: azkar.arabicTitle,
                  color: cardColor,
                  icon: cardIcon,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AzkarReadingPage(
                          title: azkar.title,
                          items: azkar.items.map((item) => DhikrItem(
                            arabic: item.arabic,
                            translation: item.translation,
                            repeat: item.repeat,
                          )).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
          
          // Custom Azkar Management Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomAzkarPage(),
                  ),
                );
                _loadCustomAzkar();
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: theme.colorScheme.primary,
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.manageCustomAzkar,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.createAndEditCustomAzkar,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
