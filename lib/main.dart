import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'services/notification_service.dart';
import 'services/language_provider.dart';
import 'services/prayer_settings_provider.dart';
import 'services/analytics_service.dart';
import 'services/compass_service.dart';
import 'services/azkar_reminder_service.dart';
import 'theme/theme_notifier.dart';
import 'pages/splash_screen.dart';   // or MainNavScreen()
import 'pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize analytics service
  await AnalyticsService().init();
  
  /// Initialize compass service
  await CompassService().init();

  /// Request notification permission on Android
  if (!kIsWeb) {
    await requestNotificationPermission();
  }

  await NotificationService().init();
  
  /// Initialize azkar reminder service
  await AzkarReminderService.init();

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

Future<void> requestNotificationPermission() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final prayerSettings = Provider.of<PrayerSettingsProvider>(context);

    return MaterialApp(
      title: 'Advanced Islamic App',
      debugShowCheckedModeBanner: false,
      locale: lang.locale,                                   // ← NEW
      localizationsDelegates: AppLocalizations.localizationsDelegates,   // ← NEW
      supportedLocales: AppLocalizations.supportedLocales,              // ← NEW
      theme: themeNotifier.lightTheme,
      darkTheme: themeNotifier.darkTheme,
      themeMode: themeNotifier.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: FutureBuilder<bool>(
        future: prayerSettings.isFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final isFirstTime = snapshot.data ?? true;
          
          if (isFirstTime) {
            return const OnboardingPage();
          } else {
            return const MainNavScreen();
          }
        },
      ),
    );
  }
}
