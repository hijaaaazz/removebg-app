// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'रिमूवइट';

  @override
  String get homeUploadTitle => 'तुरंत बैकग्राउंड हटाएं';

  @override
  String get homeUploadSubtitle =>
      'स्टूडियो जैसी स्पष्टता के साथ फोटो से बैकग्राउंड अलग करें';

  @override
  String get buttonSelectPhoto => 'गैलरी से फोटो चुनें';

  @override
  String get buttonTakePhoto => 'कैमरे से फोटो लें';

  @override
  String get buttonWatchAdBonus => 'वीडियो देखें (+1 बोनस उपयोग)';

  @override
  String get buttonUnlockPro => 'प्रो अनलिमिटेड में अपग्रेड करें';

  @override
  String get canvasCompareTooltip =>
      'मूल फोटो के साथ कटआउट की तुलना करने के लिए स्लाइडर खींचें';

  @override
  String get canvasSaveToGallery => 'गैलरी में सहेजें';

  @override
  String get canvasSavedSuccess => 'कटआउट सफलतापूर्वक सहेजा गया!';

  @override
  String get historyTitle => 'कटआउट इतिहास';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get errorQuotaExhausted =>
      'आज के मुफ्त कट समाप्त हो गए हैं। बोनस अनलॉक करने के लिए वीडियो देखें।';

  @override
  String get errorNetwork =>
      'इंटरनेट कनेक्शन नहीं मिला। कृपया अपना नेटवर्क जांचें।';
}
