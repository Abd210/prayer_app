import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../theme/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const SettingsPage({Key? key, required this.themeNotifier}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PrayerSettings _prayerSettings = PrayerSettings(
    calculationMethod: CalculationMethod.muslim_world_league,
    madhab: Madhab.shafi,
    use24hFormat: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            SwitchListTile(
              activeColor: theme.colorScheme.primary,
              title: Text('Dark Theme', style: TextStyle(color: theme.colorScheme.onBackground)),
              value: widget.themeNotifier.isDarkTheme,
              onChanged: (val) {
                widget.themeNotifier.toggleTheme();
                setState(() {});
              },
            ),
            ListTile(
              title: Text('Calculation Method', style: TextStyle(color: theme.colorScheme.onBackground)),
              subtitle: Text(
                'Current: ${_prayerSettings.calculationMethod.name.toUpperCase()}',
                style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onBackground.withOpacity(0.7)),
              onTap: _showCalculationMethodDialog,
            ),
            ListTile(
              title: Text('Madhab', style: TextStyle(color: theme.colorScheme.onBackground)),
              subtitle: Text(
                _prayerSettings.madhab.name.toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onBackground.withOpacity(0.7)),
              onTap: _showMadhabDialog,
            ),
            SwitchListTile(
              activeColor: theme.colorScheme.primary,
              title: Text('Use 24-hour format', style: TextStyle(color: theme.colorScheme.onBackground)),
              value: _prayerSettings.use24hFormat,
              onChanged: (val) {
                setState(() {
                  _prayerSettings.use24hFormat = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCalculationMethodDialog() async {
    final selectedMethod = await showDialog<CalculationMethod>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Calculation Method'),
        children: [
          SimpleDialogOption(child: const Text('Muslim World League'), onPressed: () => Navigator.pop(ctx, CalculationMethod.muslim_world_league)),
          SimpleDialogOption(child: const Text('Egyptian'), onPressed: () => Navigator.pop(ctx, CalculationMethod.egyptian)),
          SimpleDialogOption(child: const Text('Karachi'), onPressed: () => Navigator.pop(ctx, CalculationMethod.karachi)),
          SimpleDialogOption(child: const Text('Umm al-Qura'), onPressed: () => Navigator.pop(ctx, CalculationMethod.umm_al_qura)),
          SimpleDialogOption(child: const Text('Moonsighting Committee'), onPressed: () => Navigator.pop(ctx, CalculationMethod.moon_sighting_committee)),
          SimpleDialogOption(child: const Text('North America (ISNA)'), onPressed: () => Navigator.pop(ctx, CalculationMethod.north_america)),
        ],
      ),
    );
    if (selectedMethod != null) {
      setState(() {
        _prayerSettings.calculationMethod = selectedMethod;
      });
    }
  }

  void _showMadhabDialog() async {
    final selectedMadhab = await showDialog<Madhab>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Madhab'),
        children: [
          SimpleDialogOption(child: const Text('Shafi'), onPressed: () => Navigator.pop(ctx, Madhab.shafi)),
          SimpleDialogOption(child: const Text('Hanafi'), onPressed: () => Navigator.pop(ctx, Madhab.hanafi)),
        ],
      ),
    );
    if (selectedMadhab != null) {
      setState(() {
        _prayerSettings.madhab = selectedMadhab;
      });
    }
  }
}

class PrayerSettings {
  CalculationMethod calculationMethod;
  Madhab madhab;
  bool use24hFormat;
  PrayerSettings({
    required this.calculationMethod,
    required this.madhab,
    required this.use24hFormat,
  });
}
