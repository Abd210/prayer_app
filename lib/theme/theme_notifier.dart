import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Your original brand colors
const Color kDarkGreen = Color(0xFF16423C);
const Color kMintGreen = Color(0xFF6A9C89);
const Color kLightGreen = Color(0xFFC4DAD2);
const Color kOffWhite = Color(0xFFE9EFEC);

///
/// A notifier that toggles between dark mode and multiple light themes.
/// Also loads/saves theme choice to SharedPreferences.
///
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;

  // Tracks which "light theme" index is currently selected: 0..5
  int _selectedThemeIndex = 0;
  int get selectedThemeIndex => _selectedThemeIndex;

  /// On creation, load from SharedPreferences:
  ThemeNotifier() {
    _loadFromPrefs();
  }

  /// Async: get saved values, then notify listeners so the UI updates.
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _selectedThemeIndex = prefs.getInt('selectedThemeIndex') ?? 0;
    notifyListeners();
  }

  /// Save current theme selections to SharedPreferences:
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setInt('selectedThemeIndex', _selectedThemeIndex);
  }

  /// Toggle between dark mode and light mode
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    _saveToPrefs(); // persist changes
  }

  /// Choose which of the 6 light themes to use
  void setThemeIndex(int index) {
    _selectedThemeIndex = index;
    _isDarkTheme = false; // forcibly switch to light mode
    notifyListeners();
    _saveToPrefs();
  }

  ///
  /// Return whichever light theme is currently selected
  ///
  ThemeData get lightTheme {
    switch (_selectedThemeIndex) {
      case 0:
        return _originalLightTheme; // your brand default
      case 1:
        return _lightTheme1;
      case 2:
        return _lightTheme2;
      case 3:
        return _lightTheme3;
      case 4:
        return _lightTheme4;
      case 5:
        return _lightTheme5;
      default:
        return _originalLightTheme;
    }
  }

  ///
  /// Dark theme remains your original code
  ///
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: kDarkGreen,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: kDarkGreen,
          onPrimary: kOffWhite,
          secondary: kMintGreen,
          onSecondary: Colors.black,
          error: Colors.redAccent,
          onError: Colors.white,
          background: Colors.black87,
          onBackground: kOffWhite,
          surface: kDarkGreen,
          onSurface: Colors.white,
        ),
        fontFamily: 'Roboto',
      );

  // ─────────────────────────────────────────────────────────────────────────────
  //  0) ORIGINAL LIGHT THEME (Default)
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _originalLightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: kDarkGreen,
        scaffoldBackgroundColor: kOffWhite,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: kDarkGreen,
          onPrimary: Colors.white,
          secondary: kMintGreen,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: kOffWhite,
          onBackground: kDarkGreen,
          surface: kLightGreen,
          onSurface: kDarkGreen,
        ),
        fontFamily: 'Roboto',
      );

  // ─────────────────────────────────────────────────────────────────────────────
  //  1) LIGHT THEME #1: Soft Slate & Periwinkle
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme1 {
    const Color colBackground = Color(0xFFF2F2F7); 
    const Color colPrimary    = Color(0xFF5B6EAE); 
    const Color colSecondary  = Color(0xFFA8B9EE); 
    const Color colOnDark     = Color(0xFF2A2A2A); 

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: colPrimary,
      scaffoldBackgroundColor: colBackground,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colPrimary,
        onPrimary: Colors.white,
        secondary: colSecondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: colBackground,
        onBackground: colOnDark,
        surface: colSecondary,
        onSurface: colOnDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  2) LIGHT THEME #2: Teal & Orange
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme2 {
    const background = Color(0xFFF9FAFB);
    const primary    = Color(0xFF009688); // teal
    const secondary  = Color(0xFFFF9800); // orange
    const onDark     = Color(0xFF333333);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: background,
        onBackground: onDark,
        surface: const Color(0xFFBBE6E3), 
        onSurface: onDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  3) LIGHT THEME #3: Lilac & Deep Purple
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme3 {
    const background = Color(0xFFF6F2FB);
    const primary    = Color(0xFF7E57C2); 
    const secondary  = Color(0xFFD1B2FF); 
    const onDark     = Color(0xFF4E2E73);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: background,
        onBackground: onDark,
        surface: const Color(0xFFE9DDFA),
        onSurface: onDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  4) LIGHT THEME #4: Warm Beige & Brown
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme4 {
    const background = Color(0xFFFAF2EB);
    const primary    = Color(0xFFA38671);
    const secondary  = Color(0xFFD7C3B5);
    const onDark     = Color(0xFF3F2D23);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: background,
        onBackground: onDark,
        surface: const Color(0xFFEBDDCB),
        onSurface: onDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  5) LIGHT THEME #5: Midnight Blue & Soft Gold
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme5 {
    const background = Color(0xFFFDFCF7);
    const primary    = Color(0xFF243B55);
    const secondary  = Color(0xFFFFD966);
    const onDark     = Color(0xFF2F2F2F);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: background,
        onBackground: onDark,
        surface: const Color(0xFFE3E0D3),
        onSurface: onDark,
      ),
    );
  }
}
