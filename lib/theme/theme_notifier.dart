import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Your original brand colors
const Color kDarkGreen = Color(0xFF16423C);
const Color kMintGreen = Color(0xFF6A9C89);
const Color kLightGreen = Color(0xFFC4DAD2);
const Color kOffWhite = Color(0xFFE9EFEC);

///
/// A notifier that toggles between dark mode, multiple custom light themes,
/// and a user-defined "Custom Theme." The user’s selected colors are saved in
/// SharedPreferences so they persist across app launches.
///
class ThemeNotifier extends ChangeNotifier {
  // Tracks whether we are in dark mode
  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;

  // Which "light theme" index is selected: 0..8
  // (0..7 => predefined, 8 => Custom Theme)
  int _selectedThemeIndex = 0;
  int get selectedThemeIndex => _selectedThemeIndex;

  // For the custom theme, we store 4 colors:
  // primary, secondary, background, surface
  // (the user picks them in settings)
  Color _customPrimary = Colors.blue;
  Color _customSecondary = Colors.orange;
  Color _customBackground = Colors.white;
  Color _customSurface = Colors.grey.shade300;

  Color get customPrimary => _customPrimary;
  Color get customSecondary => _customSecondary;
  Color get customBackground => _customBackground;
  Color get customSurface => _customSurface;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _selectedThemeIndex = prefs.getInt('selectedThemeIndex') ?? 0;

    // Load custom theme colors
    final cp = prefs.getInt('customPrimary') ?? Colors.blue.value;
    final cs = prefs.getInt('customSecondary') ?? Colors.orange.value;
    final cbg = prefs.getInt('customBackground') ?? Colors.white.value;
    final csf = prefs.getInt('customSurface') ?? Colors.grey.shade300.value;

    _customPrimary = Color(cp);
    _customSecondary = Color(cs);
    _customBackground = Color(cbg);
    _customSurface = Color(csf);

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setInt('selectedThemeIndex', _selectedThemeIndex);

