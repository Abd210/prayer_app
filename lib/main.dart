import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer/generated/l10n/app_localizations.dart';

import 'services/notification_service.dart';
import 'services/language_provider.dart';
import 'services/prayer_settings_provider.dart';
import 'services/azkar_reminder_service.dart';
import 'theme/theme_notifier.dart';
import 'pages/splash_screen.dart';   // or MainNavScreen()

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Request notification permission on Android
  if (!kIsWeb) {
    await requestNotificationPermission();
  }

  await NotificationService().init();
  await AzkarReminderService().init();
  
  // Reschedule notifications on startup in case app was force-closed
  await NotificationService().rescheduleNotificationsOnStartup();
  
  // Check if app was closed for more than a day and reschedule if needed
  await _checkLongTermClosure();

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

Future<void> _checkLongTermClosure() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastAppCloseTime = prefs.getInt('lastAppCloseTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // If app was closed for more than 12 hours, force reschedule notifications
    const twelveHoursMs = 12 * 60 * 60 * 1000;
    
    if (currentTime - lastAppCloseTime > twelveHoursMs) {
      print('[Main] App was closed for more than 12 hours, forcing notification reschedule');
      await NotificationService().forceRescheduleNotifications();
    }
    
    // Save current time as last app close time
    await prefs.setInt('lastAppCloseTime', currentTime);
    
  } catch (e) {
    print('[Main] Error checking long term closure: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      // App is being closed, save the time
      _saveAppCloseTime();
    }
  }

  Future<void> _saveAppCloseTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('lastAppCloseTime', currentTime);
      print('[Main] App close time saved: $currentTime');
    } catch (e) {
      print('[Main] Error saving app close time: $e');
    }
  }

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
