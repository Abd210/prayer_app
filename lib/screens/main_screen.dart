import 'package:flutter/material.dart';
import '../theme/theme_notifier.dart';
import 'home_page.dart';
import 'azkar_page.dart';
import 'qibla_page.dart';
import 'tasbih_page.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const MainScreen({Key? key, required this.themeNotifier}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      AzkarPage(),
      const QiblaPage(),
      TasbihPage(),
      SettingsPage(themeNotifier: widget.themeNotifier),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Azkar'),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
              BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Tasbih'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
