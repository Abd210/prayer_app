import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // for custom theme color picks

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

  /// A static map of "preview swatches" for each theme index (0..7),
  /// so we don't have to do the "temp set" approach. This is simpler
  /// and ensures the final theme doesn't revert.
  static final Map<int, List<Color>> _themeSwatchMap = {
    /// 0: Original brand
    0: [
      Color(0xFF16423C), // primary
      Color(0xFF6A9C89), // secondary
      Color(0xFFE9EFEC), // background
    ],
    /// 1: Soft Slate & Periwinkle
    1: [
      Color(0xFF5B6EAE),
      Color(0xFFA8B9EE),
      Color(0xFFF2F2F7),
    ],
    /// 2: Teal & Orange
    2: [
      Color(0xFF009688),
      Color(0xFFFF9800),
      Color(0xFFF9FAFB),
    ],
    /// 3: Lilac & Deep Purple
    3: [
      Color(0xFF7E57C2),
      Color(0xFFD1B2FF),
      Color(0xFFF6F2FB),
    ],
    /// 4: Warm Beige & Brown
    4: [
      Color(0xFFA38671),
      Color(0xFFD7C3B5),
      Color(0xFFFAF2EB),
    ],
    /// 5: Midnight Blue & Soft Gold
    5: [
      Color(0xFF243B55),
      Color(0xFFFFD966),
      Color(0xFFFDFCF7),
    ],
    /// 6: #7D0A0A & #BF3131
    6: [
      Color(0xFF7D0A0A),
      Color(0xFFBF3131),
      Color(0xFFF3EDC8), // from the logic or combos
    ],
    /// 7: #AC1754 & #E53888
    7: [
      Color(0xFFAC1754),
      Color(0xFFE53888),
      Color(0xFFF7A8C4),
    ],
    // index 8 => custom, we handle dynamically
  };

  @override
  void initState() {
    super.initState();
    _loadLocalPrefs();
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
          // APPEARANCE
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

          if (!themeNotifier.isDarkTheme)
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('Select App Color Theme'),
              subtitle: Row(
                children: [
                  Text(
                    'Current: Theme ${themeNotifier.selectedThemeIndex + 1}',
                  ),
                  const SizedBox(width: 8),
                  // Show color squares for the current theme
                  ..._themePreviewSwatches(themeNotifier.selectedThemeIndex, themeNotifier),
                ],
              ),
              onTap: _showSelectThemeDialog,
            ),
          const Divider(),

          // ─────────────────────────────────────────────────────────────────────
          // PRAYER SETTINGS
          // ─────────────────────────────────────────────────────────────────────
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

          // ─────────────────────────────────────────────────────────────────────
          // NOTIFICATIONS, HADITH, ACCURACY
          // ─────────────────────────────────────────────────────────────────────
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: enableNotifications,
            onChanged: (val) {
              setState(() => enableNotifications = val);
              _saveLocalPrefs();
            },
          ),
          SwitchListTile(
            title: const Text('Enable Daily Hadith'),
            value: enableDailyHadith,
            onChanged: (val) {
              setState(() => enableDailyHadith = val);
              _saveLocalPrefs();
            },
          ),
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

          // ─────────────────────────────────────────────────────────────────────
          // LANGUAGE
          // ─────────────────────────────────────────────────────────────────────
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
  // THEME SELECTION DIALOG
  // ─────────────────────────────────────────────────────────────────────────────
  void _showSelectThemeDialog() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    final chosenIndex = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose a Light Theme'),
        children: [
          _themeOption(ctx, 0, 'Original Brand', themeNotifier),
          _themeOption(ctx, 1, 'Soft Slate & Periwinkle', themeNotifier),
          _themeOption(ctx, 2, 'Teal & Orange', themeNotifier),
          _themeOption(ctx, 3, 'Lilac & Deep Purple', themeNotifier),
          _themeOption(ctx, 4, 'Warm Beige & Brown', themeNotifier),
          _themeOption(ctx, 5, 'Midnight Blue & Soft Gold', themeNotifier),
          _themeOption(ctx, 6, '#7D0A0A & #BF3131', themeNotifier),
          _themeOption(ctx, 7, '#AC1754 & #E53888', themeNotifier),
          _themeOption(ctx, 8, 'Custom Theme', themeNotifier),
        ],
      ),
    );
    if (chosenIndex != null) {
      if (chosenIndex == 8) {
        // custom
        _showCustomThemeDialog();
      } else {
        themeNotifier.setThemeIndex(chosenIndex);
      }
    }
  }

  SimpleDialogOption _themeOption(
      BuildContext ctx, int index, String label, ThemeNotifier themeNotifier) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, index),
      child: Row(
        children: [
          ..._themePreviewSwatches(index, themeNotifier),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  /// Instead of "temp setThemeIndex," we use a static map for (0..7).
  /// For custom (8), we show user-chosen colors from themeNotifier.
  List<Widget> _themePreviewSwatches(int index, ThemeNotifier themeNotifier) {
    if (index == 8) {
      // Custom => 4 squares
      final custom = [
        themeNotifier.customPrimary,
        themeNotifier.customSecondary,
        themeNotifier.customBackground,
        themeNotifier.customSurface,
      ];
      return custom
          .map((c) => Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black12),
                ),
              ))
          .toList();
    } else {
      // Predefined => fetch from static map
      final list = _themeSwatchMap[index] ?? [Colors.grey, Colors.grey, Colors.white];
      return list
          .map((c) => Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black12),
                ),
              ))
          .toList();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CUSTOM THEME DIALOG
  // ─────────────────────────────────────────────────────────────────────────────
  void _showCustomThemeDialog() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    // current
    Color p = themeNotifier.customPrimary;
    Color s = themeNotifier.customSecondary;
    Color b = themeNotifier.customBackground;
    Color f = themeNotifier.customSurface;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Your Own Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Column(
                    children: [
                      _colorPickerRow('Primary', p, (c) => setState(() => p = c)),
                      const SizedBox(height: 12),
                      _colorPickerRow('Secondary', s, (c) => setState(() => s = c)),
                      const SizedBox(height: 12),
                      _colorPickerRow('Background', b, (c) => setState(() => b = c)),
                      const SizedBox(height: 12),
                      _colorPickerRow('Surface', f, (c) => setState(() => f = c)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('CANCEL'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    ElevatedButton(
                      child: const Text('SAVE'),
                      onPressed: () {
                        themeNotifier.setCustomThemeColors(
                          primary: p,
                          secondary: s,
                          background: b,
                          surface: f,
                        );
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorPickerRow(String label, Color initial, ValueChanged<Color> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: initial,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 6),
        ElevatedButton.icon(
          onPressed: () => _openTinyPicker(label, initial, onChanged),
          icon: const Icon(Icons.colorize, size: 16),
          label: const Text('Pick'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _openTinyPicker(String title, Color current, ValueChanged<Color> onPicked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: MaterialPicker(
          pickerColor: current,
          onColorChanged: (c) => onPicked(c),
          enableLabel: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CALC METHOD, MADHAB, LANGUAGE, ABOUT
  // ─────────────────────────────────────────────────────────────────────────────
  void _showCalculationMethodDialog() async {
    final prayerSettings =
        Provider.of<PrayerSettingsProvider>(context, listen: false);
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

  SimpleDialogOption _methodOption(
      BuildContext ctx, String label, CalculationMethod method) {
    return SimpleDialogOption(
      child: Text(label),
      onPressed: () => Navigator.pop(ctx, method),
    );
  }

  void _showMadhabDialog() async {
    final prayerSettings =
        Provider.of<PrayerSettingsProvider>(context, listen: false);
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
