import 'package:equatable/equatable.dart';
import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitialState extends HistoryState {
  const HistoryInitialState();
}

class HistoryLoadingState extends HistoryState {
  const HistoryLoadingState();
}

class HistoryLoadedState extends HistoryState {
  final List<HistoryItemEntity> items;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final bool isSyncing;
  final String? successMessage;
  final String? errorMessage;

  const HistoryLoadedState({
    required this.items,
    this.isSelectionMode = false,
    this.selectedIds = const {},
    this.isSyncing = false,
    this.successMessage,
    this.errorMessage,
  });

  bool get isEmpty => items.isEmpty;
  int get selectedCount => selectedIds.length;
  bool isItemSelected(String id) => selectedIds.contains(id);

  HistoryLoadedState copyWith({
    List<HistoryItemEntity>? items,
    bool? isSelectionMode,
    Set<String>? selectedIds,
    bool? isSyncing,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return HistoryLoadedState(
      items: items ?? this.items,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
      isSyncing: isSyncing ?? this.isSyncing,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        items,
        isSelectionMode,
        selectedIds,
        isSyncing,
        successMessage,
        errorMessage,
      ];
}

class HistoryOperationSuccessState extends HistoryState {
  final String message;

  const HistoryOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class HistoryErrorState extends HistoryState {
  final String message;

  const HistoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
