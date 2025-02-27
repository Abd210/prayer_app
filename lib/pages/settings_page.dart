import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_notifier.dart';
import '../services/prayer_settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool enableNotifications = true;
  bool enableDailyHadith = false;
  bool highAccuracyCalc = false;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadLocalPrefs(); // load booleans/language from SharedPreferences
  }

  Future<void> _loadLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enableNotifications = prefs.getBool('enableNotifications') ?? true;
      enableDailyHadith = prefs.getBool('enableDailyHadith') ?? false;
      highAccuracyCalc = prefs.getBool('highAccuracyCalc') ?? false;
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  Future<void> _saveLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', enableNotifications);
    await prefs.setBool('enableDailyHadith', enableDailyHadith);
    await prefs.setBool('highAccuracyCalc', highAccuracyCalc);
    await prefs.setString('selectedLanguage', selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final prayerSettings = Provider.of<PrayerSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ─────────────────────────────────────────────────────────────────────
          // APPEARANCE HEADER
          // ─────────────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),

          // DARK MODE TOGGLE
          SwitchListTile(
            title: Row(
              children: const [
                Icon(Icons.dark_mode, size: 20),
                SizedBox(width: 10),
                Text('Enable Dark Mode'),
              ],
            ),
            value: themeNotifier.isDarkTheme,
            onChanged: (val) => themeNotifier.toggleTheme(),
          ),

          // LIGHT THEME SELECTOR (only visible if dark mode is off)
          if (!themeNotifier.isDarkTheme)
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('Select App Color Theme'),
              subtitle: Text(
                'Current: Theme ${themeNotifier.selectedThemeIndex + 1}',
              ),
              onTap: _showSelectThemeDialog,
            ),

          const Divider(),

          // ─────────────────────────────────────────────────────────────────────
          // CALCULATION METHOD
          // ─────────────────────────────────────────────────────────────────────
          ListTile(
            title: const Text('Calculation Method'),
            subtitle: Text(prayerSettings.calculationMethod.name.toUpperCase()),
            onTap: _showCalculationMethodDialog,
          ),

          // MADHAB
          ListTile(
            title: const Text('Madhab'),
            subtitle: Text(prayerSettings.madhab.name.toUpperCase()),
            onTap: _showMadhabDialog,
          ),

          // 24-hour format
          SwitchListTile(
            title: const Text('Use 24-hour Format'),
            value: prayerSettings.use24hFormat,
            onChanged: (val) => prayerSettings.toggle24hFormat(val),
          ),
          const Divider(),

          // ─────────────────────────────────────────────────────────────────────
          // ENABLE NOTIFICATIONS
          // ─────────────────────────────────────────────────────────────────────
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: enableNotifications,
            onChanged: (val) {
              setState(() => enableNotifications = val);
              _saveLocalPrefs();
            },
          ),

          // ENABLE DAILY HADITH
          SwitchListTile(
            title: const Text('Enable Daily Hadith'),
            value: enableDailyHadith,
            onChanged: (val) {
              setState(() => enableDailyHadith = val);
              _saveLocalPrefs();
            },
          ),

          // HIGH ACCURACY
          SwitchListTile(
            title: const Text('High Accuracy Calculation'),
            subtitle: const Text('Adds extra location checks & fine-tuned method'),
            value: highAccuracyCalc,
            onChanged: (val) {
              setState(() => highAccuracyCalc = val);
              _saveLocalPrefs();
            },
          ),
          const Divider(),

          // LANGUAGE
          ListTile(
            title: const Text('Language'),
            subtitle: Text(selectedLanguage),
            onTap: _showLanguageDialog,
          ),

          const Divider(),
          // ABOUT
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            subtitle: const Text('Advanced Islamic App with multiple features'),
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // THEME DIALOG  (We use static colorSwatches so we don’t break immediate updates)
  // ─────────────────────────────────────────────────────────────────────────────
  void _showSelectThemeDialog() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    final chosenIndex = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose a Light Theme'),
        children: [
          // We'll show color squares from a static list:
          _themeOption(ctx, 0, 'Original Brand',  [Color(0xFF16423C), Color(0xFF6A9C89), Color(0xFFE9EFEC)]),
          _themeOption(ctx, 1, 'Soft Slate & Periwinkle', [Color(0xFF5B6EAE), Color(0xFFA8B9EE), Color(0xFFF2F2F7)]),
          _themeOption(ctx, 2, 'Teal & Orange',   [Color(0xFF009688), Color(0xFFFF9800), Color(0xFFF9FAFB)]),
          _themeOption(ctx, 3, 'Lilac & Deep Purple', [Color(0xFF7E57C2), Color(0xFFD1B2FF), Color(0xFFF6F2FB)]),
          _themeOption(ctx, 4, 'Warm Beige & Brown',   [Color(0xFFA38671), Color(0xFFD7C3B5), Color(0xFFFAF2EB)]),
          _themeOption(ctx, 5, 'Midnight Blue & Soft Gold', [Color(0xFF243B55), Color(0xFFFFD966), Color(0xFFFDFCF7)]),
        ],
      ),
    );
    if (chosenIndex != null) {
      // Immediately apply the selected theme
      themeNotifier.setThemeIndex(chosenIndex);
      // Now the app theme changes at once, no need to exit or reopen
    }
  }

  Widget _themeOption(BuildContext ctx, int index, String label, List<Color> swatches) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, index),
      child: Row(
        children: [
          _colorBox(swatches[0]),
          const SizedBox(width: 4),
          _colorBox(swatches[1]),
          const SizedBox(width: 4),
          _colorBox(swatches[2]),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  Widget _colorBox(Color c) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CALCULATION METHOD
  // ─────────────────────────────────────────────────────────────────────────────
  void _showCalculationMethodDialog() async {
    final prayerSettings = Provider.of<PrayerSettingsProvider>(context, listen: false);

    final chosenMethod = await showDialog<CalculationMethod>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Calculation Method'),
        children: [
          _methodOption(ctx, 'Muslim World League', CalculationMethod.muslim_world_league),
          _methodOption(ctx, 'Egyptian', CalculationMethod.egyptian),
          _methodOption(ctx, 'Karachi', CalculationMethod.karachi),
          _methodOption(ctx, 'Umm al-Qura', CalculationMethod.umm_al_qura),
          _methodOption(ctx, 'Moonsighting Committee', CalculationMethod.moon_sighting_committee),
          _methodOption(ctx, 'North America (ISNA)', CalculationMethod.north_america),
          _methodOption(ctx, 'Dubai', CalculationMethod.dubai),
          _methodOption(ctx, 'Qatar', CalculationMethod.qatar),
          _methodOption(ctx, 'Kuwait', CalculationMethod.kuwait),
          _methodOption(ctx, 'Turkey', CalculationMethod.turkey),
          _methodOption(ctx, 'Tehran', CalculationMethod.tehran),
          _methodOption(ctx, 'Other', CalculationMethod.other),
        ],
      ),
    );
    if (chosenMethod != null) {
      prayerSettings.updateCalculationMethod(chosenMethod);
    }
  }

  SimpleDialogOption _methodOption(BuildContext ctx, String label, CalculationMethod method) {
    return SimpleDialogOption(
      child: Text(label),
      onPressed: () => Navigator.pop(ctx, method),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MADHAB
  // ─────────────────────────────────────────────────────────────────────────────
  void _showMadhabDialog() async {
    final prayerSettings = Provider.of<PrayerSettingsProvider>(context, listen: false);

    final chosenMadhab = await showDialog<Madhab>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Madhab'),
        children: [
          SimpleDialogOption(
            child: const Text('Shafi'),
            onPressed: () => Navigator.pop(ctx, Madhab.shafi),
          ),
          SimpleDialogOption(
            child: const Text('Hanafi'),
            onPressed: () => Navigator.pop(ctx, Madhab.hanafi),
          ),
        ],
      ),
    );
    if (chosenMadhab != null) {
      prayerSettings.updateMadhab(chosenMadhab);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LANGUAGE
  // ─────────────────────────────────────────────────────────────────────────────
  void _showLanguageDialog() async {
    final chosenLang = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          SimpleDialogOption(
            child: const Text('English'),
            onPressed: () => Navigator.pop(ctx, 'English'),
          ),
          SimpleDialogOption(
            child: const Text('Arabic'),
            onPressed: () => Navigator.pop(ctx, 'Arabic'),
          ),
          SimpleDialogOption(
            child: const Text('French'),
            onPressed: () => Navigator.pop(ctx, 'French'),
          ),
        ],
      ),
    );
    if (chosenLang != null) {
      setState(() => selectedLanguage = chosenLang);
      _saveLocalPrefs();
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Advanced Islamic App',
      applicationVersion: '2.0.0',
      children: const [
        Text(
          'This app provides advanced features for prayer times, Azkār, '
          'Qibla, Tasbih, and more.',
        ),
      ],
    );
  }
}
