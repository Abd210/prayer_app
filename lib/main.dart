import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_notifier.dart';
import 'providers/prayer_settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/home_page.dart';
import 'screens/qibla_page.dart' as qibla;
import 'screens/settings_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => PrayerSettingsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced Islamic App',
      theme: themeNotifier.isDarkTheme
          ? themeNotifier.darkTheme
          : themeNotifier.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(themeNotifier: themeNotifier),
        '/main': (context) => MainScreen(themeNotifier: themeNotifier),
        '/home': (context) => HomePage(),
        '/qibla': (context) => qibla.QiblaPage(),
        '/settings': (context) => SettingsPage(themeNotifier: themeNotifier),
      },
    );
  }
}
