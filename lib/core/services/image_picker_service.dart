import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum ImagePickerSource { camera, gallery }

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImagePickerSource source) async {
    final xFile = await _picker.pickImage(
      source: source == ImagePickerSource.camera ? ImageSource.camera : ImageSource.gallery,
    );

    if (xFile == null) return null;
    return File(xFile.path);
  }
}
