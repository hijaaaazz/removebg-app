import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/features/image_processing/data/models/job_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<JobModel>> fetchRemoteHistory();
  Future<void> deleteRemoteJob(String id);
  Future<void> bulkDeleteRemoteJobs(List<String> ids);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final ApiClient apiClient;

  HistoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<JobModel>> fetchRemoteHistory() async {
    final response = await apiClient.get<Map<String, dynamic>>(ApiEndpoints.history);
    final data = response.data!['data'] as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => JobModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteRemoteJob(String id) async {
    await apiClient.delete<dynamic>(ApiEndpoints.historyDelete(id));
  }

  @override
  Future<void> bulkDeleteRemoteJobs(List<String> ids) async {
    await apiClient.post<dynamic>(
      ApiEndpoints.historyBulkDelete,
      data: {'ids': ids},
    );
  }
}
