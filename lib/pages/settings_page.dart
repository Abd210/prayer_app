import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../theme/theme_notifier.dart';
import '../services/prayer_settings_provider.dart';

// ─── new imports for language switching ──────────────────────────
import '../services/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ─────────────────────────────────────────────────────────────────

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

  /// Preview swatches for predefined light‑theme palettes (index 0‑7)
  static final Map<int, List<Color>> _themeSwatchMap = {
    0: [Color(0xFF16423C), Color(0xFF6A9C89), Color(0xFFE9EFEC)],
    1: [Color(0xFF5B6EAE), Color(0xFFA8B9EE), Color(0xFFF2F2F7)],
    2: [Color(0xFF009688), Color(0xFFFF9800), Color(0xFFF9FAFB)],
    3: [Color(0xFF7E57C2), Color(0xFFD1B2FF), Color(0xFFF6F2FB)],
    4: [Color(0xFFA38671), Color(0xFFD7C3B5), Color(0xFFFAF2EB)],
    5: [Color(0xFF243B55), Color(0xFFFFD966), Color(0xFFFDFCF7)],
    6: [Color(0xFF7D0A0A), Color(0xFFBF3131), Color(0xFFF3EDC8)],
    7: [Color(0xFFAC1754), Color(0xFFE53888), Color(0xFFF7A8C4)],
    // index 8 is custom – handled dynamically
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
    final langProv = Provider.of<LanguageProvider>(context);
    final loc = AppLocalizations.of(context)!; // localisation instance

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),            // ← localised
      body: ListView(
        children: [
          // ────────────────────────── APPEARANCE ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              loc.appearance,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          SwitchListTile(
            title: Row(
              children: [
                const Icon(Icons.dark_mode, size: 20),
                const SizedBox(width: 10),
                Text(loc.enableDarkMode),
              ],
            ),
            value: themeNotifier.isDarkTheme,
            onChanged: (_) => themeNotifier.toggleTheme(),
          ),
          if (!themeNotifier.isDarkTheme)
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: Text(loc.selectColorTheme),
              subtitle: Row(
                children: [
                  Text('${loc.currentTheme} ${themeNotifier.selectedThemeIndex + 1}'),
                  const SizedBox(width: 8),
                  ..._themePreviewSwatches(themeNotifier.selectedThemeIndex, themeNotifier),
                ],
              ),
              onTap: _showSelectThemeDialog,
            ),
          const Divider(),

          // ──────────────────────── PRAYER SETTINGS ────────────────────────
          ListTile(
            title: Text(loc.calculationMethod),
            subtitle: Text(prayerSettings.calculationMethod.name.toUpperCase()),
            onTap: _showCalculationMethodDialog,
          ),
          ListTile(
            title: Text(loc.madhab),
            subtitle: Text(prayerSettings.madhab.name.toUpperCase()),
            onTap: _showMadhabDialog,
          ),
          SwitchListTile(
            title: Text(loc.use24HourFormat),
            value: prayerSettings.use24hFormat,
            onChanged: prayerSettings.toggle24hFormat,
          ),
          const Divider(),

          // ────────────── NOTIFICATIONS / HADITH / ACCURACY ───────────────
          SwitchListTile(
            title: Text(loc.enableNotifications),
            value: enableNotifications,
            onChanged: (v) {
              setState(() => enableNotifications = v);
              _saveLocalPrefs();
            },
          ),
          SwitchListTile(
            title: Text(loc.enableDailyHadith),
            value: enableDailyHadith,
            onChanged: (v) {
              setState(() => enableDailyHadith = v);
              _saveLocalPrefs();
            },
          ),
          SwitchListTile(
            title: Text(loc.highAccuracyCalculation),
            subtitle: const Text('Adds extra location checks & fine‑tuned method'),
            value: highAccuracyCalc,
            onChanged: (v) {
              setState(() => highAccuracyCalc = v);
              _saveLocalPrefs();
            },
          ),
          const Divider(),

          // ─────────────────────────── LANGUAGE ────────────────────────────
          ListTile(
            title: Text(loc.language),
            subtitle: Text(
              langProv.locale.languageCode == 'ar'
                  ? loc.languageArabic
                  : loc.languageEnglish,
            ),
            onTap: _showLanguageDialog,
          ),
          const Divider(),

          // ─────────────────────────── ABOUT ───────────────────────────────
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(loc.aboutApp),
            subtitle: const Text('Advanced Islamic App with multiple features'),
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }

  // ───────────────────── THEME SELECTION DIALOG ────────────────────────
  void _showSelectThemeDialog() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final loc = AppLocalizations.of(context)!;

    final chosenIndex = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(loc.chooseLightTheme),
        children: [
          _themeOption(ctx, 0, 'Original Brand', themeNotifier),
          _themeOption(ctx, 1, 'Soft Slate & Periwinkle', themeNotifier),
          _themeOption(ctx, 2, 'Teal & Orange', themeNotifier),
          _themeOption(ctx, 3, 'Lilac & Deep Purple', themeNotifier),
          _themeOption(ctx, 4, 'Warm Beige & Brown', themeNotifier),
          _themeOption(ctx, 5, 'Midnight Blue & Soft Gold', themeNotifier),
          _themeOption(ctx, 6, '#7D0A0A & #BF3131', themeNotifier),
          _themeOption(ctx, 7, '#AC1754 & #E53888', themeNotifier),
          _themeOption(ctx, 8, loc.customTheme, themeNotifier),
        ],
      ),
    );
    if (chosenIndex != null) {
      if (chosenIndex == 8) {
        _showCustomThemeDialog();
      } else {
        themeNotifier.setThemeIndex(chosenIndex);
      }
    }
  }

  SimpleDialogOption _themeOption(
      BuildContext ctx, int index, String label, ThemeNotifier tn) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, index),
      child: Row(
        children: [
          ..._themePreviewSwatches(index, tn),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  List<Widget> _themePreviewSwatches(int index, ThemeNotifier tn) {
    if (index == 8) {
      final c = [
        tn.customPrimary,
        tn.customSecondary,
        tn.customBackground,
        tn.customSurface,
      ];
      return c.map(_swatch).toList();
    } else {
      final list = _themeSwatchMap[index]!;
      return list.map(_swatch).toList();
    }
  }

  Widget _swatch(Color c) => Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black12),
        ),
      );

  // ────────────────────────── CUSTOM THEME DIALOG ────────────────────────
  void _showCustomThemeDialog() {
    final tn = Provider.of<ThemeNotifier>(context, listen: false);

    Color p = tn.customPrimary;
    Color s = tn.customSecondary;
    Color b = tn.customBackground;
    Color f = tn.customSurface;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create Your Own Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      tn.setCustomThemeColors(
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
      ),
    );
  }

  Widget _colorPickerRow(
      String label, Color initial, ValueChanged<Color> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
        ),
      ],
    );
  }

  void _openTinyPicker(
      String title, Color current, ValueChanged<Color> onPicked) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: MaterialPicker(
          pickerColor: current,
          onColorChanged: onPicked,
          enableLabel: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  // ──────────────────── CALC METHOD / MADHAB / LANG / ABOUT ──────────────
  void _showCalculationMethodDialog() async {
    final ps = Provider.of<PrayerSettingsProvider>(context, listen: false);
    final chosen = await showDialog<CalculationMethod>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Calculation Method'),
        children: [
          _methodOption(ctx, 'Muslim World League',
              CalculationMethod.muslim_world_league),
          _methodOption(ctx, 'Egyptian', CalculationMethod.egyptian),
          _methodOption(ctx, 'Karachi', CalculationMethod.karachi),
          _methodOption(ctx, 'Umm al-Qura', CalculationMethod.umm_al_qura),
          _methodOption(ctx, 'Moonsighting Committee',
              CalculationMethod.moon_sighting_committee),
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
    if (chosen != null) ps.updateCalculationMethod(chosen);
  }

  SimpleDialogOption _methodOption(
          BuildContext ctx, String label, CalculationMethod m) =>
      SimpleDialogOption(
        child: Text(label),
        onPressed: () => Navigator.pop(ctx, m),
      );

  void _showMadhabDialog() async {
    final ps = Provider.of<PrayerSettingsProvider>(context, listen: false);
    final chosen = await showDialog<Madhab>(
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
    if (chosen != null) ps.updateMadhab(chosen);
  }

  void _showLanguageDialog() async {
    final loc = AppLocalizations.of(context)!;
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select Language'),
        children: [
          SimpleDialogOption(
            child: Text(loc.languageEnglish),
            onPressed: () => Navigator.pop(ctx, 'en'),
          ),
          SimpleDialogOption(
            child: Text(loc.languageArabic),
            onPressed: () => Navigator.pop(ctx, 'ar'),
          ),
        ],
      ),
    );
    if (chosen != null) {
      Provider.of<LanguageProvider>(context, listen: false)
          .setLocale(Locale(chosen));
      setState(() => selectedLanguage =
          chosen == 'ar' ? loc.languageArabic : loc.languageEnglish);
      _saveLocalPrefs();
    }
  }

  void _showAbout() {
    final loc = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: loc.appTitle,
      applicationVersion: '2.0.0',
      children: const [
        Text(
          'This app provides advanced features for prayer times, Azkār, Qibla, Tasbih, and more.',
        ),
      ],
    );
  }
}
