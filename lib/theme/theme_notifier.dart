import 'package:flutter/material.dart';

/// Example brand colors (customize as needed)
const Color kDarkGreen = Color(0xFF16423C);
const Color kMintGreen = Color(0xFF6A9C89);
const Color kLightGreen = Color(0xFFC4DAD2);
const Color kOffWhite = Color(0xFFE9EFEC);

/// Notifier that toggles between light and dark themes.
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: kDarkGreen,
        scaffoldBackgroundColor: kOffWhite,
        colorScheme: ColorScheme(
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

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: kDarkGreen,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme(
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
}
