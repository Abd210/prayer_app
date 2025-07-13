// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق إسلامي متقدم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get selectColorTheme => 'اختر نسق الألوان';

  @override
  String get customTheme => 'نسق مخصّص';

  @override
  String get enableDarkMode => 'تفعيل الوضع الداكن';

  @override
  String get enableLightMode => 'تفعيل الوضع الفاتح';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get enableDailyHadith => 'تفعيل حديث اليوم';

  @override
  String get highAccuracyCalculation => 'دقة حساب عالية';

  @override
  String get highAccuracySubtitle => 'يشمل الارتفاع لحساب أوقات أكثر دقة';

  @override
  String get frequentLocationUpdates => 'تحديثات متكررة للموقع';

  @override
  String get frequentLocationSubtitle => 'دقة أعلى ولكن استهلاك أكبر للبطارية';

  @override
  String get otherSettings => 'إعدادات أخرى';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get calculationMethodLabel => 'طريقة حساب أوقات الصلاة';

  @override
  String get calculationMethodTitle => 'طريقة حساب أوقات الصلاة';

  @override
  String get asrCalculationTitle => 'حساب صلاة العصر';

  @override
  String get madhab => 'المذهب';

  @override
  String get use24HourFormat => 'استخدام صيغة 24 ساعة';

  @override
  String get use24hFormat => 'استخدام صيغة 24 ساعة';

  @override
  String get timeFormatTitle => 'صيغة الوقت';

  @override
  String get shafiiLabel => 'الشافعي';

  @override
  String get shafiiDescription => 'طول الظل القياسي (رأي أغلب العلماء)';

  @override
  String get hanafiLabel => 'الحنفي';

  @override
  String get hanafiDescription => 'ضعف طول الظل';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get pick => 'اختيار';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get createCustomTheme => 'أنشئ نسقك المخصَّص';

  @override
  String get chooseLightTheme => 'اختر نسقًا فاتحًا';

  @override
  String get currentTheme => 'الحالي:';

  @override
  String get primary => 'أساسي';

  @override
  String get secondary => 'ثانوي';

  @override
  String get background => 'خلفية';

  @override
  String get surface => 'سطح';

  @override
  String nextPrayerLabel(String prayerName) {
    return 'الصلاة التالية: $prayerName';
  }

  @override
  String startsIn(String countdown) {
    return 'يبدأ خلال $countdown';
  }

  @override
  String get returnToToday => 'العودة إلى اليوم';

  @override
  String get testNotification => 'اختبار الإشعار';

  @override
  String get reload => 'إعادة تحميل';

  @override
  String get statisticsTooltip => 'الإحصائيات';

  @override
  String get sunnahTimes => 'أوقات السنن';

  @override
  String get tipOfDay => 'نصيحة اليوم:';

  @override
  String get prayerTimeTitle => 'وقت الصلاة';

  @override
  String prayerNotificationBody(String prayerName, String city) {
    return 'حان وقت صلاة $prayerName في $city';
  }

  @override
  String get locationUnavailable => 'الموقع غير متاح';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get middleNight => 'منتصف الليل';

  @override
  String get lastThirdNight => 'ثلث الليل الأخير';

  @override
  String get tipEstablishPrayer => '\"﴿أَقِمِ الصَّلَاةَ وَآتِ الزَّكَاةَ﴾\"';

  @override
  String get tipBetterThanSleep => '\"«الصلاة خيرٌ من النوم»\"';

  @override
  String get tipCallUponMe => '\"﴿ادْعُونِي أَسْتَجِبْ لَكُمْ﴾\"';

  @override
  String get tipReflectQuran => 'تدبّر القرآن يوميًّا لنموٍّ روحيٍّ أكبر.';

  @override
  String get tipKhushu => 'اسعَ إلى الخشوع في الصلاة.';

  @override
  String get tipSharePrayer => 'شارك مواعيد الصلاة مع أصدقائك.';

  @override
  String get tipSunnah => 'داوم على صلوات السنن لتحصل على مزيد من الأجر.';

  @override
  String get navPrayers => 'الصلوات';

  @override
  String get navAzkar => 'أذكار';

  @override
  String get navQibla => 'قِبلة';

  @override
  String get navQuran => 'القرآن';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get locating => 'جارٍ التحديد…';

  @override
  String get refreshCompass => 'تحديث الموقع والاتجاه';

  @override
  String get headingLabel => 'اتجاه الجهاز';

  @override
  String get qiblaLabel => 'القبلة';

  @override
  String get facingQibla => 'أنت متجه نحو القبلة!';

  @override
  String deltaFromQibla(Object degrees) {
    return 'Δ $degrees° عن القبلة';
  }

  @override
  String get compassWarnInterference => 'قد تقل دقة البوصلة إن وُجدت أجسام معدنية أو مجالات مغناطيسية قريبة.';

  @override
  String get compassWarnNeedle => 'الإبرة البرتقالية تشير إلى اتجاه القبلة.';

  @override
  String get azkarTasbihTitle => 'الأذكار والتسبيح';

  @override
  String get freeTasbih => 'تسبيح حرّ';

  @override
  String get statsTitle => 'إحصاءات الأذكار';

  @override
  String get statsNoData => 'لا توجد إحصاءات بعد.\nأكمِل أي قائمة أذكار ثم عد لاحقًا!';

  @override
  String get tabDaily => 'يومي';

  @override
  String get tabWeekly => 'أسبوعي';

  @override
  String get tabMonthly => 'شهري';

  @override
  String get kpiDays => 'الأيام';

  @override
  String get kpiStreak => 'السلسلة';

  @override
  String get kpiBest => 'الأفضل';

  @override
  String get week => 'الأسبوع';

  @override
  String get weekShort => 'أ';

  @override
  String needMoreData(Object period) {
    return 'تحتاج إلى مزيد من البيانات لرسم اتجاه $period';
  }

  @override
  String percentCompleted(Object percent) {
    return 'اكتمل$percent٪';
  }

  @override
  String get periodDaily => 'يومي';

  @override
  String get periodWeekly => 'أسبوعي';

  @override
  String get periodMonthly => 'شهري';

  @override
  String get tasbihTitle => 'تسبيح متقدم';

  @override
  String get globalTasbih => 'التسبيح العام';

  @override
  String get subCounters => 'عدادات فرعية';

  @override
  String get resetAll => 'إعادة الضبط';

  @override
  String get tasbihHint => 'انقر على المربع الرئيسي للعد العام.\nوانقر أي مربع فرعي للعد المحدد (٣٣ مرة).';

  @override
  String get compactView => 'عرض مضغوط';

  @override
  String get expandedView => 'عرض موسَّع';

  @override
  String get azkarCopy => 'نسخ';

  @override
  String get azkarCopied => 'تم نسخ نص الذكر!';

  @override
  String get tapAnywhere => 'اضغط في أي مكان للعد';

  @override
  String get azkarReminder => '﴿وَلَذِكْرُ اللَّهِ أَكْبَرُ﴾ (العنكبوت ٤٥)';

  @override
  String azkarCompletedTitle(Object title) {
    return 'اكتمل $title!';
  }

  @override
  String get azkarCompletedContent => 'لقد أنهيت جميع الأذكار في هذا القسم.';

  @override
  String get ok => 'حسناً';

  @override
  String get azkarTab => 'أذكار';

  @override
  String get tasbihTab => 'تسبيح';

  @override
  String get customAzkar => 'أذكار مخصصة';

  @override
  String get manageCustomAzkar => 'إدارة الأذكار المخصصة';

  @override
  String get createAndEditCustomAzkar => 'إنشاء وتعديل مجموعات الأذكار الخاصة بك';

  @override
  String get createAzkar => 'إنشاء ذكر جديد';

  @override
  String get editAzkar => 'تعديل الذكر';

  @override
  String get noCustomAzkar => 'ليس لديك أي أذكار مخصصة بعد.\nأنشئ أول ذكر لك!';

  @override
  String get createNewAzkar => 'إنشاء ذكر جديد';

  @override
  String get basicInfo => 'المعلومات الأساسية';

  @override
  String get title => 'العنوان';

  @override
  String get arabicTitle => 'العنوان بالعربية';

  @override
  String get selectColor => 'اختر اللون';

  @override
  String get selectIcon => 'اختر الأيقونة';

  @override
  String get items => 'العناصر';

  @override
  String get addItem => 'إضافة عنصر';

  @override
  String get editItem => 'تعديل العنصر';

  @override
  String get noItemsYet => 'لم تضف أي عناصر بعد.\nانقر على الزر أعلاه لإضافة عنصر جديد.';

  @override
  String deleteConfirmation(Object title) {
    return 'هل أنت متأكد أنك تريد حذف \'$title\'؟';
  }

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get arabicText => 'النص العربي';

  @override
  String get description => 'الوصف';

  @override
  String get repeat => 'التكرار';

  @override
  String get enterArabicText => 'أدخل النص العربي هنا...';

  @override
  String get addItemsFirst => 'الرجاء إضافة عنصر واحد على الأقل أولاً';

  @override
  String get errorSaving => 'خطأ في الحفظ. يرجى المحاولة مرة أخرى.';

  @override
  String get deleteItemConfirmation => 'هل أنت متأكد أنك تريد حذف هذا العنصر؟';

  @override
  String get quranTitle => 'القرآن';

  @override
  String get searchHint => 'ابحث عن آية';

  @override
  String searchNoResults(Object query) {
    return 'لم يتم العثور على آيات لـ \"$query\"';
  }

  @override
  String get searchPrompt => 'اكتب كلمة أو عبارة للبحث في القرآن';

  @override
  String searchSuggestions(Object query) {
    return 'بحث عن آيات تحتوي: $query';
  }

  @override
  String searchResultTitle(Object surah, Object verse) {
    return 'سورة $surah: آية $verse';
  }

  @override
  String juzLabel(Object number) {
    return 'جزء $number';
  }

  @override
  String juzSurahHeader(Object juz) {
    return 'السور في الجزء $juz';
  }

  @override
  String versesLabel(Object count) {
    return '$count آية';
  }

  @override
  String get playEntireSurah => 'تشغيل السورة كاملة';

  @override
  String get prayerTimeAdjustments => 'تعديلات أوقات الصلاة';

  @override
  String get adjustmentMinutes => 'تعديل';

  @override
  String get resetAdjustments => 'إعادة ضبط التعديلات';

  @override
  String get locationSettings => 'إعدادات الموقع';

  @override
  String get manualLocation => 'تحديد الموقع يدويًا';

  @override
  String get adhanSettings => 'إعدادات الأذان';

  @override
  String get enableAdhan => 'تفعيل الأذان';

  @override
  String get adhanVolume => 'مستوى صوت الأذان';

  @override
  String get testAdhan => 'اختبار الأذان';

  @override
  String get autoNext => 'الانتقال التلقائي';

  @override
  String get manualNext => 'الانتقال اليدوي';

  @override
  String get autoDetectMethod => 'اكتشاف تلقائي للطريقة';

  @override
  String get autoDetectMethodSubtitle => 'تحديد طريقة الحساب تلقائياً حسب موقعك';

  @override
  String get manualCalculationMethod => 'طريقة الحساب اليدوية';

  @override
  String get detectMethodNow => 'اكتشاف الطريقة الآن';

  @override
  String get detectingMethod => 'جاري اكتشاف الطريقة...';

  @override
  String get methodUpdatedAuto => 'تم تحديث طريقة الحساب تلقائياً!';

  @override
  String get methodUnchanged => 'لم يتم تغيير طريقة الحساب';

  @override
  String get methodUpdatedForLocation => 'تم تحديث طريقة الحساب تلقائياً لموقعك الجديد';

  @override
  String get azkarReminders => 'تذكير الأذكار';

  @override
  String get enableAzkarReminders => 'تفعيل تذكير الأذكار';

  @override
  String get azkarRemindersEnabled => 'تذكير الأذكار مفعل';

  @override
  String get azkarRemindersDisabled => 'تذكير الأذكار معطل';

  @override
  String get dhuhrAzkarReminder => 'تذكير أذكار الظهر';

  @override
  String get maghribAzkarReminder => 'تذكير أذكار المغرب';

  @override
  String get resetToDefaults => 'إعادة تعيين للافتراضي';

  @override
  String get testReminder => 'اختبار التذكير';

  @override
  String get azkarReminderInfo => 'معلومات تذكير الأذكار';

  @override
  String get azkarReminderInfoText => '• الظهر: تذكير بأذكار الصباح قبل صلاة الظهر\n• المغرب: تذكير بأذكار المساء قبل صلاة المغرب\n• قابل للتخصيص: اضبط الوقت حسب رغبتك\n• يومياً: تتكرر التذكيرات كل يوم';

  @override
  String get azkarRemindersEnabledMsg => 'تم تفعيل تذكير الأذكار';

  @override
  String get azkarRemindersDisabledMsg => 'تم إلغاء تذكير الأذكار';

  @override
  String get resetToDefaultsMsg => 'تم إعادة التعيين للافتراضي';

  @override
  String get testReminderSent => 'تم إرسال تذكير تجريبي!';

  @override
  String get testBackgroundNotification => 'اختبار الإشعار في الخلفية';

  @override
  String get backgroundTestTitle => 'اختبار الإشعار في الخلفية';

  @override
  String get backgroundTestBody => 'هذا اختبار للإشعار عندما يكون التطبيق مغلقاً. يمكنك إغلاق التطبيق الآن والانتظار 30 ثانية.';

  @override
  String get backgroundTestScheduled => 'تم جدولة اختبار الإشعار في الخلفية. أغلق التطبيق وانتظر 30 ثانية.';
}
