import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/prayer_settings_provider.dart';

/// A widget for prayer calculation settings including calculation method and madhab
class PrayerCalculationSettings extends StatelessWidget {
  /// Creates a prayer calculation settings widget
  const PrayerCalculationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PrayerSettingsProvider>(context);
    final l10n = AppLocalizations.of(context)!;
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.prayerCalculation, Icons.calculate, context),
        
        // Calculation method
        _buildSettingTile(
          context,
          leading: Icons.public,
          title: l10n.calculationMethod,
          subtitle: _getMethodName(prefs.calculationMethod),
          onTap: () => _showCalculationMethodDialog(context, calculationMethods, prefs),
        ),
        
        // Madhab for Asr calculation
        _buildSettingTile(
          context,
          leading: Icons.brightness_4,
          title: l10n.asrCalculation,
          subtitle: prefs.madhab == Madhab.hanafi
              ? l10n.hanafiMadhab
              : l10n.shafiiMadhab,
          trailing: Switch(
            value: prefs.madhab == Madhab.hanafi,
            onChanged: (value) {
              prefs.updateMadhab(value ? Madhab.hanafi : Madhab.shafi);
            },
            activeColor: theme.colorScheme.primary,
          ),
        ),
        
        // High accuracy calculation
        _buildSettingTile(
          context,
          leading: Icons.science,
          title: l10n.highPrecisionMode,
          subtitle: l10n.highPrecisionExplanation,
          trailing: Switch(
            value: prefs.highAccuracyMode,
            onChanged: (value) {
              prefs.toggleHighAccuracyMode(value);
            },
            activeColor: theme.colorScheme.primary,
          ),
        ),
        
        // Manual time adjustments
        _buildSettingTile(
          context,
          leading: Icons.tune,
          title: l10n.timeAdjustments,
          subtitle: l10n.timeAdjustmentsExplanation,
          onTap: () => _showTimeAdjustmentsDialog(context, prefs),
        ),
        
        // Use elevation for calculation
        _buildSettingTile(
          context,
          leading: Icons.terrain,
          title: l10n.useElevation,
          subtitle: l10n.elevationExplanation,
          trailing: Switch(
            value: prefs.useElevation,
            onChanged: (value) {
              prefs.toggleUseElevation(value);
            },
            activeColor: theme.colorScheme.primary,
          ),
        ),
        
        // Manual elevation input (if enabled)
        if (prefs.useElevation)
          _buildSettingTile(
            context,
            leading: Icons.height,
            title: l10n.manualElevation,
            subtitle: '${prefs.manualElevation.toStringAsFixed(1)} m',
            onTap: () => _showElevationDialog(context, prefs),
          ),
        
        // Time format setting
        _buildSettingTile(
          context,
          leading: Icons.access_time,
          title: l10n.timeFormat,
          subtitle: prefs.use24hFormat ? l10n.format24h : l10n.format12h,
          trailing: Switch(
            value: prefs.use24hFormat,
            onChanged: (value) {
              prefs.toggle24hFormat(value);
            },
            activeColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
  
  /// Get a readable name for the calculation method
  String _getMethodName(CalculationMethod method) {
    return method.name
      .replaceAll('_', ' ')
      .split(' ')
      .map((s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}')
      .join(' ');
  }
  
  Widget _buildSectionHeader(String title, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            icon, 
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingTile(
    BuildContext context, {
    required IconData leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(leading, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
  
  void _showCalculationMethodDialog(
    BuildContext context, 
    List<CalculationMethod> methods,
    PrayerSettingsProvider prefs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectCalculationMethod),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final method = methods[index];
                final isSelected = prefs.calculationMethod == method;
                
                return ListTile(
                  title: Text(_getMethodName(method)),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    prefs.updateCalculationMethod(method);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
  
  void _showTimeAdjustmentsDialog(BuildContext context, PrayerSettingsProvider prefs) {
    final l10n = AppLocalizations.of(context)!;
    
    // Get current adjustments
    int fajrAdjustment = prefs.fajrAdjustment;
    int dhuhrAdjustment = prefs.dhuhrAdjustment;
    int asrAdjustment = prefs.asrAdjustment;
    int maghribAdjustment = prefs.maghribAdjustment;
    int ishaAdjustment = prefs.ishaAdjustment;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.timeAdjustments),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.timeAdjustmentsExplanation),
                    const SizedBox(height: 16),
                    
                    // Fajr adjustment
                    _buildAdjustmentSlider(
                      context,
                      title: l10n.fajr,
                      value: fajrAdjustment,
                      onChanged: (value) {
                        setState(() => fajrAdjustment = value.round());
                      },
                    ),
                    
                    // Dhuhr adjustment
                    _buildAdjustmentSlider(
                      context,
                      title: l10n.dhuhr,
                      value: dhuhrAdjustment,
                      onChanged: (value) {
                        setState(() => dhuhrAdjustment = value.round());
                      },
                    ),
                    
                    // Asr adjustment
                    _buildAdjustmentSlider(
                      context,
                      title: l10n.asr,
                      value: asrAdjustment,
                      onChanged: (value) {
                        setState(() => asrAdjustment = value.round());
                      },
                    ),
                    
                    // Maghrib adjustment
                    _buildAdjustmentSlider(
                      context,
                      title: l10n.maghrib,
                      value: maghribAdjustment,
                      onChanged: (value) {
                        setState(() => maghribAdjustment = value.round());
                      },
                    ),
                    
                    // Isha adjustment
                    _buildAdjustmentSlider(
                      context,
                      title: l10n.isha,
                      value: ishaAdjustment,
                      onChanged: (value) {
                        setState(() => ishaAdjustment = value.round());
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Update all adjustments
                    prefs.updatePrayerAdjustment('fajr', fajrAdjustment);
                    prefs.updatePrayerAdjustment('dhuhr', dhuhrAdjustment);
                    prefs.updatePrayerAdjustment('asr', asrAdjustment);
                    prefs.updatePrayerAdjustment('maghrib', maghribAdjustment);
                    prefs.updatePrayerAdjustment('isha', ishaAdjustment);
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildAdjustmentSlider(
    BuildContext context, {
    required String title,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${value >= 0 ? '+' : ''}$value ${value == 1 || value == -1 ? 'minute' : 'minutes'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: value.toDouble(),
          min: -30,
          max: 30,
          divisions: 60,
          label: value.toString(),
          onChanged: onChanged,
        ),
        const Divider(),
      ],
    );
  }
  
  void _showElevationDialog(BuildContext context, PrayerSettingsProvider prefs) {
    final l10n = AppLocalizations.of(context)!;
    double elevation = prefs.manualElevation;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.manualElevation),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.elevationExplanation),
                  const SizedBox(height: 16),
                  Text(
                    '${elevation.toStringAsFixed(1)} m',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Slider(
                    value: elevation,
                    min: 0,
                    max: 5000,
                    divisions: 100,
                    label: elevation.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() => elevation = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    prefs.setManualElevation(elevation);
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 