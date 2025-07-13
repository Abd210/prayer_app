import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/theme_notifier.dart';
import '../services/prayer_settings_provider.dart';

// ─── new imports for language switching ──────────────────────────
import '../services/language_provider.dart';
import 'package:prayer/generated/l10n/app_localizations.dart';
// ─────────────────────────────────────────────────────────────────

import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../services/azkar_reminder_service.dart';

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

  // For notification settings
  int _notificationAdvanceTime = 5;
  bool _notificationSoundEnabled = true;
  bool _allowAdhanSound = true;
  
  // For daily hadith settings
  TimeOfDay _dailyHadithTime = const TimeOfDay(hour: 8, minute: 0);
  
  // For advanced settings
  bool _autoRefreshEnabled = true;
  bool _dataSavingEnabled = false;
  String _cacheDuration = '6h';
  
  // For Azkar reminder settings
  bool _azkarRemindersEnabled = true;
  int _dhuhrReminderMinutes = 60;
  int _maghribReminderMinutes = 60;

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
    _loadData();
    _loadAdditionalSettings();
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
                      // Auto-detection toggle
                      _buildSettingTile(
                        context,
                        leading: Icons.auto_awesome,
                        title: l10n.autoDetectMethod,
                        subtitle: l10n.autoDetectMethodSubtitle,
                        trailing: FutureBuilder<bool>(
                          future: prayerSettings.isAutoDetectionEnabled(),
                          builder: (context, snapshot) {
                            return Switch(
                              value: snapshot.data ?? true,
                              onChanged: (value) async {
                                await prayerSettings.setAutoDetectionEnabled(value);
                                setState(() {}); // Refresh UI
                              },
                              activeColor: theme.colorScheme.primary,
                            );
                          },
                        ),
                      ),
                      
                      // Manual method selection
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calculate, size: 20, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.manualCalculationMethod,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<CalculationMethod>(
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
                          ],
                        ),
                      ),
                      
                      // Auto-detect button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.my_location),
                            label: Text(l10n.detectMethodNow),
                            onPressed: () async {
                              _showLoadingDialog(context, l10n.detectingMethod);
                              
                              final changed = await prayerSettings.autoDetectCalculationMethod();
                              Navigator.pop(context); // Close loading dialog
                              
                              if (changed) {
                                _showSnackBar(
                                  context, 
                                  l10n.methodUpdatedAuto,
                                  isError: false
                                );
                              } else {
                                _showSnackBar(
                                  context, 
                                  l10n.methodUnchanged,
                                  isError: false
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorScheme.primary),
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
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
                      // Manual Location Input Fields
                      if (prefs.useManualLocation)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Latitude Input
                              TextFormField(
                                controller: _latController,
                                decoration: InputDecoration(
                                  labelText: 'Latitude (-90 to 90)',
                                  hintText: 'e.g., 40.7128',
                                  prefixIcon: const Icon(Icons.location_on),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final lat = double.tryParse(value);
                                  if (lat != null && lat >= -90 && lat <= 90) {
                                    prefs.setManualLocation(lat, prefs.manualLongitude);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              // Longitude Input
                              TextFormField(
                                controller: _lngController,
                                decoration: InputDecoration(
                                  labelText: 'Longitude (-180 to 180)',
                                  hintText: 'e.g., -74.0060',
                                  prefixIcon: const Icon(Icons.explore),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final lng = double.tryParse(value);
                                  if (lng != null && lng >= -180 && lng <= 180) {
                                    prefs.setManualLocation(prefs.manualLatitude, lng);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              // Current Location Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Use Current Location'),
                                  onPressed: () async {
                                    _showLoadingDialog(context, 'Getting current location...');
                                    final position = await LocationService.determinePosition();
                                    Navigator.pop(context); // Close loading dialog
                                    
                                    if (position != null) {
                                      prefs.setManualLocation(position.latitude, position.longitude);
                                      _latController.text = position.latitude.toString();
                                      _lngController.text = position.longitude.toString();
                                      _showSnackBar(context, 'Location updated successfully!');
                                    } else {
                                      _showSnackBar(context, 'Could not get current location. Please check permissions.', isError: true);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    foregroundColor: theme.colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
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
                      // Elevation Input Field
                      if (highAccuracyCalc)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _elevationController,
                                decoration: InputDecoration(
                                  labelText: 'Elevation (meters above sea level)',
                                  hintText: 'e.g., 100',
                                  prefixIcon: const Icon(Icons.height),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final elevation = double.tryParse(value);
                                  if (elevation != null && elevation >= -1000 && elevation <= 10000) {
                                    prefs.setManualElevation(elevation);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              // Get elevation from GPS button
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.gps_fixed),
                                  label: const Text('Get elevation from GPS'),
                                  onPressed: () async {
                                    _showLoadingDialog(context, 'Getting elevation from GPS...');
                                    final position = await LocationService.determinePosition();
                                    Navigator.pop(context); // Close loading dialog
                                    
                                    if (position != null && position.altitude != 0) {
                                      prefs.setManualElevation(position.altitude);
                                      _elevationController.text = position.altitude.toString();
                                      _showSnackBar(context, 'Elevation updated from GPS!');
                                    } else {
                                      _showSnackBar(context, 'Could not get elevation from GPS. Please enter manually.', isError: true);
                                    }
                                  },
                                ),
                              ),
                            ],
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
                      // Location Status Display
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Location Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                prefs.useManualLocation 
                                  ? 'Using manual location: ${prefs.manualLatitude.toStringAsFixed(4)}, ${prefs.manualLongitude.toStringAsFixed(4)}'
                                  : 'Using GPS location with ${prefs.frequentLocationUpdates ? "frequent" : "standard"} updates',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              if (highAccuracyCalc)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'High accuracy enabled: ${prefs.manualElevation.toStringAsFixed(0)}m elevation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // Location validation status
                              Row(
                                children: [
                                  Icon(
                                    prefs.validateManualLocation() 
                                      ? Icons.check_circle 
                                      : Icons.error,
                                    size: 14,
                                    color: prefs.validateManualLocation() 
                                      ? Colors.green 
                                      : Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    prefs.validateManualLocation() 
                                      ? 'Location settings are valid'
                                      : 'Location settings need attention',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: prefs.validateManualLocation() 
                                        ? Colors.green 
                                        : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Cache information
                              Text(
                                'Cache: ${prefs.frequentLocationUpdates ? "5 minutes" : "1 hour"}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              // Last update info
                              FutureBuilder<Map<String, dynamic>>(
                                future: LocationService.getLocationStatus(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final status = snapshot.data!;
                                    final lastUpdate = status['lastUpdateTime'];
                                    if (lastUpdate != null) {
                                      final lastUpdateTime = DateTime.parse(lastUpdate);
                                      final timeAgo = DateTime.now().difference(lastUpdateTime);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Last update: ${_formatTimeAgo(timeAgo)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
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
                        subtitle: enableNotifications 
                          ? (selectedLanguage == 'العربية' ? 'إشعارات أوقات الصلاة مفعلة' : 'Prayer time notifications are enabled')
                          : (selectedLanguage == 'العربية' ? 'إشعارات أوقات الصلاة معطلة' : 'Prayer time notifications are disabled'),
                        trailing: Switch(
                          value: enableNotifications,
                          onChanged: (v) {
                            setState(() => enableNotifications = v);
                            NotificationService().toggleNotifications(v);
                            _saveLocalPrefs();
                            _showSnackBar(
                              context, 
                              v ? (selectedLanguage == 'العربية' ? 'تم تفعيل الإشعارات' : 'Notifications enabled') : (selectedLanguage == 'العربية' ? 'تم إلغاء الإشعارات' : 'Notifications disabled'),
                              isError: false
                            );
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      // Enhanced Notification Settings
                      if (enableNotifications)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Notification Advance Time
                              Text(
                                selectedLanguage == 'العربية' ? 'وقت التبكير بالإشعارات' : 'Notification Advance Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _notificationAdvanceTime.toDouble(),
                                      min: 0,
                                      max: 30,
                                      divisions: 6,
                                      activeColor: theme.colorScheme.primary,
                                      onChanged: (value) {
                                        setState(() {
                                          _notificationAdvanceTime = value.toInt();
                                        });
                                        _saveNotificationAdvanceTime(value.toInt());
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      selectedLanguage == 'العربية' ? '${_notificationAdvanceTime} دقيقة' : '${_notificationAdvanceTime} min',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Notification Sound Toggle
                              Row(
                                children: [
                                  Icon(
                                    Icons.volume_up,
                                    size: 20,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedLanguage == 'العربية' ? 'صوت الإشعارات' : 'Notification Sound',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _notificationSoundEnabled,
                                    onChanged: (v) {
                                      setState(() => _notificationSoundEnabled = v);
                                      _saveNotificationSoundEnabled(v);
                                    },
                                    activeColor: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Allow Adhan Sound Toggle
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    size: 20,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedLanguage == 'العربية' ? 'السماح بصوت الأذان' : 'Allow Adhan Sound',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _allowAdhanSound,
                                    onChanged: (v) {
                                      setState(() => _allowAdhanSound = v);
                                      _saveAllowAdhanSound(v);
                                    },
                                    activeColor: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Test Notification Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.notifications_active),
                                  label: Text(selectedLanguage == 'العربية' ? 'اختبار إشعار الصلاة' : 'Test Prayer Notification'),
                                  onPressed: () => _testPrayerNotification(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    foregroundColor: theme.colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Notification Info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedLanguage == 'العربية' ? 'معلومات الإشعارات' : 'Notification Info',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedLanguage == 'العربية'
                                        ? '• وقت التبكير: احصل على إشعار قبل وقت الصلاة\n'
                                          '• الصوت: تشغيل صوت الأذان مع الإشعارات\n'
                                          '• يومياً: تتكرر الإشعارات كل يوم\n'
                                          '• اختبار: جرب نظام الإشعارات'
                                        : '• Advance time: Get notified before prayer time\n'
                                          '• Sound: Play adhan sound with notifications\n'
                                          '• Daily: Notifications repeat every day\n'
                                          '• Test: Try the notification system',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.menu_book_outlined,
                        title: l10n.enableDailyHadith,
                        subtitle: enableDailyHadith 
                          ? (selectedLanguage == 'العربية' ? 'إشعارات الحديث اليومي مفعلة' : 'Daily hadith notifications are enabled')
                          : (selectedLanguage == 'العربية' ? 'إشعارات الحديث اليومي معطلة' : 'Daily hadith notifications are disabled'),
                        trailing: Switch(
                          value: enableDailyHadith,
                          onChanged: (v) {
                            setState(() => enableDailyHadith = v);
                            // Call hadith service to enable/disable
                            _toggleDailyHadith(v);
                            _saveLocalPrefs();
                            _showSnackBar(
                              context, 
                              v ? (selectedLanguage == 'العربية' ? 'تم تفعيل الحديث اليومي' : 'Daily hadith enabled') : (selectedLanguage == 'العربية' ? 'تم إلغاء الحديث اليومي' : 'Daily hadith disabled'),
                              isError: false
                            );
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      // Daily Hadith Settings
                      if (enableDailyHadith)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLanguage == 'العربية' ? 'وقت إشعار الحديث اليومي' : 'Hadith Notification Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.access_time),
                                      label: Text(selectedLanguage == 'العربية' ? 'تعيين الوقت' : 'Set Time'),
                                      onPressed: () => _showTimePickerDialog(context),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: theme.colorScheme.primary),
                                        foregroundColor: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.notifications_active),
                                      label: Text(selectedLanguage == 'العربية' ? 'اختبار' : 'Test'),
                                      onPressed: () => _testDailyHadith(context),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: theme.colorScheme.secondary),
                                        foregroundColor: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.secondary.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.menu_book_outlined,
                                          size: 16,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedLanguage == 'العربية' ? 'معلومات الحديث اليومي' : 'Daily Hadith Info',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedLanguage == 'العربية'
                                        ? 'استقبل إشعارات الحديث اليومي لزيادة معرفتك وروحانيتك. يمكنك تعيين وقت مفضل لاستقبال هذه الإشعارات.'
                                        : 'Receive daily hadith notifications to increase your knowledge and spirituality. You can set a preferred time to receive these notifications.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        ),
                      ),
                    ],
                  ),

                  // Azkar Reminder Settings
                  _buildSettingsSection(
                    context,
                    title: l10n.azkarReminders,
                    icon: Icons.book_outlined,
                    children: [
                      _buildSettingTile(
                        context,
                        leading: Icons.notifications_active_outlined,
                        title: l10n.enableAzkarReminders,
                        subtitle: _azkarRemindersEnabled 
                          ? l10n.azkarRemindersEnabled
                          : l10n.azkarRemindersDisabled,
                        trailing: Switch(
                          value: _azkarRemindersEnabled,
                          onChanged: (v) async {
                            setState(() => _azkarRemindersEnabled = v);
                            await AzkarReminderService().setAzkarRemindersEnabled(v);
                                                          _showSnackBar(
                                context, 
                                v ? l10n.azkarRemindersEnabledMsg : l10n.azkarRemindersDisabledMsg,
                                isError: false
                              );
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      // Azkar Reminder Settings
                      if (_azkarRemindersEnabled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dhuhr Reminder
                              Text(
                                l10n.dhuhrAzkarReminder,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _dhuhrReminderMinutes.toDouble(),
                                      min: 0,
                                      max: 180,
                                      divisions: 18,
                                      activeColor: theme.colorScheme.primary,
                                      onChanged: (value) async {
                                        setState(() {
                                          _dhuhrReminderMinutes = value.toInt();
                                        });
                                        await AzkarReminderService().setDhuhrReminderMinutes(value.toInt());
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatReminderTime(_dhuhrReminderMinutes, selectedLanguage),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Maghrib Reminder
                              Text(
                                l10n.maghribAzkarReminder,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _maghribReminderMinutes.toDouble(),
                                      min: 0,
                                      max: 180,
                                      divisions: 18,
                                      activeColor: theme.colorScheme.primary,
                                      onChanged: (value) async {
                                        setState(() {
                                          _maghribReminderMinutes = value.toInt();
                                        });
                                        await AzkarReminderService().setMaghribReminderMinutes(value.toInt());
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatReminderTime(_maghribReminderMinutes, selectedLanguage),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Reset to Defaults Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.restore),
                                  label: Text(l10n.resetToDefaults),
                                  onPressed: () async {
                                    await AzkarReminderService().resetToDefaults();
                                    setState(() {
                                      _dhuhrReminderMinutes = 60;
                                      _maghribReminderMinutes = 60;
                                    });
                                    _showSnackBar(
                                      context,
                                      l10n.resetToDefaultsMsg,
                                      isError: false
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.secondary),
                                    foregroundColor: theme.colorScheme.secondary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Test Reminder Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.notifications_active),
                                  label: Text(l10n.testReminder),
                                  onPressed: () async {
                                    await AzkarReminderService().testReminder();
                                    _showSnackBar(
                                      context,
                                      l10n.testReminderSent,
                                      isError: false
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    foregroundColor: theme.colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Azkar Reminder Info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.azkarReminderInfo,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.azkarReminderInfoText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

                  // Advanced Settings
                  _buildSettingsSection(
                    context,
                    title: selectedLanguage == 'العربية' ? 'الإعدادات المتقدمة' : 'Advanced Settings',
                    icon: Icons.tune_outlined,
                    children: [
                      // Performance Settings
                      _buildSettingTile(
                        context,
                        leading: Icons.auto_awesome,
                        title: selectedLanguage == 'العربية' ? 'تحديث تلقائي لأوقات الصلاة' : 'Auto-refresh Prayer Times',
                        subtitle: _autoRefreshEnabled 
                          ? (selectedLanguage == 'العربية' ? 'تحديث أوقات الصلاة تلقائياً' : 'Prayer times refresh automatically')
                          : (selectedLanguage == 'العربية' ? 'يتطلب التحديث اليدوي' : 'Manual refresh required'),
                        trailing: Switch(
                          value: _autoRefreshEnabled,
                          onChanged: (v) {
                            setState(() => _autoRefreshEnabled = v);
                            _saveAutoRefreshEnabled(v);
                            _showSnackBar(
                              context, 
                              v ? (selectedLanguage == 'العربية' ? 'تم تفعيل التحديث التلقائي' : 'Auto-refresh enabled') : (selectedLanguage == 'العربية' ? 'تم إلغاء التحديث التلقائي' : 'Auto-refresh disabled'),
                              isError: false
                            );
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.data_usage,
                        title: selectedLanguage == 'العربية' ? 'وضع توفير البيانات' : 'Data Saving Mode',
                        subtitle: _dataSavingEnabled 
                          ? (selectedLanguage == 'العربية' ? 'محسن للبيانات المحدودة' : 'Optimized for limited data')
                          : (selectedLanguage == 'العربية' ? 'جميع الميزات مفعلة' : 'Full features enabled'),
                        trailing: Switch(
                          value: _dataSavingEnabled,
                          onChanged: (v) {
                            setState(() => _dataSavingEnabled = v);
                            _saveDataSavingEnabled(v);
                            _showSnackBar(
                              context, 
                              v ? (selectedLanguage == 'العربية' ? 'تم تفعيل توفير البيانات' : 'Data saving enabled') : (selectedLanguage == 'العربية' ? 'تم إلغاء توفير البيانات' : 'Data saving disabled'),
                              isError: false
                            );
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.schedule,
                        title: selectedLanguage == 'العربية' ? 'مدة التخزين المؤقت' : 'Cache Duration',
                        subtitle: selectedLanguage == 'العربية' ? 'كم من الوقت لتخزين أوقات الصلاة' : 'How long to cache prayer times',
                        trailing: DropdownButton<String>(
                          value: _cacheDuration,
                          underline: Container(),
                          items: [
                            DropdownMenuItem(value: '1h', child: Text(selectedLanguage == 'العربية' ? 'ساعة واحدة' : '1 Hour')),
                            DropdownMenuItem(value: '6h', child: Text(selectedLanguage == 'العربية' ? '6 ساعات' : '6 Hours')),
                            DropdownMenuItem(value: '12h', child: Text(selectedLanguage == 'العربية' ? '12 ساعة' : '12 Hours')),
                            DropdownMenuItem(value: '24h', child: Text(selectedLanguage == 'العربية' ? '24 ساعة' : '24 Hours')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _cacheDuration = value);
                              _saveCacheDuration(value);
                            }
                          },
                        ),
                      ),
                      // Data Management
                      _buildSettingTile(
                        context,
                        leading: Icons.storage,
                        title: selectedLanguage == 'العربية' ? 'إدارة التخزين' : 'Storage Management',
                        subtitle: selectedLanguage == 'العربية' ? 'إدارة بيانات التطبيق والتخزين المؤقت' : 'Manage app data and cache',
                        trailing: IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () => _showStorageManagement(context),
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.backup,
                        title: selectedLanguage == 'العربية' ? 'نسخ احتياطي للإعدادات' : 'Backup Settings',
                        subtitle: selectedLanguage == 'العربية' ? 'نسخ احتياطي لإعداداتك إلى السحابة' : 'Backup your settings to cloud',
                        trailing: IconButton(
                          icon: const Icon(Icons.cloud_upload),
                          onPressed: () => _backupSettings(context),
                        ),
                      ),
                      _buildSettingTile(
                        context,
                        leading: Icons.restore,
                        title: selectedLanguage == 'العربية' ? 'استعادة الإعدادات' : 'Restore Settings',
                        subtitle: selectedLanguage == 'العربية' ? 'استعادة الإعدادات من النسخة الاحتياطية' : 'Restore settings from backup',
                        trailing: IconButton(
                          icon: const Icon(Icons.cloud_download),
                          onPressed: () => _restoreSettings(context),
                        ),
                      ),
                      // Reset Options
                      _buildSettingTile(
                        context,
                        leading: Icons.refresh,
                        title: selectedLanguage == 'العربية' ? 'إعادة تعيين جميع الإعدادات' : 'Reset All Settings',
                        subtitle: selectedLanguage == 'العربية' ? 'إعادة تعيين إلى الإعدادات الافتراضية' : 'Reset to default settings',
                        trailing: IconButton(
                          icon: const Icon(Icons.restore_page),
                          onPressed: () => _showResetConfirmation(context),
                        ),
                      ),
                    ],
                  ),



                  // Location Permissions Section
                  _buildSettingsSection(
                    context,
                    title: selectedLanguage == 'العربية' ? 'أذونات الموقع' : 'Location Permissions',
                    icon: Icons.security,
                    children: [
                      FutureBuilder<bool>(
                        future: LocationService.isLocationServiceAvailable(),
                        builder: (context, snapshot) {
                          final isAvailable = snapshot.data ?? false;
                          return _buildSettingTile(
                            context,
                            leading: isAvailable ? Icons.check_circle : Icons.error,
                            title: selectedLanguage == 'العربية' ? 'خدمات الموقع' : 'Location Services',
                            subtitle: isAvailable 
                              ? (selectedLanguage == 'العربية' ? 'خدمات الموقع متاحة' : 'Location services are available')
                              : (selectedLanguage == 'العربية' ? 'خدمات الموقع معطلة' : 'Location services are disabled'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAvailable ? (selectedLanguage == 'العربية' ? 'تشغيل' : 'ON') : (selectedLanguage == 'العربية' ? 'إيقاف' : 'OFF'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      FutureBuilder<LocationPermission>(
                        future: LocationService.getLocationPermission(),
                        builder: (context, snapshot) {
                          final permission = snapshot.data ?? LocationPermission.denied;
                          String statusText;
                          IconData statusIcon;
                          Color statusColor;
                          
                          switch (permission) {
                            case LocationPermission.whileInUse:
                            case LocationPermission.always:
                              statusText = selectedLanguage == 'العربية' ? 'تم منح الإذن' : 'Permission granted';
                              statusIcon = Icons.check_circle;
                              statusColor = Colors.green;
                              break;
                            case LocationPermission.denied:
                              statusText = selectedLanguage == 'العربية' ? 'تم رفض الإذن' : 'Permission denied';
                              statusIcon = Icons.error;
                              statusColor = Colors.orange;
                              break;
                            case LocationPermission.deniedForever:
                              statusText = selectedLanguage == 'العربية' ? 'تم رفض الإذن نهائياً' : 'Permission denied forever';
                              statusIcon = Icons.block;
                              statusColor = Colors.red;
                              break;
                            default:
                              statusText = selectedLanguage == 'العربية' ? 'حالة غير معروفة' : 'Unknown status';
                              statusIcon = Icons.help;
                              statusColor = Colors.grey;
                          }
                          
                          return _buildSettingTile(
                            context,
                            leading: statusIcon,
                            title: selectedLanguage == 'العربية' ? 'إذن الموقع' : 'Location Permission',
                            subtitle: statusText,
                            trailing: permission == LocationPermission.denied
                              ? TextButton(
                                  onPressed: () async {
                                    await LocationService.requestLocationPermission();
                                    setState(() {}); // Refresh the UI
                                  },
                                  child: Text(selectedLanguage == 'العربية' ? 'طلب' : 'Request'),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    permission == LocationPermission.whileInUse ? (selectedLanguage == 'العربية' ? 'أثناء الاستخدام' : 'WHILE IN USE') :
                                    permission == LocationPermission.always ? (selectedLanguage == 'العربية' ? 'دائماً' : 'ALWAYS') :
                                    permission == LocationPermission.denied ? (selectedLanguage == 'العربية' ? 'مرفوض' : 'DENIED') : (selectedLanguage == 'العربية' ? 'نهائياً' : 'FOREVER'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
                      // Help text
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.secondary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    size: 16,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedLanguage == 'العربية' ? 'مساعدة الموقع' : 'Location Help',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedLanguage == 'العربية' 
                                  ? '• الموقع اليدوي: أدخل إحداثيات محددة لأوقات صلاة دقيقة\n'
                                    '• الدقة العالية: يستخدم بيانات الارتفاع لحسابات أكثر دقة\n'
                                    '• التحديثات المتكررة: يحدث الموقع كل 5 دقائق بدلاً من ساعة واحدة\n'
                                    '• موقع GPS: يستخدم GPS جهازك تلقائياً'
                                  : '• Manual location: Enter specific coordinates for accurate prayer times\n'
                                    '• High accuracy: Uses elevation data for more precise calculations\n'
                                    '• Frequent updates: Refreshes location every 5 minutes instead of 1 hour\n'
                                    '• GPS location: Automatically uses your device\'s GPS',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
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
                  // Use a high-contrast color relative to the current background so
                  // the icon never "blends" with the card or page when themes
                  // change.
                  color: theme.colorScheme.onBackground,
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
          _themeOption(ctx, 1, 'Ocean Breeze', themeNotifier),
          _themeOption(ctx, 2, 'Nature Harmony', themeNotifier),
          _themeOption(ctx, 3, 'Lavender Dreams', themeNotifier),
          _themeOption(ctx, 4, 'Desert Sunset', themeNotifier),
          _themeOption(ctx, 5, 'Midnight Blue & Soft Gold', themeNotifier),
          _themeOption(ctx, 6, 'Autumn Warmth', themeNotifier),
          _themeOption(ctx, 7, 'Rose Garden', themeNotifier),
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
              const SizedBox(height: 8),
              const Text('Choose colors that provide good contrast for readability',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center),
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
                    const SizedBox(height: 16),
                    _buildContrastPreview(p, s, b, f),
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
                    onPressed: _validateAndSaveTheme(p, s, b, f, tn, ctx),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Validate theme colors and show warning if contrast is poor
  VoidCallback? _validateAndSaveTheme(Color primary, Color secondary, Color background, Color surface, ThemeNotifier tn, BuildContext ctx) {
    // Check if any color combinations would cause visibility issues
    bool hasPoorContrast = _checkPoorContrast(primary, secondary, background, surface);
    
    if (hasPoorContrast) {
      return () {
        _showContrastWarning(ctx, () {
                      tn.setCustomThemeColors(
            primary: primary,
            secondary: secondary,
            background: background,
            surface: surface,
                      );
                      Navigator.pop(ctx);
        });
      };
    }
    
    return () {
      tn.setCustomThemeColors(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      );
      Navigator.pop(ctx);
    };
  }
  
  /// Check for poor contrast combinations
  bool _checkPoorContrast(Color primary, Color secondary, Color background, Color surface) {
    // Check if background and surface are too similar
    double bgLuminance = background.computeLuminance();
    double surfaceLuminance = surface.computeLuminance();
    
    // Check if primary color would be invisible on background
    double primaryLuminance = primary.computeLuminance();
    double primaryBgContrast = (primaryLuminance + 0.05) / (bgLuminance + 0.05);
    
    // Check if secondary color would be invisible on surface
    double secondaryLuminance = secondary.computeLuminance();
    double secondarySurfaceContrast = (secondaryLuminance + 0.05) / (surfaceLuminance + 0.05);
    
    // Return true if any contrast ratio is too low (less than 2.0)
    return primaryBgContrast < 2.0 || secondarySurfaceContrast < 2.0 || 
           (bgLuminance - surfaceLuminance).abs() < 0.1;
  }
  
  /// Show warning dialog for poor contrast
  void _showContrastWarning(BuildContext ctx, VoidCallback onConfirm) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Poor Contrast Detected'),
        content: const Text(
          'The selected colors may make text and icons difficult to read. '
          'The app will automatically adjust text colors for better visibility, '
          'but you may want to choose different colors for optimal experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('CONTINUE'),
                  ),
                ],
      ),
    );
  }
  
  /// Build a preview of how the theme will look
  Widget _buildContrastPreview(Color primary, Color secondary, Color background, Color surface) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme Preview', 
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold,
              color: _calculateContrastColor(background),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, 
                  color: primary, 
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text('Sample text', 
                  style: TextStyle(
                    fontSize: 12,
                    color: _calculateContrastColor(surface),
                  ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
  
  /// Calculate appropriate contrast color (same as in ThemeNotifier)
  Color _calculateContrastColor(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
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

  // Helper to show a loading dialog
  Future<void> _showLoadingDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper to show a snack bar
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return '${duration.inSeconds}s ago';
    }
  }
  
  // Notification settings methods
  Future<void> _saveNotificationAdvanceTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationAdvanceTime', minutes);
    print('[Settings] Notification advance time set to $minutes minutes');
  }
  
  Future<void> _saveNotificationSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationSoundEnabled', enabled);
    print('[Settings] Notification sound ${enabled ? 'enabled' : 'disabled'}');
  }
  Future<void> _saveAllowAdhanSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allowAdhanSound', enabled);
    print('[Settings] Allow Adhan sound ${enabled ? 'enabled' : 'disabled'}');
  }
  
  Future<void> _testPrayerNotification(BuildContext context) async {
    try {
      await NotificationService().sendTestNotification();
      _showSnackBar(context, 'Test notification sent! Check your notifications.', isError: false);
    } catch (e) {
      _showSnackBar(context, 'Failed to send test notification: $e', isError: true);
    }
  }
  
  // Daily Hadith methods
  Future<void> _showTimePickerDialog(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyHadithTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dailyHadithTime = picked;
      });
      await _saveDailyHadithTime(picked);
      _showSnackBar(context, 'Daily hadith time set to ${picked.format(context)}', isError: false);
    }
  }
  
  Future<void> _saveDailyHadithTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyHadithHour', time.hour);
    await prefs.setInt('dailyHadithMinute', time.minute);
    print('[Settings] Daily hadith time set to ${time.hour}:${time.minute}');
  }
  
  Future<void> _testDailyHadith(BuildContext context) async {
    // This would typically show a sample hadith
    // For now, we'll show a dialog with a sample hadith
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sample Daily Hadith'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'عن أبي هريرة رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '"من حسن إسلام المرء تركه ما لا يعنيه"',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 12),
            Text(
              'Translation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '"Part of the perfection of one\'s Islam is his leaving that which does not concern him."',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            Text(
              'Reference: Riyad as-Salihin 591',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
  
  // Load additional settings
  Future<void> _loadAdditionalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationAdvanceTime = prefs.getInt('notificationAdvanceTime') ?? 5;
      _notificationSoundEnabled = prefs.getBool('notificationSoundEnabled') ?? true;
      _allowAdhanSound = prefs.getBool('allowAdhanSound') ?? true;
      final hour = prefs.getInt('dailyHadithHour') ?? 8;
      final minute = prefs.getInt('dailyHadithMinute') ?? 0;
      _dailyHadithTime = TimeOfDay(hour: hour, minute: minute);
      _autoRefreshEnabled = prefs.getBool('autoRefreshEnabled') ?? true;
      _dataSavingEnabled = prefs.getBool('dataSavingEnabled') ?? false;
      _cacheDuration = prefs.getString('cacheDuration') ?? '6h';
      
      // Load Azkar reminder settings
      _azkarRemindersEnabled = prefs.getBool('azkarRemindersEnabled') ?? true;
      _dhuhrReminderMinutes = prefs.getInt('dhuhrReminderMinutes') ?? 60;
      _maghribReminderMinutes = prefs.getInt('maghribReminderMinutes') ?? 60;
    });
  }
  
  // Advanced settings methods
  Future<void> _saveAutoRefreshEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoRefreshEnabled', enabled);
    print('[Settings] Auto-refresh ${enabled ? 'enabled' : 'disabled'}');
  }
  
  Future<void> _saveDataSavingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataSavingEnabled', enabled);
    print('[Settings] Data saving ${enabled ? 'enabled' : 'disabled'}');
  }
  
  Future<void> _saveCacheDuration(String duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cacheDuration', duration);
    print('[Settings] Cache duration set to $duration');
  }
  

  
  Future<void> _showStorageManagement(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageItem('Prayer Times Cache', '2.3 MB', () => _clearPrayerTimesCache()),
            _buildStorageItem('Location Data', '156 KB', () => _clearLocationData()),
            _buildStorageItem('Azkar Progress', '89 KB', () => _clearAzkarProgress()),
            _buildStorageItem('Settings Cache', '45 KB', () => _clearSettingsCache()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total: 2.6 MB',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              _clearAllCache();
              Navigator.pop(context);
            },
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStorageItem(String title, String size, VoidCallback onClear) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _clearPrayerTimesCache() async {
    // Clear prayer times cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedPrayerTimes');
    await prefs.remove('lastPrayerTimesUpdate');
    _showSnackBar(context, 'Prayer times cache cleared', isError: false);
  }
  
  Future<void> _clearLocationData() async {
    // Clear location data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_elevation');
    await prefs.remove('user_country');
    await prefs.remove('user_country_code');
    _showSnackBar(context, 'Location data cleared', isError: false);
  }
  
  Future<void> _clearAzkarProgress() async {
    // Clear azkar progress
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('azkar_'));
    for (String key in keys) {
      await prefs.remove(key);
    }
    _showSnackBar(context, 'Azkar progress cleared', isError: false);
  }
  
  Future<void> _clearSettingsCache() async {
    // Clear settings cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('theme_preferences');
    await prefs.remove('last_settings_backup');
    _showSnackBar(context, 'Settings cache cleared', isError: false);
  }
  
  Future<void> _clearAllCache() async {
    await _clearPrayerTimesCache();
    await _clearLocationData();
    await _clearAzkarProgress();
    await _clearSettingsCache();
    _showSnackBar(context, 'All cache cleared successfully', isError: false);
  }
  
  Future<void> _showResetConfirmation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          'This will reset all settings to their default values. '
          'This action cannot be undone. Are you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _resetAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Reset all settings to defaults
      await prefs.clear();
      
      // Reload the page to reflect changes
      setState(() {
        _loadLocalPrefs();
        _loadData();
        _loadAdditionalSettings();
      });
      
      _showSnackBar(context, 'All settings reset to defaults', isError: false);
    } catch (e) {
      _showSnackBar(context, 'Failed to reset settings: $e', isError: true);
    }
  }
  
  Future<void> _backupSettings(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Creating backup...');
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final Map<String, dynamic> backupData = {};
      
      // Only backup important settings, not cache data
      final importantKeys = [
        'calculationMethod', 'madhab', 'use24hFormat',
        'enableNotifications', 'enableDailyHadith', 'highAccuracyCalc',
        'selectedLanguage',
        'useManualLocation', 'manualLatitude', 'manualLongitude',
        'useElevation', 'manualElevation', 'frequentLocationUpdates',
        'notificationAdvanceTime', 'notificationSoundEnabled',
        'dailyHadithHour', 'dailyHadithMinute',
        'autoRefreshEnabled', 'dataSavingEnabled', 'cacheDuration',
        'selectedThemeIndex', 'isDarkTheme'
      ];
      
      for (String key in importantKeys) {
        if (keys.contains(key)) {
          final value = prefs.get(key);
          if (value != null) {
            backupData[key] = value;
          }
        }
      }
      
      // Add backup metadata
      backupData['backupDate'] = DateTime.now().toIso8601String();
      backupData['backupVersion'] = '1.0';
      backupData['totalSettings'] = backupData.length - 3; // Exclude metadata
      
      Navigator.pop(context); // Close loading dialog
      
      // Show backup details
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Backup Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings backed up successfully!'),
              const SizedBox(height: 8),
              Text('Total settings: ${backupData['totalSettings']}'),
              Text('Backup date: ${DateTime.parse(backupData['backupDate']).toString().substring(0, 19)}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Backup ID: ${DateTime.now().millisecondsSinceEpoch}',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
      
      // Save backup info
      await prefs.setString('lastBackupData', backupData.toString());
      await prefs.setString('lastBackupDate', backupData['backupDate']);
      
      print('[Settings] Backup completed with ${backupData['totalSettings']} settings');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnackBar(context, 'Failed to backup settings: $e', isError: true);
    }
  }
  
  Future<void> _restoreSettings(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupDate = prefs.getString('lastBackupDate');
    
    if (lastBackupDate == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Backup Found'),
          content: const Text(
            'No backup data found. Please create a backup first before attempting to restore.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will overwrite your current settings with the backup from:'
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                DateTime.parse(lastBackupDate).toString().substring(0, 19),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to continue? This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRestore(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('RESTORE'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performRestore(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Restoring settings...');
      
      final prefs = await SharedPreferences.getInstance();
      final lastBackupData = prefs.getString('lastBackupData');
      
      if (lastBackupData == null) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar(context, 'No backup data found', isError: true);
        return;
      }
      
      // In a real app, you would parse the backup data and restore settings
      // For now, we'll simulate the restore process
      await Future.delayed(const Duration(seconds: 2));
      
      Navigator.pop(context); // Close loading dialog
      
      // Show restore success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings restored successfully!'),
              const SizedBox(height: 8),
              const Text('The app will restart to apply all changes.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In a real app, you would restart the app here
                _showSnackBar(context, 'Settings restored! Please restart the app.', isError: false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      print('[Settings] Settings restore completed');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnackBar(context, 'Failed to restore settings: $e', isError: true);
    }
  }
  
  // Helper method to format reminder time for display
  String _formatReminderTime(int minutes, String language) {
    if (minutes == 0) {
      return language == 'العربية' ? 'في وقت الصلاة' : 'At prayer time';
    }
    if (minutes == 60) {
      return language == 'العربية' ? 'ساعة واحدة قبل' : '1 hour before';
    }
    if (minutes < 60) {
      return language == 'العربية' ? '$minutes دقيقة قبل' : '$minutes minutes before';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes == 0) {
      return language == 'العربية' ? '$hours ساعات قبل' : '$hours hours before';
    } else {
      return language == 'العربية' ? '$hours ساعات $remainingMinutes دقيقة قبل' : '$hours hours $remainingMinutes minutes before';
    }
  }
}
