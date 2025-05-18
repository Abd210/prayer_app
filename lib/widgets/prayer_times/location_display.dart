import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A widget that displays the current location and date
class LocationDisplay extends StatelessWidget {
  /// The city name to display
  final String cityName;
  
  /// The date to display
  final DateTime date;
  
  /// Whether there was a permission error with location
  final bool hasPermissionError;
  
  /// Callback to request location permissions
  final VoidCallback? onRequestPermission;
  
  /// Creates a LocationDisplay widget
  /// 
  /// [cityName] The name of the city to display
  /// [date] The current date to display
  /// [hasPermissionError] Whether there was a permission error with location
  /// [onRequestPermission] Callback to request location permissions
  const LocationDisplay({
    super.key,
    required this.cityName,
    required this.date,
    this.hasPermissionError = false,
    this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Format the date
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final formattedDate = dateFormat.format(date);
    
    if (hasPermissionError) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                l10n.locationPermissionDenied,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.location_on),
                label: Text(l10n.allowLocationAccess),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cityName.isEmpty ? '...' : cityName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onBackground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
} 