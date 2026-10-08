import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';
import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';
import 'package:removeit_app/features/history/domain/usecases/bulk_delete_history_items_usecase.dart';
import 'package:removeit_app/features/history/domain/usecases/delete_history_item_usecase.dart';
import 'package:removeit_app/features/history/domain/usecases/sync_history_usecase.dart';
import 'package:removeit_app/features/history/domain/usecases/watch_history_usecase.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_event.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_state.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';

class MockHistoryRepository implements HistoryRepository {
  final StreamController<List<HistoryItemEntity>> _controller =
      StreamController<List<HistoryItemEntity>>.broadcast();

  Either<Failure, Unit>? syncResult;
  Either<Failure, Unit>? deleteResult;
  Either<Failure, Unit>? bulkDeleteResult;

  void emitItems(List<HistoryItemEntity> items) {
    _controller.add(items);
  }

  @override
  Stream<List<HistoryItemEntity>> watchHistory() {
    return _controller.stream;
  }

  @override
  Future<Either<Failure, Unit>> syncHistory() async {
    return syncResult ?? const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteJob(String id) async {
    return deleteResult ?? const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> bulkDeleteJobs(List<String> ids) async {
    return bulkDeleteResult ?? const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> clearAllHistory() async {
    return const Right(unit);
  }

  @override
  Future<void> saveJobToHistory(JobEntity job, {String? originalLocalPath}) async {}

  void dispose() {
    _controller.close();
  }
}

void main() {
  late MockHistoryRepository repository;
  late WatchHistoryUseCase watchHistoryUseCase;
  late SyncHistoryUseCase syncHistoryUseCase;
  late DeleteHistoryItemUseCase deleteHistoryItemUseCase;
  late BulkDeleteHistoryItemsUseCase bulkDeleteHistoryItemsUseCase;
  late HistoryBloc bloc;

  setUp(() {
    repository = MockHistoryRepository();
    watchHistoryUseCase = WatchHistoryUseCase(repository);
    syncHistoryUseCase = SyncHistoryUseCase(repository);
    deleteHistoryItemUseCase = DeleteHistoryItemUseCase(repository);
    bulkDeleteHistoryItemsUseCase = BulkDeleteHistoryItemsUseCase(repository);

    bloc = HistoryBloc(
      watchHistoryUseCase: watchHistoryUseCase,
      syncHistoryUseCase: syncHistoryUseCase,
      deleteHistoryItemUseCase: deleteHistoryItemUseCase,
      bulkDeleteHistoryItemsUseCase: bulkDeleteHistoryItemsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
    repository.dispose();
  });

  test('initial state is HistoryInitialState', () {
    expect(bloc.state, equals(const HistoryInitialState()));
  });

  test('emits HistoryLoadedState when stream emits items', () async {
    final testItems = [
      HistoryItemEntity(
        id: 'job-1',
        previewRemoteUrl: 'https://cdn.removeit.ai/preview_1.png',
        width: 1920,
        height: 1080,
        createdAt: DateTime(2026, 10, 8),
      ),
    ];

    final expectation = expectLater(
      bloc.stream,
      emits(predicate<HistoryState>((state) {
        return state is HistoryLoadedState && state.items.length == 1;
      })),
    );

    repository.emitItems(testItems);
    await expectation;
  });

  test('handles item selection toggles and select all', () async {
    final testItems = [
      HistoryItemEntity(
        id: 'job-1',
        previewRemoteUrl: 'https://cdn.removeit.ai/preview_1.png',
        width: 1920,
        height: 1080,
        createdAt: DateTime(2026, 10, 8),
      ),
      HistoryItemEntity(
        id: 'job-2',
        previewRemoteUrl: 'https://cdn.removeit.ai/preview_2.png',
        width: 1080,
        height: 1080,
        createdAt: DateTime(2026, 10, 8),
      ),
    ];

    repository.emitItems(testItems);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Toggle single item
    bloc.add(const ToggleItemSelectionEvent('job-1'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state, isA<HistoryLoadedState>());
    var loadedState = bloc.state as HistoryLoadedState;
    expect(loadedState.isSelectionMode, isTrue);
    expect(loadedState.selectedIds, contains('job-1'));

    // Select all
    bloc.add(const SelectAllHistoryEvent());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    loadedState = bloc.state as HistoryLoadedState;
    expect(loadedState.selectedCount, equals(2));

    // Clear selection
    bloc.add(const ClearSelectionEvent());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    loadedState = bloc.state as HistoryLoadedState;
    expect(loadedState.isSelectionMode, isFalse);
    expect(loadedState.selectedCount, equals(0));
  });
}
