import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'pages/splash_screen.dart'; // Replace with your starting page if needed
import 'package:provider/provider.dart';
import 'services/prayer_settings_provider.dart';
import 'theme/theme_notifier.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the notification service
  await NotificationService().init();

  // Initialize background notification handling
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('Notification tapped with payload: ${response.payload}');
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

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

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  // Handle background notification tap if needed.
  print('Headless notification tapped: ${response.payload}');
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
      home: const MainNavScreen(), // Replace with your main navigation screen widget
    );
  }
}
