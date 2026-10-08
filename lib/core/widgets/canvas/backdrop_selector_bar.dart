import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/features/studio_canvas/presentation/bloc/studio_canvas_cubit.dart';

class BackdropSelectorBar extends StatelessWidget {
  final StudioCanvasState currentState;
  final VoidCallback onSelectTransparent;
  final void Function(Color color) onSelectColor;
  final void Function(LinearGradient gradient) onSelectGradient;
  final VoidCallback onSelectBlur;
  final void Function(File photo) onSelectCustomPhoto;

  const BackdropSelectorBar({
    super.key,
    required this.currentState,
    required this.onSelectTransparent,
    required this.onSelectColor,
    required this.onSelectGradient,
    required this.onSelectBlur,
    required this.onSelectCustomPhoto,
  });

  static const List<Color> _solidPresets = [
    Colors.white,
    Colors.black,
    Color(0xFFF8FAFC), // Off-white e-commerce
    Color(0xFFBFDBFE), // Soft pastel blue
    Color(0xFFA7F3D0), // Cyber mint
    Color(0xFFFED7AA), // Peach studio
    Color(0xFFF43F5E), // Rose red
  ];

  static const List<LinearGradient> _gradientPresets = [
    LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  Future<void> _pickCustomPhoto() async {
    HapticService.light();
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      onSelectCustomPhoto(File(xFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 1. Transparent Checkerboard
          _buildItemWrapper(
            isSelected: currentState.mode == BackdropMode.transparent,
            onTap: onSelectTransparent,
            label: 'Alpha',
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.grid_4x4_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Blur Mode
          _buildItemWrapper(
            isSelected: currentState.mode == BackdropMode.blur,
            onTap: onSelectBlur,
            label: 'Blur',
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.blur_on_rounded, color: AppColors.accentCyan, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 3. Custom Photo Picker
          _buildItemWrapper(
            isSelected: currentState.mode == BackdropMode.customPhoto,
            onTap: _pickCustomPhoto,
            label: 'Photo',
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryVioletLight, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Vertical divider
          Container(width: 1, height: 36, color: AppColors.surfaceBorder),
          const SizedBox(width: 16),

          // 4. Solid Colors
          ..._solidPresets.map((color) {
            final isSelected = currentState.mode == BackdropMode.solid &&
                currentState.solidColor == color;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildItemWrapper(
                isSelected: isSelected,
                onTap: () => onSelectColor(color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accentCyan : Colors.white24,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                ),
              ),
            );
          }),

          // 5. Gradients
          ..._gradientPresets.map((gradient) {
            final isSelected = currentState.mode == BackdropMode.gradient &&
                currentState.gradient == gradient;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildItemWrapper(
                isSelected: isSelected,
                onTap: () => onSelectGradient(gradient),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accentCyan : Colors.white24,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemWrapper({
    required bool isSelected,
    required VoidCallback onTap,
    String? label,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentCyan.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: child,
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
