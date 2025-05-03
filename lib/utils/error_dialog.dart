import 'package:flutter/material.dart';
import '../services/location_service.dart';

class ErrorDialog {
  /// Show a location error dialog with appropriate actions
  static Future<void> showLocationErrorDialog(
    BuildContext context,
    LocationError error,
  ) async {
    final theme = Theme.of(context);
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Location Error'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(error.message),
                const SizedBox(height: 16),
                if (error.type == LocationErrorType.serviceDisabled)
                  _buildHelpText('Please enable location services in your device settings.'),
                if (error.type == LocationErrorType.permissionDenied)
                  _buildHelpText('This app requires location permission to provide accurate prayer times.'),
                if (error.type == LocationErrorType.permissionDeniedForever)
                  _buildHelpText('Please go to your device settings and enable location permission for this app.'),
                if (error.type == LocationErrorType.timeout)
                  _buildHelpText('Your location could not be determined. You can set a manual location in settings.'),
              ],
            ),
          ),
          actions: <Widget>[
            if (error.type == LocationErrorType.timeout)
              TextButton(
                child: Text(
                  'Use Manual Location',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _showManualLocationDialog(context);
                },
              ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  static Widget _buildHelpText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
  
  static Future<void> _showManualLocationDialog(BuildContext context) async {
    // Implementation of manual location dialog
    // This could navigate to the settings page or show a manual location input dialog
  }
  
  /// Show a generic error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
} 