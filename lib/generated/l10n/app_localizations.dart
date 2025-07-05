import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Islamic App'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @selectColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Select App Color Theme'**
  String get selectColorTheme;

  /// No description provided for @customTheme.
  ///
  /// In en, this message translates to:
  /// **'Custom Theme'**
  String get customTheme;

  /// Switch to dark theme
  ///
  /// In en, this message translates to:
  /// **'Enable Dark Mode'**
  String get enableDarkMode;

  /// No description provided for @enableLightMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Light Mode'**
  String get enableLightMode;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @enableDailyHadith.
  ///
  /// In en, this message translates to:
  /// **'Enable Daily Hadith'**
  String get enableDailyHadith;

  /// No description provided for @highAccuracyCalculation.
  ///
  /// In en, this message translates to:
  /// **'High Accuracy Calculation'**
  String get highAccuracyCalculation;

  /// No description provided for @highAccuracySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes elevation for more precise times'**
  String get highAccuracySubtitle;

  /// No description provided for @frequentLocationUpdates.
  ///
  /// In en, this message translates to:
  /// **'Frequent Location Updates'**
  String get frequentLocationUpdates;

  /// No description provided for @frequentLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Higher accuracy but more battery usage'**
  String get frequentLocationSubtitle;

  /// No description provided for @otherSettings.
  ///
  /// In en, this message translates to:
  /// **'Other Settings'**
  String get otherSettings;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @calculationMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Prayer Calculation Method'**
  String get calculationMethodLabel;

  /// No description provided for @calculationMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Calculation Method'**
  String get calculationMethodTitle;

  /// No description provided for @asrCalculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Asr Prayer Calculation'**
  String get asrCalculationTitle;

  /// No description provided for @madhab.
  ///
  /// In en, this message translates to:
  /// **'Madhab'**
  String get madhab;

  /// No description provided for @use24HourFormat.
  ///
  /// In en, this message translates to:
  /// **'Use 24‑hour Format'**
  String get use24HourFormat;

  /// No description provided for @use24hFormat.
  ///
  /// In en, this message translates to:
  /// **'Use 24‑hour Format'**
  String get use24hFormat;

  /// No description provided for @timeFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get timeFormatTitle;

  /// No description provided for @shafiiLabel.
  ///
  /// In en, this message translates to:
  /// **'Shafii'**
  String get shafiiLabel;

  /// No description provided for @shafiiDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard shadow length (majority of scholars)'**
  String get shafiiDescription;

  /// No description provided for @hanafiLabel.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get hanafiLabel;

  /// No description provided for @hanafiDescription.
  ///
  /// In en, this message translates to:
  /// **'Double shadow length'**
  String get hanafiDescription;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @pick.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @createCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Create Your Own Theme'**
  String get createCustomTheme;

  /// No description provided for @chooseLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose a Light Theme'**
  String get chooseLightTheme;

  /// No description provided for @currentTheme.
  ///
  /// In en, this message translates to:
  /// **'Current:'**
  String get currentTheme;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @surface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surface;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer: {prayerName}'**
  String nextPrayerLabel(String prayerName);

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'Starts in {countdown}'**
  String startsIn(String countdown);

  /// No description provided for @returnToToday.
  ///
  /// In en, this message translates to:
  /// **'Return to Today'**
  String get returnToToday;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @statisticsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTooltip;

  /// No description provided for @sunnahTimes.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Times'**
  String get sunnahTimes;

  /// No description provided for @tipOfDay.
  ///
  /// In en, this message translates to:
  /// **'Tip of the Day:'**
  String get tipOfDay;

  /// No description provided for @prayerTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time'**
  String get prayerTimeTitle;

  /// No description provided for @prayerNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for {prayerName} prayer in {city}'**
  String prayerNotificationBody(String prayerName, String city);

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @middleNight.
  ///
  /// In en, this message translates to:
  /// **'Middle of Night'**
  String get middleNight;

  /// No description provided for @lastThirdNight.
  ///
  /// In en, this message translates to:
  /// **'Last Third of Night'**
  String get lastThirdNight;

  /// No description provided for @tipEstablishPrayer.
  ///
  /// In en, this message translates to:
  /// **'\"Establish prayer and give charity.\"'**
  String get tipEstablishPrayer;

  /// No description provided for @tipBetterThanSleep.
  ///
  /// In en, this message translates to:
  /// **'\"Prayer is better than sleep.\"'**
  String get tipBetterThanSleep;

  /// No description provided for @tipCallUponMe.
  ///
  /// In en, this message translates to:
  /// **'\"Call upon Me, I will respond.\"'**
  String get tipCallUponMe;

  /// No description provided for @tipReflectQuran.
  ///
  /// In en, this message translates to:
  /// **'Reflect upon the Quran daily for spiritual growth.'**
  String get tipReflectQuran;

  /// No description provided for @tipKhushu.
  ///
  /// In en, this message translates to:
  /// **'Strive for khushū` (humility) in prayer.'**
  String get tipKhushu;

  /// No description provided for @tipSharePrayer.
  ///
  /// In en, this message translates to:
  /// **'Share your knowledge of prayer times with friends.'**
  String get tipSharePrayer;

  /// No description provided for @tipSunnah.
  ///
  /// In en, this message translates to:
  /// **'Keep consistent with Sunnah prayers for extra reward.'**
  String get tipSunnah;

  /// No description provided for @navPrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get navPrayers;

  /// No description provided for @navAzkar.
  ///
  /// In en, this message translates to:
  /// **'Azkār'**
  String get navAzkar;

  /// No description provided for @navQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @navQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get navQuran;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get locating;

  /// No description provided for @refreshCompass.
  ///
  /// In en, this message translates to:
  /// **'Refresh location & heading'**
  String get refreshCompass;

  /// No description provided for @headingLabel.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get headingLabel;

  /// No description provided for @qiblaLabel.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaLabel;

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla!'**
  String get facingQibla;

  /// No description provided for @deltaFromQibla.
  ///
  /// In en, this message translates to:
  /// **'Δ {degrees}° from Qibla'**
  String deltaFromQibla(Object degrees);

  /// No description provided for @compassWarnInterference.
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy may drop if you\'re near magnetic fields or metal objects.'**
  String get compassWarnInterference;

  /// No description provided for @compassWarnNeedle.
  ///
  /// In en, this message translates to:
  /// **'The orange needle points toward the Qibla direction.'**
  String get compassWarnNeedle;

  /// No description provided for @azkarTasbihTitle.
  ///
  /// In en, this message translates to:
  /// **'Azkar & Tasbih'**
  String get azkarTasbihTitle;

  /// No description provided for @freeTasbih.
  ///
  /// In en, this message translates to:
  /// **'Free Tasbih'**
  String get freeTasbih;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Azkar Statistics'**
  String get statsTitle;

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'No statistics yet.\nFinish any Azkar list and come back!'**
  String get statsNoData;

  /// No description provided for @tabDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get tabDaily;

  /// No description provided for @tabWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get tabWeekly;

  /// No description provided for @tabMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get tabMonthly;

  /// No description provided for @kpiDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get kpiDays;

  /// No description provided for @kpiStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get kpiStreak;

  /// No description provided for @kpiBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get kpiBest;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @weekShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekShort;

  /// No description provided for @needMoreData.
  ///
  /// In en, this message translates to:
  /// **'Need more data to draw a {period} trend'**
  String needMoreData(Object period);

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent} % completed'**
  String percentCompleted(Object percent);

  /// No description provided for @periodDaily.
  ///
  /// In en, this message translates to:
  /// **'daily'**
  String get periodDaily;

  /// No description provided for @periodWeekly.
  ///
  /// In en, this message translates to:
  /// **'weekly'**
  String get periodWeekly;

  /// No description provided for @periodMonthly.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get periodMonthly;

  /// No description provided for @tasbihTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Advanced'**
  String get tasbihTitle;

  /// No description provided for @globalTasbih.
  ///
  /// In en, this message translates to:
  /// **'Global Tasbih'**
  String get globalTasbih;

  /// No description provided for @subCounters.
  ///
  /// In en, this message translates to:
  /// **'Sub‑Counters'**
  String get subCounters;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @tasbihHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the main box for a global count.\nTap any sub box for specific counts (33 each).'**
  String get tasbihHint;

  /// No description provided for @compactView.
  ///
  /// In en, this message translates to:
  /// **'Compact View'**
  String get compactView;

  /// No description provided for @expandedView.
  ///
  /// In en, this message translates to:
  /// **'Expanded View'**
  String get expandedView;

  /// No description provided for @azkarCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get azkarCopy;

  /// No description provided for @azkarCopied.
  ///
  /// In en, this message translates to:
  /// **'Azkar text copied to clipboard!'**
  String get azkarCopied;

  /// No description provided for @tapAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Tap Anywhere to Count'**
  String get tapAnywhere;

  /// No description provided for @azkarReminder.
  ///
  /// In en, this message translates to:
  /// **'Remembrance of Allah is the greatest (Qur\'an 29:45).'**
  String get azkarReminder;

  /// No description provided for @azkarCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} Completed!'**
  String azkarCompletedTitle(Object title);

  /// No description provided for @azkarCompletedContent.
  ///
  /// In en, this message translates to:
  /// **'You have finished all azkār in this category.'**
  String get azkarCompletedContent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @azkarTab.
  ///
  /// In en, this message translates to:
  /// **'Azkar'**
  String get azkarTab;

  /// No description provided for @tasbihTab.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbihTab;

  /// No description provided for @customAzkar.
  ///
  /// In en, this message translates to:
  /// **'Custom Azkar'**
  String get customAzkar;

  /// No description provided for @manageCustomAzkar.
  ///
  /// In en, this message translates to:
  /// **'Manage Custom Azkar'**
  String get manageCustomAzkar;

  /// No description provided for @createAndEditCustomAzkar.
  ///
  /// In en, this message translates to:
  /// **'Create and edit your own azkar collections'**
  String get createAndEditCustomAzkar;

  /// No description provided for @createAzkar.
  ///
  /// In en, this message translates to:
  /// **'Create Azkar'**
  String get createAzkar;

  /// No description provided for @editAzkar.
  ///
  /// In en, this message translates to:
  /// **'Edit Azkar'**
  String get editAzkar;

  /// No description provided for @noCustomAzkar.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any custom azkar yet.\nCreate your first one!'**
  String get noCustomAzkar;

  /// No description provided for @createNewAzkar.
  ///
  /// In en, this message translates to:
  /// **'Create New Azkar'**
  String get createNewAzkar;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @arabicTitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic Title'**
  String get arabicTitle;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any items yet.\nClick the button above to add a new one.'**
  String get noItemsYet;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{title}\'?'**
  String deleteConfirmation(Object title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @arabicText.
  ///
  /// In en, this message translates to:
  /// **'Arabic Text'**
  String get arabicText;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @enterArabicText.
  ///
  /// In en, this message translates to:
  /// **'Enter Arabic text here...'**
  String get enterArabicText;

  /// No description provided for @addItemsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item first'**
  String get addItemsFirst;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving. Please try again.'**
  String get errorSaving;

  /// No description provided for @deleteItemConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemConfirmation;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a verse'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No verses found for \'{query}\''**
  String searchNoResults(Object query);

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a word or phrase to search in the Quran'**
  String get searchPrompt;

  /// No description provided for @searchSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Search verses containing: {query}'**
  String searchSuggestions(Object query);

  /// No description provided for @searchResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Surah {surah}: Verse {verse}'**
  String searchResultTitle(Object surah, Object verse);

  /// No description provided for @juzLabel.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzLabel(Object number);

  /// No description provided for @juzSurahHeader.
  ///
  /// In en, this message translates to:
  /// **'Surahs in Juz {juz}'**
  String juzSurahHeader(Object juz);

  /// No description provided for @versesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Verses'**
  String versesLabel(Object count);

  /// No description provided for @playEntireSurah.
  ///
  /// In en, this message translates to:
  /// **'Play Entire Surah'**
  String get playEntireSurah;

  /// No description provided for @prayerTimeAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Adjustments'**
  String get prayerTimeAdjustments;

  /// No description provided for @adjustmentMinutes.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustmentMinutes;

  /// No description provided for @resetAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Reset Adjustments'**
  String get resetAdjustments;

  /// No description provided for @locationSettings.
  ///
  /// In en, this message translates to:
  /// **'Location Settings'**
  String get locationSettings;

  /// No description provided for @manualLocation.
  ///
  /// In en, this message translates to:
  /// **'Manual Location'**
  String get manualLocation;

  /// No description provided for @adhanSettings.
  ///
  /// In en, this message translates to:
  /// **'Adhan Settings'**
  String get adhanSettings;

  /// No description provided for @enableAdhan.
  ///
  /// In en, this message translates to:
  /// **'Enable Adhan'**
  String get enableAdhan;

  /// No description provided for @adhanVolume.
  ///
  /// In en, this message translates to:
  /// **'Adhan Volume'**
  String get adhanVolume;

  /// No description provided for @testAdhan.
  ///
  /// In en, this message translates to:
  /// **'Test Adhan'**
  String get testAdhan;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
