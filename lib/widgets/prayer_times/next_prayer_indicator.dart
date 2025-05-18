import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// A widget that displays information about the next prayer including a countdown timer.
class NextPrayerIndicator extends StatelessWidget {
  /// The name of the next prayer
  final String nextPrayerName;
  
  /// Time remaining until the next prayer (in seconds)
  final Duration timeUntil;
  
  /// Progress value between 0.0 and 1.0 indicating how close the next prayer is
  final double progress;
  
  /// Random tip to display
  final String randomTip;
  
  /// Creates a NextPrayerIndicator widget
  /// 
  /// [nextPrayerName] The name of the next prayer
  /// [timeUntil] Time remaining until the next prayer
  /// [progress] Progress value (0.0-1.0) indicating how close the next prayer is
  /// [randomTip] Optional tip to display below the timer
  const NextPrayerIndicator({
    super.key,
    required this.nextPrayerName,
    required this.timeUntil,
    required this.progress,
    required this.randomTip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Determine localized prayer name
    String localizedName = '';
    switch (nextPrayerName.toLowerCase()) {
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
        localizedName = nextPrayerName;
    }
    
    // Format the time remaining
    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes % 60;
    final seconds = timeUntil.inSeconds % 60;
    
    String formattedTime = '';
    if (hours > 0) {
      formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            Text(
              l10n.nextPrayerIs(localizedName),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Circular countdown timer
            CircularPercentIndicator(
              radius: 70,
              lineWidth: 8.0,
              percent: progress,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.remaining,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              progressColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceVariant,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1000,
            ),
            
            const SizedBox(height: 20),
            
            // Tip section
            if (randomTip.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        randomTip,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 