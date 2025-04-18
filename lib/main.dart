import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'services/notification_service.dart';
import 'services/language_provider.dart';
import 'services/prayer_settings_provider.dart';
import 'theme/theme_notifier.dart';
import 'pages/splash_screen.dart';   // or MainNavScreen()

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),   // ← NEW
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
    final lang = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Advanced Islamic App',
      debugShowCheckedModeBanner: false,
      locale: lang.locale,                                   // ← NEW
      localizationsDelegates: AppLocalizations.localizationsDelegates,   // ← NEW
      supportedLocales: AppLocalizations.supportedLocales,              // ← NEW
      theme: themeNotifier.lightTheme,
      darkTheme: themeNotifier.darkTheme,
      themeMode: themeNotifier.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: MainNavScreen(),
    );
  }
}
