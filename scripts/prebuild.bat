@echo off
echo 🚀 Pre-build script started...

REM Generate localization files
echo 📄 Generating localization files...
flutter gen-l10n

REM Check if localization files were generated
if exist ".dart_tool\flutter_gen\gen_l10n\app_localizations.dart" (
    echo ✅ Localization files generated successfully
) else (
    echo ❌ Failed to generate localization files
    exit /b 1
)

REM Get dependencies
echo 📦 Getting Flutter dependencies...
flutter pub get

echo ✅ Pre-build script completed successfully! 