import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/theme_notifier.dart';
import 'services/prayer_settings_provider.dart';
import 'pages/splash_screen.dart';
import 'package:provider/provider.dart';

/// Main entry point of the Flutter app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optionally load anything else (like SharedPrefs) here if needed.

  runApp(
    /// We provide both the ThemeNotifier and PrayerSettingsProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => PrayerSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget that reads theme and navigates to SplashScreen first.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Advanced Islamic App',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.lightTheme,
      darkTheme: themeNotifier.darkTheme,
      themeMode: themeNotifier.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
