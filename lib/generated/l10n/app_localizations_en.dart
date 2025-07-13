// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Advanced Islamic App';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get aboutApp => 'About App';

  @override
  String get selectColorTheme => 'Select App Color Theme';

  @override
  String get customTheme => 'Custom Theme';

  @override
  String get enableDarkMode => 'Enable Dark Mode';

  @override
  String get enableLightMode => 'Enable Light Mode';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get enableDailyHadith => 'Enable Daily Hadith';

  @override
  String get highAccuracyCalculation => 'High Accuracy Calculation';

  @override
  String get highAccuracySubtitle => 'Includes elevation for more precise times';

  @override
  String get frequentLocationUpdates => 'Frequent Location Updates';

  @override
  String get frequentLocationSubtitle => 'Higher accuracy but more battery usage';

  @override
  String get otherSettings => 'Other Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get calculationMethodLabel => 'Prayer Calculation Method';

  @override
  String get calculationMethodTitle => 'Prayer Calculation Method';

  @override
  String get asrCalculationTitle => 'Asr Prayer Calculation';

  @override
  String get madhab => 'Madhab';

  @override
  String get use24HourFormat => 'Use 24‑hour Format';

  @override
  String get use24hFormat => 'Use 24‑hour Format';

  @override
  String get timeFormatTitle => 'Time Format';

  @override
  String get shafiiLabel => 'Shafii';

  @override
  String get shafiiDescription => 'Standard shadow length (majority of scholars)';

  @override
  String get hanafiLabel => 'Hanafi';

  @override
  String get hanafiDescription => 'Double shadow length';

  @override
  String get notifications => 'Notifications';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get pick => 'Pick';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get createCustomTheme => 'Create Your Own Theme';

  @override
  String get chooseLightTheme => 'Choose a Light Theme';

  @override
  String get currentTheme => 'Current:';

  @override
  String get primary => 'Primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get background => 'Background';

  @override
  String get surface => 'Surface';

  @override
  String nextPrayerLabel(String prayerName) {
    return 'Next Prayer: $prayerName';
  }

  @override
  String startsIn(String countdown) {
    return 'Starts in $countdown';
  }

  @override
  String get returnToToday => 'Return to Today';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get reload => 'Reload';

  @override
  String get statisticsTooltip => 'Statistics';

  @override
  String get sunnahTimes => 'Sunnah Times';

  @override
  String get tipOfDay => 'Tip of the Day:';

  @override
  String get prayerTimeTitle => 'Prayer Time';

  @override
  String prayerNotificationBody(String prayerName, String city) {
    return 'It\'s time for $prayerName prayer in $city';
  }

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get middleNight => 'Middle of Night';

  @override
  String get lastThirdNight => 'Last Third of Night';

  @override
  String get tipEstablishPrayer => '\"Establish prayer and give charity.\"';

  @override
  String get tipBetterThanSleep => '\"Prayer is better than sleep.\"';

  @override
  String get tipCallUponMe => '\"Call upon Me, I will respond.\"';

  @override
  String get tipReflectQuran => 'Reflect upon the Quran daily for spiritual growth.';

  @override
  String get tipKhushu => 'Strive for khushū` (humility) in prayer.';

  @override
  String get tipSharePrayer => 'Share your knowledge of prayer times with friends.';

  @override
  String get tipSunnah => 'Keep consistent with Sunnah prayers for extra reward.';

  @override
  String get navPrayers => 'Prayers';

  @override
  String get navAzkar => 'Azkār';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navQuran => 'Quran';

  @override
  String get navSettings => 'Settings';

  @override
  String get locating => 'Locating…';

  @override
  String get refreshCompass => 'Refresh location & heading';

  @override
  String get headingLabel => 'Heading';

  @override
  String get qiblaLabel => 'Qibla';

  @override
  String get facingQibla => 'You are facing the Qibla!';

  @override
  String deltaFromQibla(Object degrees) {
    return 'Δ $degrees° from Qibla';
  }

  @override
  String get compassWarnInterference => 'Compass accuracy may drop if you\'re near magnetic fields or metal objects.';

  @override
  String get compassWarnNeedle => 'The orange needle points toward the Qibla direction.';

  @override
  String get azkarTasbihTitle => 'Azkar & Tasbih';

  @override
  String get freeTasbih => 'Free Tasbih';

  @override
  String get statsTitle => 'Azkar Statistics';

  @override
  String get statsNoData => 'No statistics yet.\nFinish any Azkar list and come back!';

  @override
  String get tabDaily => 'Daily';

  @override
  String get tabWeekly => 'Weekly';

  @override
  String get tabMonthly => 'Monthly';

  @override
  String get kpiDays => 'Days';

  @override
  String get kpiStreak => 'Streak';

  @override
  String get kpiBest => 'Best';

  @override
  String get week => 'Week';

  @override
  String get weekShort => 'W';

  @override
  String needMoreData(Object period) {
    return 'Need more data to draw a $period trend';
  }

  @override
  String percentCompleted(Object percent) {
    return '$percent % completed';
  }

  @override
  String get periodDaily => 'daily';

  @override
  String get periodWeekly => 'weekly';

  @override
  String get periodMonthly => 'monthly';

  @override
  String get tasbihTitle => 'Tasbih Advanced';

  @override
  String get globalTasbih => 'Global Tasbih';

  @override
  String get subCounters => 'Sub‑Counters';

  @override
  String get resetAll => 'Reset All';

  @override
  String get tasbihHint => 'Tap the main box for a global count.\nTap any sub box for specific counts (33 each).';

  @override
  String get compactView => 'Compact View';

  @override
  String get expandedView => 'Expanded View';

  @override
  String get azkarCopy => 'Copy';

  @override
  String get azkarCopied => 'Azkar text copied to clipboard!';

  @override
  String get tapAnywhere => 'Tap Anywhere to Count';

  @override
  String get azkarReminder => 'Remembrance of Allah is the greatest (Qur\'an 29:45).';

  @override
  String azkarCompletedTitle(Object title) {
    return '$title Completed!';
  }

  @override
  String get azkarCompletedContent => 'You have finished all azkār in this category.';

  @override
  String get ok => 'OK';

  @override
  String get azkarTab => 'Azkar';

  @override
  String get tasbihTab => 'Tasbih';

  @override
  String get customAzkar => 'Custom Azkar';

  @override
  String get manageCustomAzkar => 'Manage Custom Azkar';

  @override
  String get createAndEditCustomAzkar => 'Create and edit your own azkar collections';

  @override
  String get createAzkar => 'Create Azkar';

  @override
  String get editAzkar => 'Edit Azkar';

  @override
  String get noCustomAzkar => 'You don\'t have any custom azkar yet.\nCreate your first one!';

  @override
  String get createNewAzkar => 'Create New Azkar';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get title => 'Title';

  @override
  String get arabicTitle => 'Arabic Title';

  @override
  String get selectColor => 'Select Color';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get items => 'Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get noItemsYet => 'You haven\'t added any items yet.\nClick the button above to add a new one.';

  @override
  String deleteConfirmation(Object title) {
    return 'Are you sure you want to delete \'$title\'?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get deleted => 'deleted';

  @override
  String get requiredField => 'This field is required';

  @override
  String get arabicText => 'Arabic Text';

  @override
  String get description => 'Description';

  @override
  String get repeat => 'Repeat';

  @override
  String get enterArabicText => 'Enter Arabic text here...';

  @override
  String get addItemsFirst => 'Please add at least one item first';

  @override
  String get errorSaving => 'Error saving. Please try again.';

  @override
  String get deleteItemConfirmation => 'Are you sure you want to delete this item?';

  @override
  String get quranTitle => 'Quran';

  @override
  String get searchHint => 'Search for a verse';

  @override
  String searchNoResults(Object query) {
    return 'No verses found for \'$query\'';
  }

  @override
  String get searchPrompt => 'Type a word or phrase to search in the Quran';

  @override
  String searchSuggestions(Object query) {
    return 'Search verses containing: $query';
  }

  @override
  String searchResultTitle(Object surah, Object verse) {
    return 'Surah $surah: Verse $verse';
  }

  @override
  String juzLabel(Object number) {
    return 'Juz $number';
  }

  @override
  String juzSurahHeader(Object juz) {
    return 'Surahs in Juz $juz';
  }

  @override
  String versesLabel(Object count) {
    return '$count Verses';
  }

  @override
  String get playEntireSurah => 'Play Entire Surah';

  @override
  String get prayerTimeAdjustments => 'Prayer Time Adjustments';

  @override
  String get adjustmentMinutes => 'Adjustment';

  @override
  String get resetAdjustments => 'Reset Adjustments';

  @override
  String get locationSettings => 'Location Settings';

  @override
  String get manualLocation => 'Manual Location';

  @override
  String get adhanSettings => 'Adhan Settings';

  @override
  String get enableAdhan => 'Enable Adhan';

  @override
  String get adhanVolume => 'Adhan Volume';

  @override
  String get testAdhan => 'Test Adhan';

  @override
  String get autoNext => 'Auto Next';

  @override
  String get manualNext => 'Manual Next';

  @override
  String get autoDetectMethod => 'Auto-detect Method';

  @override
  String get autoDetectMethodSubtitle => 'Automatically detect calculation method based on your location';

  @override
  String get manualCalculationMethod => 'Manual Calculation Method';

  @override
  String get detectMethodNow => 'Detect Method Now';

  @override
  String get detectingMethod => 'Detecting method...';

  @override
  String get methodUpdatedAuto => 'Calculation method updated automatically!';

  @override
  String get methodUnchanged => 'Calculation method unchanged';

  @override
  String get methodUpdatedForLocation => 'Calculation method updated automatically for your new location';

  @override
  String get azkarReminders => 'Azkar Reminders';

  @override
  String get enableAzkarReminders => 'Enable Azkar Reminders';

  @override
  String get azkarRemindersEnabled => 'Azkar reminders are enabled';

  @override
  String get azkarRemindersDisabled => 'Azkar reminders are disabled';

  @override
  String get dhuhrAzkarReminder => 'Dhuhr Azkar Reminder';

  @override
  String get maghribAzkarReminder => 'Maghrib Azkar Reminder';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get testReminder => 'Test Reminder';

  @override
  String get azkarReminderInfo => 'Azkar Reminder Info';

  @override
  String get azkarReminderInfoText => '• Dhuhr: Morning azkar reminder before Dhuhr prayer\n• Maghrib: Evening azkar reminder before Maghrib prayer\n• Customizable: Adjust timing as you prefer\n• Daily: Reminders repeat every day';

  @override
  String get azkarRemindersEnabledMsg => 'Azkar reminders enabled';

  @override
  String get azkarRemindersDisabledMsg => 'Azkar reminders disabled';

  @override
  String get resetToDefaultsMsg => 'Reset to default settings';

  @override
  String get testReminderSent => 'Test reminder sent!';

  @override
  String get testBackgroundNotification => 'Test Background Notification';

  @override
  String get backgroundTestTitle => 'Background Test';

  @override
  String get backgroundTestBody => 'This is a test notification when the app is closed. You can close the app now and wait 30 seconds.';

  @override
  String get backgroundTestScheduled => 'Background notification test scheduled. Close the app and wait 30 seconds.';
}
