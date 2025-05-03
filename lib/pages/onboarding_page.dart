import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/prayer_settings_provider.dart';
import '../services/location_service.dart';
import 'splash_screen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  
  // Selected preferences
  String? _userCountry;
  CalculationMethod _selectedMethod = CalculationMethod.muslim_world_league;
  Madhab _selectedMadhab = Madhab.shafi;

  @override
  void initState() {
    super.initState();
    _detectUserRegion();
  }

  Future<void> _detectUserRegion() async {
    final country = await LocationService.getUserCountry();
    if (mounted && country != null) {
      setState(() {
        _userCountry = country;
        _selectedMethod = _getRecommendedCalculationMethod(country);
      });
    }
  }

  CalculationMethod _getRecommendedCalculationMethod(String country) {
    // Choose best calculation method based on region
    if (['Egypt', 'Sudan', 'Libya'].contains(country)) {
      return CalculationMethod.egyptian;
    } else if (['Pakistan', 'India', 'Bangladesh', 'Afghanistan'].contains(country)) {
      return CalculationMethod.karachi;
    } else if (['USA', 'Canada', 'UK', 'Mexico'].contains(country)) {
      return CalculationMethod.north_america;
    } else if (['Saudi Arabia', 'Qatar', 'Kuwait', 'UAE'].contains(country)) {
      return CalculationMethod.umm_al_qura;
    } else if (['Turkey'].contains(country)) {
      return CalculationMethod.turkey;
    } else if (['Singapore', 'Malaysia', 'Indonesia'].contains(country)) {
      return CalculationMethod.singapore;
    } else if (['Iran', 'Iraq'].contains(country)) {
      return CalculationMethod.tehran;
    }
    
    // Default to muslim_world_league
    return CalculationMethod.muslim_world_league;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(theme),
                  _buildPrayerSettingsPage(theme, l10n),
                  _buildNotificationsPage(theme, l10n),
                  _buildCompletionPage(theme, l10n),
                ],
              ),
            ),
            _buildBottomNavigation(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mosque_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 30),
          Text(
            'Welcome to Prayer App',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Your complete companion for prayers, azkar, qibla, and more.',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            'Let\'s set up your preferences to get the most accurate prayer times.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSettingsPage(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prayer Time Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          if (_userCountry != null)
            Text(
              'Based on your location ($_userCountry), we recommend:',
              style: theme.textTheme.titleMedium,
            ),
          const SizedBox(height: 30),
          _buildSettingSection(
            theme,
            title: 'Calculation Method',
            child: DropdownButtonFormField<CalculationMethod>(
              value: _selectedMethod,
              decoration: InputDecoration(
                labelText: 'Prayer Calculation Method',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (CalculationMethod? value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
              items: _buildCalculationMethodItems(),
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingSection(
            theme,
            title: 'Asr Calculation (Madhab)',
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<Madhab>(
                    title: const Text('Shafi\'i'),
                    subtitle: const Text('Standard shadow'),
                    value: Madhab.shafi,
                    groupValue: _selectedMadhab,
                    onChanged: (Madhab? value) {
                      if (value != null) {
                        setState(() {
                          _selectedMadhab = value;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<Madhab>(
                    title: const Text('Hanafi'),
                    subtitle: const Text('Double shadow'),
                    value: Madhab.hanafi,
                    groupValue: _selectedMadhab,
                    onChanged: (Madhab? value) {
                      if (value != null) {
                        setState(() {
                          _selectedMadhab = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<CalculationMethod>> _buildCalculationMethodItems() {
    final methods = [
      CalculationMethod.muslim_world_league,
      CalculationMethod.egyptian,
      CalculationMethod.karachi,
      CalculationMethod.umm_al_qura,
      CalculationMethod.dubai,
      CalculationMethod.qatar,
      CalculationMethod.kuwait,
      CalculationMethod.moon_sighting_committee,
      CalculationMethod.singapore,
      CalculationMethod.turkey,
      CalculationMethod.tehran,
      CalculationMethod.north_america,
    ];
    
    return methods.map((method) {
      return DropdownMenuItem(
        value: method,
        child: Text(_getMethodName(method)),
      );
    }).toList();
  }
  
  String _getMethodName(CalculationMethod method) {
    return method.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
  }

  Widget _buildNotificationsPage(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Would you like to receive notifications for prayer times?',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 30),
          ListTile(
            title: const Text('Prayer Time Notifications'),
            subtitle: const Text('Receive notifications for each prayer time'),
            leading: Icon(Icons.notifications_active, color: theme.colorScheme.primary),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: theme.colorScheme.primary,
            ),
          ),
          ListTile(
            title: const Text('Adhan Notifications'),
            subtitle: const Text('Play adhan sound for prayer notifications'),
            leading: Icon(Icons.volume_up, color: theme.colorScheme.primary),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: theme.colorScheme.primary,
            ),
          ),
          ListTile(
            title: const Text('Daily Hadith'),
            subtitle: const Text('Receive a daily hadith notification'),
            leading: Icon(Icons.book, color: theme.colorScheme.primary),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionPage(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 30),
          Text(
            'Setup Complete!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'You\'re all set to start using the Prayer App. You can change any of these settings later.',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : _finishOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildBottomNavigation(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Previous',
                style: TextStyle(fontSize: 16, color: theme.colorScheme.primary),
              ),
            )
          else
            const SizedBox(width: 80),
          Row(
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
            ),
          ),
          if (_currentPage < 3)
            TextButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Next',
                style: TextStyle(fontSize: 16, color: theme.colorScheme.primary),
              ),
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Save all the settings to provider and preferences
      final prefs = Provider.of<PrayerSettingsProvider>(context, listen: false);
      
      // Update calculation method and madhab
      prefs.updateCalculationMethod(_selectedMethod);
      prefs.updateMadhab(_selectedMadhab);
      
      // Navigate to main app
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 