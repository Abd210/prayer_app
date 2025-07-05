# Build Guide for Prayer App

## Prerequisites

- Flutter SDK (stable channel)
- Xcode (for iOS builds)
- CocoaPods (for iOS dependencies)

## Local Build Instructions

### 1. Setup Dependencies
```bash
flutter pub get
flutter gen-l10n
```

### 2. Build for Different Platforms

#### Web Build
```bash
flutter build web --release
```

#### iOS Build (requires macOS)
```bash
flutter build ios --release --no-codesign
```

#### Android Build
```bash
flutter build apk --release
```

## GitHub Actions iOS Build

The project includes a GitHub Actions workflow (`.github/workflows/ios-build.yml`) that automatically builds an IPA file for iOS.

### Key Steps in the Workflow:
1. **Setup Flutter**: Installs Flutter SDK
2. **Get Dependencies**: Runs `flutter pub get`
3. **Generate Localizations**: Runs `flutter gen-l10n` to generate localization files
4. **Clean Build**: Ensures a fresh build environment
5. **Update CocoaPods**: Updates iOS dependencies
6. **Build iOS App**: Creates the iOS app without code signing
7. **Create IPA**: Packages the app into an IPA file
8. **Upload Release**: Uploads the IPA to GitHub releases

### Troubleshooting

#### Issue: "Couldn't resolve the package 'flutter_gen'"
**Solution**: This happens when localization files aren't generated. The workflow now includes:
- `flutter gen-l10n` step
- Clean build process
- Verification of generated files

#### Issue: Missing translations
**Solution**: Check that all required keys are present in both `app_en.arb` and `app_ar.arb` files.

#### Issue: CocoaPods errors
**Solution**: The workflow includes `pod repo update` and `pod install` steps to ensure dependencies are properly resolved.

## Manual Build Scripts

### Windows
Run the PowerShell script (recommended):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\prebuild.ps1
```

Or run the batch script:
```batch
scripts\prebuild.bat
```

### macOS/Linux
Run `scripts/prebuild.sh` before building:
```bash
chmod +x scripts/prebuild.sh
./scripts/prebuild.sh
```

## Important Notes

1. **Localization**: Always run `flutter gen-l10n` after modifying `.arb` files
2. **Clean Builds**: If you encounter build issues, try `flutter clean` followed by `flutter pub get`
3. **iOS Signing**: The GitHub Actions workflow builds without code signing - you'll need to sign manually for distribution
4. **Dependencies**: Keep dependencies updated but test thoroughly after updates

## Files Modified for Build Fix

- `.github/workflows/ios-build.yml` - Updated workflow with proper localization generation
- `lib/l10n/app_ar.arb` - Fixed missing `startsIn` translation
- `l10n.yaml` - Updated to use explicit output directory and disable synthetic package
- `pubspec.yaml` - Updated Flutter configuration
- `lib/main.dart` and all other Dart files - Updated import paths to use new localization structure
- `scripts/prebuild.sh` - Linux/macOS prebuild script
- `scripts/prebuild.bat` - Windows batch prebuild script
- `scripts/prebuild.ps1` - Windows PowerShell prebuild script

## Changes Made to Fix Flutter Gen Issue

The main issue was that Flutter's `flutter_gen` synthetic package approach was deprecated in newer Flutter versions. The solution involved:

1. **Updated l10n.yaml configuration**:
   - Added explicit `output-dir: lib/generated/l10n`
   - Added `synthetic-package: false` to disable the deprecated approach

2. **Updated all import statements**:
   - Changed from `import 'package:flutter_gen/gen_l10n/app_localizations.dart';`
   - To `import 'package:prayer/generated/l10n/app_localizations.dart';`

3. **Updated GitHub Actions workflow**:
   - Changed verification path from `.dart_tool/flutter_gen/gen_l10n/`
   - To `lib/generated/l10n/` 