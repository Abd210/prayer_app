import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../theme/theme_notifier.dart';
import '../services/prayer_settings_provider.dart';

// ─── new imports for language switching ──────────────────────────
import '../services/language_provider.dart';
import 'package:prayer/generated/l10n/app_localizations.dart';
// ─────────────────────────────────────────────────────────────────

import '../services/notification_service.dart';
import '../services/adhan_service.dart';
import '../services/location_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool enableNotifications = true;
  bool enableDailyHadith = false;
  bool highAccuracyCalc = false;
  String selectedLanguage = 'English'; // Using exactly the same string as in dropdown options

  // For adhan settings
  bool _isAdhanEnabled = true;
  double _adhanVolume = 0.5;

  /// Preview swatches for predefined light‑theme palettes (index 0‑7)
  static final Map<int, List<Color>> _themeSwatchMap = {
    0: [Color(0xFF16423C), Color(0xFF6A9C89), Color(0xFFE9EFEC)],
    1: [Color(0xFF5B6EAE), Color(0xFFA8B9EE), Color(0xFFF2F2F7)],
    2: [Color(0xFF009688), Color(0xFFFF9800), Color(0xFFF9FAFB)],
    3: [Color(0xFF7E57C2), Color(0xFFD1B2FF), Color(0xFFF6F2FB)],
    4: [Color(0xFFA38671), Color(0xFFD7C3B5), Color(0xFFFAF2EB)],
    5: [Color(0xFF243B55), Color(0xFFFFD966), Color(0xFFFDFCF7)],
    6: [Color(0xFF7D0A0A), Color(0xFFBF3131), Color(0xFFF3EDC8)],
    7: [Color(0xFFAC1754), Color(0xFFE53888), Color(0xFFF7A8C4)],
    // index 8 is custom – handled dynamically
  };

  // Controllers for manual location input
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _elevationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocalPrefs();
    _loadAdhanSettings();
    _loadData();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enableNotifications = prefs.getBool('enableNotifications') ?? true;
      enableDailyHadith = prefs.getBool('enableDailyHadith') ?? false;
      highAccuracyCalc = prefs.getBool('highAccuracyCalc') ?? false;
      
      // Ensure selectedLanguage is exactly one of our valid options
      final storedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      if (storedLanguage == 'English' || storedLanguage == 'العربية') {
        selectedLanguage = storedLanguage;
      } else {
        selectedLanguage = 'English'; // Default to English if invalid value
      }
    });
  }

  Future<void> _saveLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', enableNotifications);
    await prefs.setBool('enableDailyHadith', enableDailyHadith);
    await prefs.setBool('highAccuracyCalc', highAccuracyCalc);
    await prefs.setString('selectedLanguage', selectedLanguage);
  }

  Future<void> _loadAdhanSettings() async {
    final notificationService = NotificationService();
    setState(() {
      _isAdhanEnabled = notificationService.isAdhanEnabled;
      _adhanVolume = notificationService.adhanVolume;
    });
  }

  Future<void> _loadData() async {
    // Get settings data
    final prefs = Provider.of<PrayerSettingsProvider>(context, listen: false);
    
    // Set controller values
    if (prefs.useManualLocation) {
      _latController.text = prefs.manualLatitude.toString();
      _lngController.text = prefs.manualLongitude.toString();
    }
    
    if (prefs.useElevation) {
      _elevationController.text = prefs.manualElevation.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final prayerSettings = Provider.of<PrayerSettingsProvider>(context);
    final langProv = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final theme = Theme.of(context);

    // All calculation methods
    final calculationMethods = [
      CalculationMethod.egyptian,
      CalculationMethod.karachi,
      CalculationMethod.north_america,
      CalculationMethod.muslim_world_league,
      CalculationMethod.moon_sighting_committee,
      CalculationMethod.singapore,
      CalculationMethod.turkey,
      CalculationMethod.tehran,
      CalculationMethod.qatar,
      CalculationMethod.kuwait,
      CalculationMethod.dubai,
    ];

    // Beautiful names for the methods
    String methodName(CalculationMethod m) {
      return m.name
          .replaceAll('_', ' ')
          .split(' ')
          .map((s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Consumer<PrayerSettingsProvider>(
          builder: (context, prefs, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ────────────────────────── APPEARANCE ───────────────────────────
                  _buildSettingsSection(
                    context,
                    title: l10n.appearance,
                    icon: Icons.palette_outlined,
                    children: [
                      _buildSettingTile(
                        context,
                        leading: themeNotifier.isDarkTheme 
                          ? Icons.dark_mode_rounded 
                          : Icons.light_mode_rounded,
                        title: themeNotifier.isDarkTheme 
                          ? l10n.enableLightMode 
                          : l10n.enableDarkMode,
                        trailing: Switch(
                          value: themeNotifier.isDarkTheme,
                          onChanged: (_) => themeNotifier.toggleTheme(),
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      if (!themeNotifier.isDarkTheme)
                        _buildSettingTile(
                          context,
                          leading: Icons.color_lens_outlined,
                          title: l10n.selectColorTheme,
                          subtitle: '${l10n.currentTheme} ${themeNotifier.selectedThemeIndex + 1}',
                          trailing: Wrap(
                            spacing: 4,
                            children: _themePreviewSwatches(
                              themeNotifier.selectedThemeIndex, 
                              themeNotifier
                            ),
                          ),
                          onTap: _showSelectThemeDialog,
                        ),
                    ],
                  ),

                  // ──────────────────────── PRAYER SETTINGS ────────────────────────
                  _buildSettingsSection(
                    context,
                    title: l10n.calculationMethodTitle,
                    icon: Icons.calculate_outlined,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: DropdownButtonFormField<CalculationMethod>(
                          value: prayerSettings.calculationMethod,
                          decoration: InputDecoration(
                            labelText: l10n.calculationMethodLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          onChanged: (CalculationMethod? value) {
                            if (value != null) {
                              prayerSettings.updateCalculationMethod(value);
                            }
                          },
                          items: calculationMethods
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(methodName(m),
                                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),

                  // Madhab (Asr calculation)
                  _buildSettingsSection(
                    context,
                    title: l10n.asrCalculationTitle,
                    icon: Icons.access_time_filled_outlined,
                    children: [
                      RadioListTile<Madhab>(
                        title: Text(l10n.shafiiLabel),
                        subtitle: Text(l10n.shafiiDescription),
                        value: Madhab.shafi,
                        groupValue: prayerSettings.madhab,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (Madhab? value) {
                          if (value != null) {
                            prayerSettings.updateMadhab(value);
                          }
                        },
                      ),
                      RadioListTile<Madhab>(
                        title: Text(l10n.hanafiLabel),
                        subtitle: Text(l10n.hanafiDescription),
                        value: Madhab.hanafi,
                        groupValue: prayerSettings.madhab,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (Madhab? value) {
                          if (value != null) {
                            prayerSettings.updateMadhab(value);
                          }
                        },
                      ),
                    ],
                  ),

                  // Prayer Adjustments
                  _buildSettingsSection(
                    context,
                    title: l10n.prayerTimeAdjustments,
                    icon: Icons.tune_rounded,
                    children: [
                      _buildPrayerAdjustment(context, prefs, l10n.prayerFajr, prefs.fajrAdjustment),
                      _buildPrayerAdjustment(context, prefs, l10n.prayerDhuhr, prefs.dhuhrAdjustment),
                      _buildPrayerAdjustment(context, prefs, l10n.prayerAsr, prefs.asrAdjustment),
                      _buildPrayerAdjustment(context, prefs, l10n.prayerMaghrib, prefs.maghribAdjustment),
                      _buildPrayerAdjustment(context, prefs, l10n.prayerIsha, prefs.ishaAdjustment),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.restart_alt),
                            label: Text(l10n.resetAdjustments),
                            onPressed: () {
                              prefs.resetAllAdjustments();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Location Settings
                  _buildSettingsSection(
                    context,
                    title: l10n.locationSettings,
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildSettingTile(
                        context,
                        leading: Icons.my_location,
                        title: l10n.manualLocation,
                        subtitle: prefs.useManualLocation 
                          ? "${prefs.manualLatitude.toStringAsFixed(4)}, ${prefs.manualLongitude.toStringAsFixed(4)}"
                          : null,
                        trailing: Switch(
                          value: prefs.useManualLocation,
                          onChanged: (v) {
                            prefs.toggleUseManualLocation(v);
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.travel_explore_outlined,
                        title: l10n.highAccuracyCalculation,
                        subtitle: l10n.highAccuracySubtitle,
                        trailing: Switch(
                          value: highAccuracyCalc,
                          onChanged: (v) {
                            setState(() => highAccuracyCalc = v);
                            // Actually apply the setting by toggling elevation usage
                            prefs.toggleUseElevation(v);
                            _saveLocalPrefs();
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.gps_fixed,
                        title: l10n.frequentLocationUpdates,
                        subtitle: l10n.frequentLocationSubtitle,
                        trailing: Switch(
                          value: prefs.frequentLocationUpdates,
                          onChanged: (v) {
                            prefs.toggleFrequentLocationUpdates(v);
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Time format & other settings
                  _buildSettingsSection(
                    context,
                    title: l10n.otherSettings,
                    icon: Icons.settings_outlined,
                    children: [
                      _buildSettingTile(
                        context,
                        leading: Icons.access_time_rounded,
                        title: l10n.use24hFormat,
                        trailing: Switch(
                          value: prayerSettings.use24hFormat,
                          onChanged: prayerSettings.toggle24hFormat,
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.notifications_active_outlined,
                        title: l10n.enableNotifications,
                        trailing: Switch(
                          value: enableNotifications,
                          onChanged: (v) {
                            setState(() => enableNotifications = v);
                            NotificationService().toggleNotifications(v);
                            _saveLocalPrefs();
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.menu_book_outlined,
                        title: l10n.enableDailyHadith,
                        trailing: Switch(
                          value: enableDailyHadith,
                          onChanged: (v) {
                            setState(() => enableDailyHadith = v);
                            // Call hadith service to enable/disable
                            _toggleDailyHadith(v);
                            _saveLocalPrefs();
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Language Settings
                  _buildSettingsSection(
                    context,
                    title: l10n.languageTitle,
                    icon: Icons.language_rounded,
                    children: [
                      _buildSettingTile(
                        context,
                        leading: Icons.translate_rounded,
                        title: l10n.selectLanguage,
                        subtitle: selectedLanguage == 'English' ? 'English' : 'العربية',
                        trailing: DropdownButton<String>(
                          value: selectedLanguage, // This must match exactly one of the dropdown item values
                          underline: Container(),
                          items: ['English', 'العربية'].map((String lang) {
                            return DropdownMenuItem<String>(
                              value: lang,
                              child: Text(lang),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedLanguage = newValue;
                              });
                              if (newValue == 'English') {
                                langProv.setLocale(const Locale('en'));
                              } else {
                                langProv.setLocale(const Locale('ar'));
                              }
                              _saveLocalPrefs();
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  // Adhan Settings
                  _buildSettingsSection(
                    context,
                    title: l10n.adhanSettings,
                    icon: Icons.volume_up_outlined,
                    children: [
                      _buildSettingTile(
                        context,
                        leading: Icons.music_note_outlined,
                        title: l10n.enableAdhan,
                        trailing: Switch(
                          value: _isAdhanEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isAdhanEnabled = value;
                            });
                            NotificationService().setAdhanEnabled(value);
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      if (_isAdhanEnabled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.adhanVolume,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.volume_down_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _adhanVolume,
                                      min: 0,
                                      max: 1.0,
                                      divisions: 10,
                                      activeColor: theme.colorScheme.primary,
                                      onChanged: (value) {
                                        setState(() {
                                          _adhanVolume = value;
                                        });
                                        NotificationService().setAdhanVolume(value);
                                      },
                                    ),
                                  ),
                                  Icon(
                                    Icons.volume_up_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ],
                              ),
                              Center(
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.play_circle_outline_rounded),
                                  label: Text(l10n.testAdhan),
                                  onPressed: () {
                                    AdhanService().playAdhanTest(_adhanVolume);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Build a styled settings section
  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // Build a styled setting tile
  Widget _buildSettingTile(
    BuildContext context, {
    required IconData leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  leading,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  // Prayer time adjustment slider
  Widget _buildPrayerAdjustment(
    BuildContext context,
    PrayerSettingsProvider prefs,
    String prayer,
    int currentValue,
  ) {
    final theme = Theme.of(context);
    // Map prayer name to lowercase key for provider
    String prayerKey = prayer.toLowerCase();
    if (prayer == AppLocalizations.of(context)!.prayerFajr) prayerKey = 'fajr';
    if (prayer == AppLocalizations.of(context)!.prayerDhuhr) prayerKey = 'dhuhr';
    if (prayer == AppLocalizations.of(context)!.prayerAsr) prayerKey = 'asr';
    if (prayer == AppLocalizations.of(context)!.prayerMaghrib) prayerKey = 'maghrib';
    if (prayer == AppLocalizations.of(context)!.prayerIsha) prayerKey = 'isha';
    
    // Get the appropriate icon based on prayer
    IconData prayerIcon = Icons.access_time;
    if (prayerKey == 'fajr') prayerIcon = Icons.wb_twilight_rounded;
    else if (prayerKey == 'dhuhr') prayerIcon = Icons.wb_sunny_rounded;
    else if (prayerKey == 'asr') prayerIcon = Icons.wb_cloudy_rounded;
    else if (prayerKey == 'maghrib') prayerIcon = Icons.nightlight_round;
    else if (prayerKey == 'isha') prayerIcon = Icons.nightlight;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  prayerIcon,
                  color: theme.colorScheme.secondary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "$prayer ${AppLocalizations.of(context)?.adjustmentMinutes ?? 'Adjustment'}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$currentValue min",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: currentValue.toDouble(),
            min: -15,
            max: 15,
            divisions: 30,
            label: "$currentValue min",
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              prefs.updatePrayerAdjustment(prayerKey, value.toInt());
            },
          ),
        ],
      ),
    );
  }

  // ───────────────────── THEME SELECTION DIALOG ────────────────────────
  void _showSelectThemeDialog() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final chosenIndex = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.chooseLightTheme),
        children: [
          _themeOption(ctx, 0, 'Original Brand', themeNotifier),
          _themeOption(ctx, 1, 'Soft Slate & Periwinkle', themeNotifier),
          _themeOption(ctx, 2, 'Teal & Orange', themeNotifier),
          _themeOption(ctx, 3, 'Lilac & Deep Purple', themeNotifier),
          _themeOption(ctx, 4, 'Warm Beige & Brown', themeNotifier),
          _themeOption(ctx, 5, 'Midnight Blue & Soft Gold', themeNotifier),
          _themeOption(ctx, 6, '#7D0A0A & #BF3131', themeNotifier),
          _themeOption(ctx, 7, '#AC1754 & #E53888', themeNotifier),
          _themeOption(ctx, 8, l10n.customTheme, themeNotifier),
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

  // ────────────────────────── CUSTOM THEME DIALOG ────────────────────────
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

  // Add methods to handle notifications and daily hadith
  Future<void> _toggleDailyHadith(bool enabled) async {
    // This would typically call a hadith service that you might implement
    // For now, we'll just save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableDailyHadith', enabled);
    
    // If you have a HadithService, you would call it like:
    // await HadithService().setEnabled(enabled);
    
    print('[Settings] Daily hadith ${enabled ? 'enabled' : 'disabled'}');
  }
}
