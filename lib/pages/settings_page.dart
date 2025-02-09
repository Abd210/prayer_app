import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import '../theme/theme_notifier.dart';
import '../services/prayer_settings_provider.dart';
import '../services/user_settings_provider.dart';

/// A more advanced Settings page that:
///  - Actually reads/writes to SharedPreferences via UserSettingsProvider
///  - Toggles dark theme, 24-hour format, high-accuracy location, fallback IP
///  - Lets user optionally enter a Google API key for an extra geocoding fallback
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // If needed, do initial loads or refresh from the provider
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final prayerSettings = Provider.of<PrayerSettingsProvider>(context);
    final userSettings = Provider.of<UserSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings - Advanced'),
      ),
      body: ListView(
        children: [
          // Dark Theme
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: themeNotifier.isDarkTheme,
            onChanged: (val) {
              themeNotifier.toggleTheme();
            },
          ),

          // Adhan Calculation Method
          ListTile(
            title: const Text('Calculation Method'),
            subtitle: Text(prayerSettings.calculationMethod.name.toUpperCase()),
            onTap: _showCalculationMethodDialog,
          ),

          // Madhab
          ListTile(
            title: const Text('Madhab'),
            subtitle: Text(prayerSettings.madhab.name.toUpperCase()),
            onTap: _showMadhabDialog,
          ),

          // 24h format
          SwitchListTile(
            title: const Text('Use 24-hour Format'),
            value: prayerSettings.use24hFormat,
            onChanged: (val) => prayerSettings.toggle24hFormat(val),
          ),

          const Divider(),

          // High Accuracy location
          SwitchListTile(
            title: const Text('High Accuracy Location'),
            subtitle: const Text('Requests fine location, might drain battery more'),
            value: userSettings.highAccuracyLocation,
            onChanged: (val) => userSettings.setHighAccuracy(val),
          ),

          // Fallback IP
          SwitchListTile(
            title: const Text('Fallback IP Geolocation'),
            subtitle: const Text('Try IP-based city if local geocoding fails'),
            value: userSettings.fallbackIP,
            onChanged: (val) => userSettings.setFallbackIP(val),
          ),

          // Google API key
          ListTile(
            title: const Text('Google Geocoding API Key'),
            subtitle: Text(
              userSettings.googleApiKey.isEmpty
                  ? 'Not Set'
                  : '****** (Tap to Edit)',
            ),
            onTap: _showGoogleApiKeyDialog,
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            subtitle: const Text('An advanced Islamic app with many features'),
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

  void _showGoogleApiKeyDialog() async {
    final userSettings = Provider.of<UserSettingsProvider>(context, listen: false);
    final controller = TextEditingController(text: userSettings.googleApiKey);

    final newKey = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter Google Geocoding API Key'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'API Key'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (newKey != null) {
      userSettings.setGoogleApiKey(newKey);
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Advanced Islamic App',
      applicationVersion: '2.5.0',
      children: const [
        Text(
          'This app provides advanced prayer times, Azkār, Qibla, Tasbih, and more.'
          'Now with robust settings that actually save via SharedPreferences!',
        ),
      ],
    );
  }
}
