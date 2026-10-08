import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class GallerySaverService {
  /// Saves a pre-existing image file to the Camera Roll
  static Future<bool> saveFileToGallery(String filePath) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }
      await Gal.putImage(filePath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Renders subject over solid color or backdrop image and saves to Camera Roll
  static Future<bool> saveCompositeToGallery({
    required ui.Image subjectImage,
    Color? solidColor,
    ui.Image? backdropImage,
  }) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, subjectImage.width.toDouble(), subjectImage.height.toDouble()),
      );
      final size = Size(subjectImage.width.toDouble(), subjectImage.height.toDouble());

      // 1. Draw backdrop if specified
      if (solidColor != null) {
        canvas.drawRect(Offset.zero & size, Paint()..color = solidColor);
      } else if (backdropImage != null) {
        paintImage(
          canvas: canvas,
          rect: Offset.zero & size,
          image: backdropImage,
          fit: BoxFit.cover,
        );
      }

      // 2. Draw cutout subject on top
      canvas.drawImage(subjectImage, Offset.zero, Paint());

      final picture = recorder.endRecording();
      final composite = await picture.toImage(subjectImage.width, subjectImage.height);
      final byteData = await composite.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cutout_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Gal.putImage(file.path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
