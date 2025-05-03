import 'package:flutter/material.dart';
import 'package:prayer/models/custom_azkar_model.dart';
import 'package:prayer/utils/custom_azkar_service.dart';
import 'package:prayer/models/azakdata.dart';
import 'package:prayer/widgets/animated_wave_background.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'custom_azkar_edit_page.dart';
import 'tasbih_azkar_reading_page.dart';

class CustomAzkarPage extends StatefulWidget {
  const CustomAzkarPage({Key? key}) : super(key: key);

  @override
  State<CustomAzkarPage> createState() => _CustomAzkarPageState();
}

class _CustomAzkarPageState extends State<CustomAzkarPage> {
  List<CustomAzkar> _customAzkar = [];
  bool _isLoading = true;

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

  Future<void> _deleteAzkar(CustomAzkar azkar) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.delete),
        content: Text(loc.deleteConfirmation(azkar.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CustomAzkarService.deleteCustomAzkar(azkar.id);
      _loadCustomAzkar();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${azkar.title} ${loc.deleted}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.customAzkar),
      ),
      body: AnimatedWaveBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _customAzkar.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.noCustomAzkar,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(loc.createNewAzkar),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CustomAzkarEditPage(),
                                ),
                              );
                              _loadCustomAzkar();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCustomAzkar,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _customAzkar.length,
                      itemBuilder: (context, index) {
                        final azkar = _customAzkar[index];
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
                            default:
                              cardIcon = Icons.menu_book;
                          }
                        }

                        return Card(
                          color: cardColor.withOpacity(0.85),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
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
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Icon(cardIcon, color: Colors.white, size: 36),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          azkar.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (azkar.arabicTitle.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              azkar.arabicTitle,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            '${azkar.items.length} ${loc.items}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CustomAzkarEditPage(
                                              azkar: azkar,
                                            ),
                                          ),
                                        );
                                        _loadCustomAzkar();
                                      } else if (value == 'delete') {
                                        _deleteAzkar(azkar);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit),
                                            const SizedBox(width: 8),
                                            Text(loc.edit),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete, color: Colors.red),
                                            const SizedBox(width: 8),
                                            Text(loc.delete, style: const TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: !_isLoading && _customAzkar.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomAzkarEditPage(),
                  ),
                );
                _loadCustomAzkar();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 