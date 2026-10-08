import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareImage(String filePath, {String? text}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: text ?? 'Cutout created with RemoveIt Studio AI',
    );
  }
}