    // Save custom colors
    await prefs.setInt('customPrimary', _customPrimary.value);
    await prefs.setInt('customSecondary', _customSecondary.value);
    await prefs.setInt('customBackground', _customBackground.value);
    await prefs.setInt('customSurface', _customSurface.value);
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    _saveToPrefs();
  }

  /// Switch to one of the 9 "light themes":
  /// 0..7 => Predefined, 8 => custom
  void setThemeIndex(int index) {
    _selectedThemeIndex = index;
    _isDarkTheme = false;
    notifyListeners();
    _saveToPrefs();
  }

  /// Update the custom theme colors and switch to "Custom" theme
  void setCustomThemeColors({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
  }) {
    _customPrimary = primary;
    _customSecondary = secondary;
    _customBackground = background;
    _customSurface = surface;

    _selectedThemeIndex = 8; // index 8 => "Custom"
    _isDarkTheme = false;
    notifyListeners();
    _saveToPrefs();
  }

  /// Provide the currently selected Light Theme
  ThemeData get lightTheme {
    switch (_selectedThemeIndex) {
      case 0:
        return _originalLightTheme;
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
      case 6:
        return _lightTheme6;
      case 7:
        return _lightTheme7;
      case 8:
        return _customTheme;
      default:
        return _originalLightTheme;
    }
  }

  /// Provide the Dark Theme
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        // Use a lighter hue for the primary color so that widgets that
        // paint themselves using `colorScheme.primary` (for example many
        // `Icon` and `Text` instances across the app) remain legible on the
        // near-black scaffold background.
        primaryColor: kMintGreen,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: kMintGreen,
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
  // 0) ORIGINAL LIGHT THEME
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
  // 1) Soft Slate & Periwinkle
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme1 {
    // Soothing Ocean Breeze - Soft blues with warm undertones
    const colBG = Color(0xFFF8FAFC);
    const colPrimary = Color(0xFF4A90E2);
    const colSecondary = Color(0xFF7BB3F0);
    const colOnDark = Color(0xFF2C3E50);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: colPrimary,
      scaffoldBackgroundColor: colBG,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colPrimary,
        onPrimary: Colors.white,
        secondary: colSecondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: colBG,
        onBackground: colOnDark,
        surface: const Color(0xFFE3F2FD),
        onSurface: colOnDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2) Teal & Orange
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme2 {
    // Nature Harmony - Balanced teal and coral
    const background = Color(0xFFF7FDFC);
    const primary = Color(0xFF00897B);
    const secondary = Color(0xFFFF7043);
    const onDark = Color(0xFF263238);

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
        surface: const Color(0xFFE0F2F1),
        onSurface: onDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3) Lilac & Deep Purple
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme3 {
    // Lavender Dreams - Soft purple with gentle contrast
    const background = Color(0xFFFAF8FF);
    const primary = Color(0xFF6A4C93);
    const secondary = Color(0xFFB39DDB);
    const onDark = Color(0xFF3E2723);

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
        surface: const Color(0xFFF3E5F5),
        onSurface: onDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4) Warm Beige & Brown
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme4 {
    // Desert Sunset - Warm earth tones with better contrast
    const background = Color(0xFFFDFBF7);
    const primary = Color(0xFF8D6E63);
    const secondary = Color(0xFFBCAAA4);
    const onDark = Color(0xFF3E2723);

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
        surface: const Color(0xFFEFEBE9),
        onSurface: onDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5) Midnight Blue & Soft Gold
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme5 {
    const background = Color(0xFFFDFCF7);
    const primary = Color(0xFF243B55);
    const secondary = Color(0xFFFFD966);
    const onDark = Color(0xFF2F2F2F);

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

  // ─────────────────────────────────────────────────────────────────────────────
  // 6) #7D0A0A (primary), #BF3131 (secondary), #EAD196 (surface), #F3EDC8 (bg)
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme6 {
    // Autumn Warmth - Rich burgundy with golden accents
    const colPrimary = Color(0xFF8E24AA);
    const colSecondary = Color(0xFFE1BEE7);
    const colSurface = Color(0xFFF3E5F5);
    const colBackground = Color(0xFFFAF8FF);
    const colOnDark = Color(0xFF2D1B69);

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
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: colBackground,
        onBackground: colOnDark,
        surface: colSurface,
        onSurface: colOnDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 7) #AC1754 (primary), #E53888 (secondary), #F37199 (surface), #F7A8C4 (bg)
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _lightTheme7 {
    // Rose Garden - Elegant pink with mint accents
    const colPrimary = Color(0xFFAD1457);
    const colSecondary = Color(0xFF81C784);
    const colSurface = Color(0xFFE8F5E8);
    const colBackground = Color(0xFFF8FDF8);
    const colOnDark = Color(0xFF1B5E20);

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
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: colBackground,
        onBackground: colOnDark,
        surface: colSurface,
        onSurface: colOnDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 8) CUSTOM THEME (User picks the 4 colors)
  // ─────────────────────────────────────────────────────────────────────────────
  ThemeData get _customTheme {
    // Ensure proper contrast by calculating appropriate onBackground color
    Color onBackgroundColor = _calculateContrastColor(_customBackground);
    Color onSurfaceColor = _calculateContrastColor(_customSurface);
    
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _customPrimary,
      scaffoldBackgroundColor: _customBackground,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _customPrimary,
        onPrimary: Colors.white,
        secondary: _customSecondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: _customBackground,
        onBackground: onBackgroundColor,
        surface: _customSurface,
        onSurface: onSurfaceColor,
      ),
    );
  }
  
  /// Calculate appropriate contrast color for text/icons based on background
  Color _calculateContrastColor(Color backgroundColor) {
    // Calculate luminance of background color
    double luminance = backgroundColor.computeLuminance();
    
    // If background is light (high luminance), use dark text
    // If background is dark (low luminance), use light text
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
