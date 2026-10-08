import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';

class SaveJobToHistoryUseCase {
  final HistoryRepository repository;

  SaveJobToHistoryUseCase(this.repository);

  Future<void> call(JobEntity job, {String? originalLocalPath}) {
    return repository.saveJobToHistory(job, originalLocalPath: originalLocalPath);
  }
}
