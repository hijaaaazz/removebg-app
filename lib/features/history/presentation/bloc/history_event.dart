import 'package:equatable/equatable.dart';
import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class StartWatchHistoryEvent extends HistoryEvent {
  const StartWatchHistoryEvent();
}

class HistoryItemsUpdatedEvent extends HistoryEvent {
  final List<HistoryItemEntity> items;

  const HistoryItemsUpdatedEvent(this.items);

  @override
  List<Object?> get props => [items];
}

class SyncHistoryEvent extends HistoryEvent {
  const SyncHistoryEvent();
}

class ToggleSelectionModeEvent extends HistoryEvent {
  const ToggleSelectionModeEvent();
}

class ToggleItemSelectionEvent extends HistoryEvent {
  final String id;

  const ToggleItemSelectionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectAllHistoryEvent extends HistoryEvent {
  const SelectAllHistoryEvent();
}

class ClearSelectionEvent extends HistoryEvent {
  const ClearSelectionEvent();
}

class DeleteSingleItemEvent extends HistoryEvent {
  final String id;

  const DeleteSingleItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteSelectedItemsEvent extends HistoryEvent {
  const DeleteSelectedItemsEvent();
}
