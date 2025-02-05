import 'package:flutter/material.dart';
import 'theme/theme_notifier.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Advanced Islamic App',
          theme: _themeNotifier.isDarkTheme ? _themeNotifier.darkTheme : _themeNotifier.lightTheme,
          home: SplashScreen(themeNotifier: _themeNotifier),
        );
      },
    );
  }
}
