#!/bin/bash

echo "🚀 Pre-build script started..."

# Generate localization files
echo "📄 Generating localization files..."
flutter gen-l10n

# Check if localization files were generated
if [ -f ".dart_tool/flutter_gen/gen_l10n/app_localizations.dart" ]; then
    echo "✅ Localization files generated successfully"
else
    echo "❌ Failed to generate localization files"
    exit 1
fi

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "✅ Pre-build script completed successfully!" 