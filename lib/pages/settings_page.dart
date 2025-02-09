import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import '../theme/theme_notifier.dart';
import '../services/prayer_settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// A more advanced Settings page:
///  - Dark Theme toggle
///  - Calculation Method
///  - Madhab
///  - 24h Format
///  - Enable Notifications
///  - Enable Daily Hadith
///  - High Accuracy Calculation
///  - Language Selection, etc.
class _SettingsPageState extends State<SettingsPage> {
  bool enableNotifications = true;
  bool enableDailyHadith = false;
  bool highAccuracyCalc = false;
  String selectedLanguage = 'English';

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
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: themeNotifier.isDarkTheme,
            onChanged: (val) => themeNotifier.toggleTheme(),
          ),
          ListTile(
            title: const Text('Calculation Method'),
            subtitle: Text(prayerSettings.calculationMethod.name.toUpperCase()),
            onTap: _showCalculationMethodDialog,
          ),
          ListTile(
            title: const Text('Madhab'),
            subtitle: Text(prayerSettings.madhab.name.toUpperCase()),
            onTap: _showMadhabDialog,
          ),
          SwitchListTile(
            title: const Text('Use 24-hour Format'),
            value: prayerSettings.use24hFormat,
            onChanged: (val) => prayerSettings.toggle24hFormat(val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: enableNotifications,
            onChanged: (val) {
              setState(() => enableNotifications = val);
              // Save in SharedPrefs or backend if needed
            },
          ),
          SwitchListTile(
            title: const Text('Enable Daily Hadith'),
            value: enableDailyHadith,
            onChanged: (val) {
              setState(() => enableDailyHadith = val);
            },
          ),
          SwitchListTile(
            title: const Text('High Accuracy Calculation'),
            subtitle: const Text('Adds extra location checks & fine-tuned method'),
            value: highAccuracyCalc,
            onChanged: (val) {
              setState(() => highAccuracyCalc = val);
              // do any logic if you want
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(selectedLanguage),
            onTap: _showLanguageDialog,
          ),
          const Divider(),
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
      // store or apply language logic
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Advanced Islamic App',
      applicationVersion: '2.0.0',
      children: const [
        Text('This app provides advanced features for prayer times, Azkār, Qibla, Tasbih, and more.'),
      ],
    );
  }
}
