import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer/models/custom_azkar_model.dart';

class CustomAzkarService {
  static const String _customAzkarKey = 'custom_azkar';
  
  // Convert DhikrItem to new format for compatibility
  static CustomDhikrItem convertDhikrItem({
    required String arabic,
    required String translation,
    required int repeat,
  }) {
    return CustomDhikrItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      arabic: arabic,
      translation: translation,
      repeat: repeat,
    );
  }
  
  // Load all custom azkar from SharedPreferences
  static Future<List<CustomAzkar>> loadCustomAzkar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_customAzkarKey);
      
      if (data == null) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => CustomAzkar.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading custom azkar: $e');
      return [];
    }
  }
  
  // Save all custom azkar to SharedPreferences
  static Future<bool> saveCustomAzkar(List<CustomAzkar> customAzkar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(customAzkar.map((azkar) => azkar.toJson()).toList());
      return await prefs.setString(_customAzkarKey, jsonData);
    } catch (e) {
      debugPrint('Error saving custom azkar: $e');
      return false;
    }
  }
  
  // Add a new custom azkar
  static Future<bool> addCustomAzkar(CustomAzkar azkar) async {
    final currentList = await loadCustomAzkar();
    
    // Check if ID already exists
    if (currentList.any((item) => item.id == azkar.id)) {
      return false;
    }
    
    currentList.add(azkar);
    return await saveCustomAzkar(currentList);
  }
  
  // Update an existing custom azkar
  static Future<bool> updateCustomAzkar(CustomAzkar azkar) async {
    final currentList = await loadCustomAzkar();
    final index = currentList.indexWhere((item) => item.id == azkar.id);
    
    if (index == -1) {
      return false;
    }
    
    currentList[index] = azkar;
    return await saveCustomAzkar(currentList);
  }
  
  // Delete a custom azkar by ID
  static Future<bool> deleteCustomAzkar(String id) async {
    final currentList = await loadCustomAzkar();
    final newList = currentList.where((azkar) => azkar.id != id).toList();
    
    if (currentList.length == newList.length) {
      return false;
    }
    
    return await saveCustomAzkar(newList);
  }
  
  // Get a custom azkar by ID
  static Future<CustomAzkar?> getCustomAzkarById(String id) async {
    final currentList = await loadCustomAzkar();
    try {
      return currentList.firstWhere((azkar) => azkar.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Generate a unique ID for a new custom azkar
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
} 