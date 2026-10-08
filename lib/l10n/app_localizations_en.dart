// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RemoveIt';

  @override
  String get homeUploadTitle => 'Remove Background Instantly';

  @override
  String get homeUploadSubtitle =>
      'Select any photo to isolate subjects with studio-grade precision';

  @override
  String get buttonSelectPhoto => 'Select Photo from Gallery';

  @override
  String get buttonTakePhoto => 'Take Photo with Camera';

  @override
  String get buttonWatchAdBonus => 'Watch Video (+1 Bonus Use)';

  @override
  String get buttonUnlockPro => 'Upgrade to Pro Unlimited';

  @override
  String get canvasCompareTooltip =>
      'Drag slider to compare cutout with original photo';

  @override
  String get canvasSaveToGallery => 'Save to Camera Roll';

  @override
  String get canvasSavedSuccess => 'Cutout saved successfully!';

  @override
  String get historyTitle => 'Cutout History';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get errorQuotaExhausted =>
      'You\'ve used today\'s free removals! Watch a quick video to unlock a bonus or switch to Pro.';

  @override
  String get errorNetwork =>
      'No internet connection detected. Please check your network.';
}
