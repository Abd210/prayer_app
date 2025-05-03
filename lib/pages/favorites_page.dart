import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../widgets/azkar_card.dart';
import '../models/azkar_model.dart';
import '../models/azakdata.dart';
import '../services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> _favoriteIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final favorites = await FavoritesService.getFavorites();

    if (mounted) {
      setState(() {
        _favoriteIds = favorites;
        _isLoading = false;
      });
    }
  }

  // Find Azkar items by their IDs
  List<AzkarModel> _getFavoriteAzkar() {
    // Create a list of all available azkar from the data
    final List<AzkarModel> allAzkar = [];
    
    // Add the morning azkar
    allAzkar.addAll(morningAzkar);
    
    // Add the evening azkar
    allAzkar.addAll(eveningAzkar);
    
    // Add other azkar collections
    allAzkar.addAll(sleepAzkar);
    allAzkar.addAll(afterSalahAzkar);
    
    // Filter to only include favorites
    return allAzkar.where((azkar) => _favoriteIds.contains(azkar.id)).toList();
  }

  Future<void> _removeFavorite(String id) async {
    await FavoritesService.removeFavorite(id);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Azkar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteIds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Favorite Azkar',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add favorites from the Azkar pages',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _getFavoriteAzkar().length,
                  itemBuilder: (context, index) {
                    final azkar = _getFavoriteAzkar()[index];
                    
                    return Dismissible(
                      key: Key(azkar.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _removeFavorite(azkar.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed from favorites'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                FavoritesService.addFavorite(azkar.id);
                                _loadFavorites();
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AzkarCard(
                          azkar: azkar,
                          onTap: () {
                            // Open the azkar detail page
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 