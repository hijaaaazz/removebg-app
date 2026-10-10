import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/services/image_picker_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class ImageSourcePickerSheet extends StatelessWidget {
  final void Function(ImagePickerSource) onSourceSelected;

  const ImageSourcePickerSheet({
    super.key,
    required this.onSourceSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(ImagePickerSource) onSourceSelected,
  }) {
    HapticService.selection();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => ImageSourcePickerSheet(
        onSourceSelected: (source) {
          Navigator.of(sheetContext).pop();
          onSourceSelected(source);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.studioCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.studioBorder, width: 1.2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.studioBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Photo to Cutout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose from gallery or snap with camera for BiRefNet AI cutout.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPickerSourceCard(
                  title: 'Photo Library',
                  subtitle: 'Choose from Gallery',
                  icon: Icons.photo_library_rounded,
                  onTap: () => onSourceSelected(ImagePickerSource.gallery),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPickerSourceCard(
                  title: 'Camera',
                  subtitle: 'Capture New Subject',
                  icon: Icons.camera_alt_rounded,
                  onTap: () => onSourceSelected(ImagePickerSource.camera),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMutedDark, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerSourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.studioCardElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.studioBorder, width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldPrimary.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: AppColors.goldPrimary, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
