Write-Host "Pre-build script started..." -ForegroundColor Green

# Generate localization files
Write-Host "Generating localization files..." -ForegroundColor Yellow
flutter gen-l10n

# Check if localization files were generated
if (Test-Path "lib\generated\l10n\app_localizations.dart") {
    Write-Host "Localization files generated successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to generate localization files" -ForegroundColor Red
    exit 1
}

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "Pre-build script completed successfully!" -ForegroundColor Green 