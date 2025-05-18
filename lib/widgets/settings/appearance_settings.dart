import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../theme/theme_notifier.dart';

/// A widget for appearance settings including theme selection and customization
class AppearanceSettings extends StatelessWidget {
  /// Creates an appearance settings widget
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    /// Preview swatches for predefined light‑theme palettes (index 0‑7)
    final Map<int, List<Color>> themeSwatchMap = {
      0: [const Color(0xFF16423C), const Color(0xFF6A9C89), const Color(0xFFE9EFEC)],
      1: [const Color(0xFF5B6EAE), const Color(0xFFA8B9EE), const Color(0xFFF2F2F7)],
      2: [const Color(0xFF009688), const Color(0xFFFF9800), const Color(0xFFF9FAFB)],
      3: [const Color(0xFF7E57C2), const Color(0xFFD1B2FF), const Color(0xFFF6F2FB)],
      4: [const Color(0xFFA38671), const Color(0xFFD7C3B5), const Color(0xFFFAF2EB)],
      5: [const Color(0xFF243B55), const Color(0xFFFFD966), const Color(0xFFFDFCF7)],
      6: [const Color(0xFF7D0A0A), const Color(0xFFBF3131), const Color(0xFFF3EDC8)],
      7: [const Color(0xFFAC1754), const Color(0xFFE53888), const Color(0xFFF7A8C4)],
      // index 8 is custom – handled dynamically
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.appearance, Icons.palette_outlined, context),
        
        // Dark mode toggle
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
        
        // Theme selection
        if (!themeNotifier.isDarkTheme)
          _buildSettingTile(
            context,
            leading: Icons.color_lens_outlined,
            title: l10n.selectColorTheme,
            subtitle: '${l10n.currentTheme} ${themeNotifier.selectedThemeIndex + 1}',
            trailing: Wrap(
              spacing: 4,
              children: _themePreviewSwatches(
                themeSwatchMap,
                themeNotifier.selectedThemeIndex, 
                themeNotifier,
              ),
            ),
            onTap: () => _showSelectThemeDialog(context, themeSwatchMap, themeNotifier),
          ),
        
        // Custom theme option
        if (!themeNotifier.isDarkTheme && themeNotifier.selectedThemeIndex == 8)
          _buildSettingTile(
            context,
            leading: Icons.palette,
            title: l10n.customizeTheme,
            subtitle: l10n.pickCustomColors,
            onTap: () => _showCustomColorDialog(context, themeNotifier),
          ),
      ],
    );
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
  
  List<Widget> _themePreviewSwatches(
    Map<int, List<Color>> themeSwatchMap,
    int selectedIndex, 
    ThemeNotifier themeNotifier,
  ) {
    final List<Widget> swatches = [];
    
    // For the selected theme, show a border
    final selectedIndex = themeNotifier.selectedThemeIndex;
    
    // For the custom theme (index 8), show its actual colors
    List<Color> customColors = [];
    if (selectedIndex == 8) {
      customColors = [
        themeNotifier.customPrimary,
        themeNotifier.customSecondary,
        themeNotifier.customBackground,
      ];
    }
    
    // Add a color circle for each theme
    for (int i = 0; i < 9; i++) {
      final isSelected = (selectedIndex == i);
      final colors = (i == 8) ? customColors : themeSwatchMap[i]!;
      
      swatches.add(
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                    )
                  ]
                : null,
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      );
    }
    
    return swatches;
  }
  
  void _showSelectThemeDialog(
    BuildContext context,
    Map<int, List<Color>> themeSwatchMap,
    ThemeNotifier themeNotifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectTheme),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9, // 8 predefined + 1 custom
              itemBuilder: (context, index) {
                // For custom theme (index 8), show actual colors
                final isCustom = index == 8;
                final List<Color> colors = isCustom
                    ? [
                        themeNotifier.customPrimary,
                        themeNotifier.customSecondary,
                        themeNotifier.customBackground,
                      ]
                    : themeSwatchMap[index]!;
                
                return InkWell(
                  onTap: () {
                    themeNotifier.setThemeIndex(index);
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: themeNotifier.selectedThemeIndex == index
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCustom ? l10n.customTheme : '${l10n.theme} ${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: themeNotifier.selectedThemeIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
  
  void _showCustomColorDialog(BuildContext context, ThemeNotifier themeNotifier) {
    final l10n = AppLocalizations.of(context)!;
    
    // Colors to modify and update
    Color primaryColor = themeNotifier.customPrimary;
    Color secondaryColor = themeNotifier.customSecondary;
    Color backgroundColor = themeNotifier.customBackground;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.customizeTheme),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary color picker
                    Text(
                      l10n.primaryColor,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ColorPicker(
                      pickerColor: primaryColor,
                      onColorChanged: (color) {
                        setState(() => primaryColor = color);
                      },
                      pickerAreaHeightPercent: 0.2,
                      displayThumbColor: true,
                      enableAlpha: false,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Secondary color picker
                    Text(
                      l10n.accentColor,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ColorPicker(
                      pickerColor: secondaryColor,
                      onColorChanged: (color) {
                        setState(() => secondaryColor = color);
                      },
                      pickerAreaHeightPercent: 0.2,
                      displayThumbColor: true,
                      enableAlpha: false,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Background color picker
                    Text(
                      l10n.backgroundColor,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ColorPicker(
                      pickerColor: backgroundColor,
                      onColorChanged: (color) {
                        setState(() => backgroundColor = color);
                      },
                      pickerAreaHeightPercent: 0.2,
                      displayThumbColor: true,
                      enableAlpha: false,
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
                    themeNotifier.setCustomThemeColors(
                      primary: primaryColor,
                      secondary: secondaryColor,
                      background: backgroundColor,
                      surface: Colors.grey.shade100,
                    );
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