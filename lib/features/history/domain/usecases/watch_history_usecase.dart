import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';
import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';

class WatchHistoryUseCase {
  final HistoryRepository repository;

  WatchHistoryUseCase(this.repository);

  Stream<List<HistoryItemEntity>> call() {
    return repository.watchHistory();
  }
}
