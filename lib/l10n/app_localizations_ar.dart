// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ريموف إت';

  @override
  String get homeUploadTitle => 'إزالة الخلفية فورياً';

  @override
  String get homeUploadSubtitle =>
      'اختر أي صورة لعزل العناصر بدقة استوديو فائقة';

  @override
  String get buttonSelectPhoto => 'اختيار صورة من المعرض';

  @override
  String get buttonTakePhoto => 'التقاط صورة بالكاميرا';

  @override
  String get buttonWatchAdBonus => 'مشاهدة إعلان (+1 استخدام إضافي)';

  @override
  String get buttonUnlockPro => 'الترقية إلى برو غير المحدود';

  @override
  String get canvasCompareTooltip =>
      'اسحب شريط التمرير لمقارنة النتيجة بالصورة الأصلية';

  @override
  String get canvasSaveToGallery => 'حفظ في ألبوم الكاميرا';

  @override
  String get canvasSavedSuccess => 'تم حفظ الصورة بنجاح!';

  @override
  String get historyTitle => 'سجل الصور';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get errorQuotaExhausted =>
      'لقد استنفدت المحاولات المجانية اليوم! شاهد إعلاناً للحصول على محاولة إضافية أو اشترك في برو.';

  @override
  String get errorNetwork =>
      'تعذر العثور على اتصال بالإنترنت. يرجى التحقق من الشبكة.';
}
