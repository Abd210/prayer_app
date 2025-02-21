import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'pages/splash_screen.dart'; // or your starting page
import 'package:provider/provider.dart';
import 'services/prayer_settings_provider.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => PrayerSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

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
      home: const MainNavScreen(), // your main navigation screen
    );
  }
}
