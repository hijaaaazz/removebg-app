import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/features/history/domain/usecases/bulk_delete_history_items_usecase.dart';
import 'package:removeit_app/features/history/domain/usecases/delete_history_item_usecase.dart';
import 'package:removeit_app/features/history/domain/usecases/sync_history_usecase.dart';
import 'package:removeit_app/features/history/domain/usecases/watch_history_usecase.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_event.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final WatchHistoryUseCase watchHistoryUseCase;
  final SyncHistoryUseCase syncHistoryUseCase;
  final DeleteHistoryItemUseCase deleteHistoryItemUseCase;
  final BulkDeleteHistoryItemsUseCase bulkDeleteHistoryItemsUseCase;

  StreamSubscription<dynamic>? _historySubscription;

  HistoryBloc({
    required this.watchHistoryUseCase,
    required this.syncHistoryUseCase,
    required this.deleteHistoryItemUseCase,
    required this.bulkDeleteHistoryItemsUseCase,
  }) : super(const HistoryInitialState()) {
    on<StartWatchHistoryEvent>(_onStartWatchHistory);
    on<HistoryItemsUpdatedEvent>(_onHistoryItemsUpdated);
    on<SyncHistoryEvent>(_onSyncHistory);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<ToggleItemSelectionEvent>(_onToggleItemSelection);
    on<SelectAllHistoryEvent>(_onSelectAllHistory);
    on<ClearSelectionEvent>(_onClearSelection);
    on<DeleteSingleItemEvent>(_onDeleteSingleItem);
    on<DeleteSelectedItemsEvent>(_onDeleteSelectedItems);

    _startListening();
  }

  void _startListening() {
    _historySubscription = watchHistoryUseCase().listen((items) {
      add(HistoryItemsUpdatedEvent(items));
    });
  }

  Future<void> _onStartWatchHistory(
    StartWatchHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    add(const SyncHistoryEvent());
  }

  void _onHistoryItemsUpdated(
    HistoryItemsUpdatedEvent event,
    Emitter<HistoryState> emit,
  ) {
    if (state is HistoryLoadedState) {
      final current = state as HistoryLoadedState;
      // Retain existing selectedIds that are still in the items list
      final validIds = current.selectedIds.where((id) => event.items.any((item) => item.id == id)).toSet();
      emit(current.copyWith(
        items: event.items,
        selectedIds: validIds,
        isSelectionMode: validIds.isNotEmpty && current.isSelectionMode,
      ));
    } else {
      emit(HistoryLoadedState(items: event.items));
    }
  }

  Future<void> _onSyncHistory(
    SyncHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoadedState) {
      emit((state as HistoryLoadedState).copyWith(isSyncing: true));
    }

    final result = await syncHistoryUseCase();

    if (state is HistoryLoadedState) {
      emit((state as HistoryLoadedState).copyWith(isSyncing: false));
    }

    result.fold(
      (failure) {
        // Sync failure message does not break the local list presentation
      },
      (_) {},
    );
  }

  void _onToggleSelectionMode(
    ToggleSelectionModeEvent event,
    Emitter<HistoryState> emit,
  ) {
    if (state is HistoryLoadedState) {
      final current = state as HistoryLoadedState;
      final newMode = !current.isSelectionMode;
      emit(current.copyWith(
        isSelectionMode: newMode,
        selectedIds: newMode ? current.selectedIds : {},
      ));
    }
  }

  void _onToggleItemSelection(
    ToggleItemSelectionEvent event,
    Emitter<HistoryState> emit,
  ) {
    if (state is HistoryLoadedState) {
      final current = state as HistoryLoadedState;
      final updated = Set<String>.from(current.selectedIds);
      if (updated.contains(event.id)) {
        updated.remove(event.id);
      } else {
        updated.add(event.id);
      }

      emit(current.copyWith(
        isSelectionMode: updated.isNotEmpty || current.isSelectionMode,
        selectedIds: updated,
      ));
    }
  }

  void _onSelectAllHistory(
    SelectAllHistoryEvent event,
    Emitter<HistoryState> emit,
  ) {
    if (state is HistoryLoadedState) {
      final current = state as HistoryLoadedState;
      final allIds = current.items.map((item) => item.id).toSet();
      emit(current.copyWith(
        isSelectionMode: true,
        selectedIds: allIds,
      ));
    }
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<HistoryState> emit,
  ) {
    if (state is HistoryLoadedState) {
      final current = state as HistoryLoadedState;
      emit(current.copyWith(
        isSelectionMode: false,
        selectedIds: {},
      ));
    }
  }

  Future<void> _onDeleteSingleItem(
    DeleteSingleItemEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoadedState) {
      final current = state as HistoryLoadedState;
      final remaining = current.items.where((item) => item.id != event.id).toList();
      emit(current.copyWith(
        items: remaining,
        selectedIds: current.selectedIds.where((id) => id != event.id).toSet(),
        clearMessages: true,
      ));

      final result = await deleteHistoryItemUseCase(event.id);
      result.fold(
        (failure) {
          if (state is HistoryLoadedState) {
            emit((state as HistoryLoadedState).copyWith(errorMessage: failure.message));
          }
        },
        (_) {
          if (state is HistoryLoadedState) {
            emit((state as HistoryLoadedState).copyWith(successMessage: 'Cutout deleted.'));
          }
        },
      );
    }
  }

  Future<void> _onDeleteSelectedItems(
    DeleteSelectedItemsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoadedState) {
      final current = state as HistoryLoadedState;
      final idsToDelete = current.selectedIds.toList();
      if (idsToDelete.isEmpty) return;

      // Optimistically remove only the selected items from the list
      final remainingItems = current.items.where((item) => !current.selectedIds.contains(item.id)).toList();
      emit(current.copyWith(
        items: remainingItems,
        isSelectionMode: false,
        selectedIds: {},
        clearMessages: true,
      ));

      final result = await bulkDeleteHistoryItemsUseCase(idsToDelete);
      result.fold(
        (failure) {
          if (state is HistoryLoadedState) {
            emit((state as HistoryLoadedState).copyWith(errorMessage: failure.message));
          }
        },
        (_) {
          if (state is HistoryLoadedState) {
            emit((state as HistoryLoadedState).copyWith(
              successMessage: '${idsToDelete.length} ${idsToDelete.length == 1 ? "cutout" : "cutouts"} deleted.',
            ));
          }
        },
      );
    }
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}
