import 'package:flutter/material.dart';
import '../theme/theme_notifier.dart';
import 'home_page.dart';
import 'qibla_page.dart' as qibla;
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const MainScreen({Key? key, required this.themeNotifier}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Build the list of pages. The SettingsPage is passed the theme notifier.
    final pages = [
      HomePage(),
      qibla.QiblaPage(),
      SettingsPage(themeNotifier: widget.themeNotifier),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Prayer Times'),
          BottomNavigationBarItem(
              icon: Icon(Icons.compass_calibration), label: 'Qibla'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
