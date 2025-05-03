import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class AdhanService {
  static final AdhanService _instance = AdhanService._internal();
  factory AdhanService() => _instance;
  AdhanService._internal();

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Settings keys
  static const String _enabledKey = 'adhan_enabled';
  static const String _volumeKey = 'adhan_volume';
  
  // Default settings
  bool _isEnabled = true;
  double _volume = 0.5;

  // Audio file path - using same adhan for all prayers
  final String _adhanPath = 'adhan/adhan_normal.mp3';

  Future<void> init() async {
    if (kIsWeb) return; // Skip on web platform
    
    try {
      // Load settings from shared preferences
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? true;
      _volume = prefs.getDouble(_volumeKey) ?? 0.5;
      
      // Configure audio player
      await _audioPlayer.setVolume(_volume);
      
      print('[AdhanService] Initialized with enabled: $_isEnabled, volume: $_volume');
    } catch (e) {
      print('[AdhanService] Error initializing: $e');
    }
  }

  // Play adhan based on prayer name
  Future<void> playAdhan(String prayerName) async {
    if (kIsWeb || !_isEnabled) {
      print('[AdhanService] Skipping playAdhan - Web: $kIsWeb, Enabled: $_isEnabled');
      return;
    }
    
    try {
      print('[AdhanService] Playing adhan for $prayerName prayer: $_adhanPath with volume: $_volume');
      
      // Stop any currently playing adhan
      await stopAdhan();
      
      // Play from asset
      await _audioPlayer.play(AssetSource(_adhanPath));
      print('[AdhanService] AudioPlayer playing');
    } catch (e) {
      print('[AdhanService] Error playing adhan: $e');
    }
  }

  // Stop playing adhan
  Future<void> stopAdhan() async {
    if (kIsWeb) return;
    
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('[AdhanService] Error stopping adhan: $e');
    }
  }

  // Play test adhan at specified volume
  Future<void> playAdhanTest(double volume) async {
    if (kIsWeb) return;
    
    try {
      print('[AdhanService] Playing test adhan with volume: $volume');
      
      // Stop any currently playing adhan
      await stopAdhan();
      
      // Set the volume temporarily for the test
      await _audioPlayer.setVolume(volume);
      
      // Play from asset
      await _audioPlayer.play(AssetSource(_adhanPath));
      
      // Reset to saved volume after test
      await _audioPlayer.setVolume(_volume);
      
      print('[AdhanService] Test adhan playing');
    } catch (e) {
      print('[AdhanService] Error playing test adhan: $e');
    }
  }

  // Toggle adhan on/off
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    
    print('[AdhanService] Adhan enabled set to: $enabled');
  }

  // Set adhan volume
  Future<void> setVolume(double volume) async {
    _volume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
    await _audioPlayer.setVolume(volume);
    
    print('[AdhanService] Adhan volume set to: $volume');
  }

  // Getters for current settings
  bool get isEnabled => _isEnabled;
  double get volume => _volume;
} 