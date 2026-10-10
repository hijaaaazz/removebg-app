import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/canvas/checkerboard_background.dart';
import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_state.dart';

class SettingsHistorySection extends StatelessWidget {
  const SettingsHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        final items = state is HistoryLoadedState ? state.items : <HistoryItemEntity>[];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryViolet.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.history_rounded, size: 18, color: AppColors.primaryVioletLight),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          items.isEmpty ? 'Saved Studio Cutouts' : '${items.length} Saved Cutouts',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        HapticService.selection();
                        context.push(RouteNames.history);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.accentCyan,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accentCyan),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty) ...[
                SizedBox(
                  height: 124,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length > 8 ? 8 : items.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final displayUrl = item.effectiveImageUrl;

                      return GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          context.push('${RouteNames.canvas}?jobId=${item.id}');
                        },
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.surfaceBorder, width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              const CheckerboardBackground(squareSize: 8),
                              if (displayUrl.isNotEmpty)
                                CachedNetworkImage(
                                  imageUrl: displayUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentCyan),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(Icons.broken_image_rounded, size: 24, color: AppColors.textMutedDark),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  color: Colors.black.withValues(alpha: 0.65),
                                  child: const Text(
                                    'Open Canvas',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceBorder.withValues(alpha: 0.6), width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 32,
                          color: AppColors.textMutedDark.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No Studio Cutouts Yet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Isolate subjects in the Studio to view and re-export your cutout history here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
