import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A card widget that displays a single prayer time with name, time, and checked status
class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final DateTime prayerTime;
  final String timeFormatted;
  final bool isNext;
  final bool checked;
  final VoidCallback? onToggle;
  final bool use24hFormat;
  final bool highContrast;

  /// Creates a prayer time card
  /// 
  /// [prayerName] The name of the prayer (e.g., "Fajr", "Dhuhr")
  /// [prayerTime] The DateTime when the prayer is scheduled
  /// [timeFormatted] Pre-formatted time string (alternative to using prayerTime with formatting)
  /// [isNext] Whether this is the next upcoming prayer
  /// [checked] Whether the prayer has been marked as performed
  /// [onToggle] Callback when the check status is toggled
  /// [use24hFormat] Whether to use 24h format for displaying time
  /// [highContrast] Whether to use high contrast colors for better visibility
  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.timeFormatted,
    this.isNext = false,
    this.checked = false,
    this.onToggle,
    this.use24hFormat = false,
    this.highContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Localized prayer name
    String localizedName = '';
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        localizedName = l10n.fajr;
        break;
      case 'sunrise':
        localizedName = l10n.sunrise;
        break;
      case 'dhuhr':
        localizedName = l10n.dhuhr;
        break;
      case 'asr':
        localizedName = l10n.asr;
        break;
      case 'maghrib':
        localizedName = l10n.maghrib;
        break;
      case 'isha':
        localizedName = l10n.isha;
        break;
      default:
        localizedName = prayerName;
    }

    // Format time based on preferences
    final timeFormat = use24hFormat ? DateFormat.Hm() : DateFormat.jm();
    final formattedTime = timeFormatted.isNotEmpty 
      ? timeFormatted 
      : timeFormat.format(prayerTime);

    // Card styling based on status
    final cardColor = isNext
        ? theme.colorScheme.primary.withOpacity(0.2)
        : theme.colorScheme.surface;
    
    final textColor = isNext
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isNext ? 4 : 1,
      color: cardColor,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Prayer name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Checkbox or indicator
              if (onToggle != null)
                Checkbox(
                  value: checked,
                  onChanged: (_) => onToggle?.call(),
                  activeColor: theme.colorScheme.primary,
                ),
              
              // Next prayer indicator
              if (isNext)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.nextPrayer,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 