import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:removeit_app/core/constants/app_constants.dart';

class PreprocessInput {
  final String sourcePath;
  final int maxDimension;
  final int quality;

  const PreprocessInput({
    required this.sourcePath,
    this.maxDimension = AppConstants.maxImageDimension,
    this.quality = AppConstants.imageJpegQuality,
  });
}

class ImagePreprocessor {
  /// Offloads image rotation, resizing, and EXIF sanitization to a background worker isolate
  static Future<File> prepareForUpload(
    File originalFile, {
    int maxDimension = AppConstants.maxImageDimension,
    int quality = AppConstants.imageJpegQuality,
  }) async {
    final input = PreprocessInput(
      sourcePath: originalFile.path,
      maxDimension: maxDimension,
      quality: quality,
    );

    final optimizedPath = await compute(_processImageIsolate, input);
    return File(optimizedPath);
  }

  static String _processImageIsolate(PreprocessInput input) {
    final bytes = File(input.sourcePath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }

    // 1. Auto-rotate based on EXIF orientation tag
    final oriented = img.bakeOrientation(decoded);

    // 2. Downscale if dimensions exceed max allowable size
    img.Image resized = oriented;
    if (oriented.width > input.maxDimension || oriented.height > input.maxDimension) {
      if (oriented.width >= oriented.height) {
        resized = img.copyResize(oriented, width: input.maxDimension);
      } else {
        resized = img.copyResize(oriented, height: input.maxDimension);
      }
    }

    // 3. Encode to optimized JPEG (strips GPS and sensitive EXIF tags automatically)
    final outBytes = img.encodeJpg(resized, quality: input.quality);
    final outputPath = '${input.sourcePath}_optimized.jpg';
    final outFile = File(outputPath);
    outFile.writeAsBytesSync(outBytes);

    return outputPath;
  }
}
