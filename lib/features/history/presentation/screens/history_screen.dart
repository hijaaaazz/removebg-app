import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/canvas/checkerboard_background.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_event.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_state.dart';
import 'package:removeit_app/injection_container.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryBloc>()..add(const StartWatchHistoryEvent()),
      child: const _HistoryScreenContent(),
    );
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistoryBloc, HistoryState>(
      listener: (context, state) {
        if (state is HistoryLoadedState) {
          if (state.successMessage != null) {
            HapticService.successPattern();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primaryViolet,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Text(state.successMessage!),
              ),
            );
          } else if (state.errorMessage != null) {
            HapticService.warningPattern();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.errorRose,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Text(state.errorMessage!),
              ),
            );
          }
        } else if (state is HistoryOperationSuccessState) {
          HapticService.successPattern();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryViolet,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(state.message),
            ),
          );
        } else if (state is HistoryErrorState) {
          HapticService.warningPattern();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.errorRose,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSelectionMode = state is HistoryLoadedState && state.isSelectionMode;
        final selectedCount = state is HistoryLoadedState ? state.selectedCount : 0;
        final hasItems = state is HistoryLoadedState && state.items.isNotEmpty;

        return StudioScaffold(
          appBar: AppBar(
            backgroundColor: AppColors.backgroundDark,
            elevation: 0,
            leading: isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () {
                      HapticService.selection();
                      context.read<HistoryBloc>().add(const ClearSelectionEvent());
                    },
                  )
                : null,
            title: Text(
              isSelectionMode ? '$selectedCount Selected' : 'Cutout History',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              if (!isSelectionMode && hasItems) ...[
                IconButton(
                  icon: const Icon(Icons.sync_rounded, color: AppColors.textSecondaryDark),
                  tooltip: 'Sync with Cloud',
                  onPressed: () {
                    HapticService.light();
                    context.read<HistoryBloc>().add(const SyncHistoryEvent());
                  },
                ),
                TextButton(
                  onPressed: () {
                    HapticService.selection();
                    context.read<HistoryBloc>().add(const ToggleSelectionModeEvent());
                  },
                  child: const Text('Select', style: TextStyle(color: AppColors.accentCyan)),
                ),
              ],
              if (isSelectionMode) ...[
                TextButton(
                  onPressed: () {
                    HapticService.selection();
                    context.read<HistoryBloc>().add(const SelectAllHistoryEvent());
                  },
                  child: const Text('Select All', style: TextStyle(color: AppColors.accentCyan)),
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              if (state is HistoryLoadingState)
                const Center(child: CircularProgressIndicator(color: AppColors.primaryViolet))
              else if (state is HistoryLoadedState && state.isEmpty)
                _buildEmptyState(context)
              else if (state is HistoryLoadedState)
                _buildGrid(context, state)
              else
                _buildEmptyState(context),

              // Bottom multi-select action bar
              if (isSelectionMode && selectedCount > 0)
                _buildBottomActionBar(context, selectedCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryViolet.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.primaryViolet.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.auto_fix_normal_rounded,
                size: 48,
                color: AppColors.primaryVioletLight,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Cutouts Saved Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your transparent PNG cutouts and studio edits will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            GlowButton(
              label: 'Start Your First Cut',
              icon: Icons.add_photo_alternate_rounded,
              onPressed: () => context.go(RouteNames.home),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, HistoryLoadedState state) {
    return RefreshIndicator(
      color: AppColors.primaryViolet,
      backgroundColor: AppColors.surfaceDark,
      onRefresh: () async {
        context.read<HistoryBloc>().add(const SyncHistoryEvent());
      },
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, state.isSelectionMode ? 96 : 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          final isSelected = state.isItemSelected(item.id);

          return _HistoryGridCard(
            item: item,
            isSelectionMode: state.isSelectionMode,
            isSelected: isSelected,
            onTap: () {
              if (state.isSelectionMode) {
                HapticService.selection();
                context.read<HistoryBloc>().add(ToggleItemSelectionEvent(item.id));
              } else {
                HapticService.light();
                context.push('${RouteNames.canvas}?jobId=${item.id}');
              }
            },
            onLongPress: () {
              HapticService.selection();
              context.read<HistoryBloc>().add(ToggleItemSelectionEvent(item.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, int count) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryViolet.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              '$count items',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                HapticService.warningPattern();
                _confirmDeleteSelected(context, count);
              },
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRose, size: 20),
              label: const Text(
                'Delete',
                style: TextStyle(color: AppColors.errorRose, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context, int count) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Cutouts', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete $count cutouts? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMutedDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRose,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<HistoryBloc>().add(const DeleteSelectedItemsEvent());
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HistoryGridCard extends StatelessWidget {
  final HistoryItemEntity item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HistoryGridCard({
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryVioletLight
                : AppColors.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Transparency checkerboard
            const CheckerboardBackground(),

            // Thumbnail Image
            CachedNetworkImage(
              imageUrl: item.effectiveImageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryViolet,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image_rounded, color: AppColors.textMutedDark),
              ),
            ),

            // Selection checkbox pill
            if (isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaryViolet : AppColors.backgroundDark.withValues(alpha: 0.6),
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.surfaceBorder,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

            // Footer gradient metadata
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  '${item.width} × ${item.height}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
