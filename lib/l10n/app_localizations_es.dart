// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'RemoveIt';

  @override
  String get homeUploadTitle => 'Eliminar Fondo al Instante';

  @override
  String get homeUploadSubtitle =>
      'Selecciona cualquier foto para recortar objetos con precisión de estudio';

  @override
  String get buttonSelectPhoto => 'Elegir Foto de la Galería';

  @override
  String get buttonTakePhoto => 'Tomar Foto con Cámara';

  @override
  String get buttonWatchAdBonus => 'Ver Video (+1 Corte Gratis)';

  @override
  String get buttonUnlockPro => 'Actualizar a Pro Ilimitado';

  @override
  String get canvasCompareTooltip =>
      'Desliza para comparar el recorte con la foto original';

  @override
  String get canvasSaveToGallery => 'Guardar en Fotos';

  @override
  String get canvasSavedSuccess => '¡Recorte guardado con éxito!';

  @override
  String get historyTitle => 'Historial de Recortes';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get errorQuotaExhausted =>
      'Has agotado los recortes gratis de hoy. Mira un video para desbloquear un bono.';

  @override
  String get errorNetwork =>
      'No se detectó conexión a internet. Por favor verifica tu red.';
}
