import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_azkar';
  
  /// Add an azkar item to favorites
  static Future<bool> addFavorite(String azkarId) async {
    final favorites = await getFavorites();
    
    if (favorites.contains(azkarId)) {
      return false; // Already a favorite
    }
    
    favorites.add(azkarId);
    return await _saveFavorites(favorites);
  }
  
  /// Remove an azkar item from favorites
  static Future<bool> removeFavorite(String azkarId) async {
    final favorites = await getFavorites();
    
    if (!favorites.contains(azkarId)) {
      return false; // Not a favorite
    }
    
    favorites.remove(azkarId);
    return await _saveFavorites(favorites);
  }
  
  /// Toggle the favorite status of an azkar item
  static Future<bool> toggleFavorite(String azkarId) async {
    final favorites = await getFavorites();
    
    if (favorites.contains(azkarId)) {
      favorites.remove(azkarId);
    } else {
      favorites.add(azkarId);
    }
    
    return await _saveFavorites(favorites);
  }
  
  /// Check if an azkar item is a favorite
  static Future<bool> isFavorite(String azkarId) async {
    final favorites = await getFavorites();
    return favorites.contains(azkarId);
  }
  
  /// Get all favorite azkar IDs
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((item) => item.toString()).toList();
    } catch (e) {
      print('Error decoding favorites: $e');
      return [];
    }
  }
  
  /// Save the list of favorites
  static Future<bool> _saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(favorites);
    
    return await prefs.setString(_favoritesKey, favoritesJson);
  }
  
  /// Clear all favorites
  static Future<bool> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_favoritesKey);
  }
} 