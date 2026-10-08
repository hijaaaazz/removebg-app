import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/features/quota/data/models/user_quota_model.dart';

abstract class QuotaRemoteDataSource {
  Future<UserQuotaModel> getUserQuota();
}

class QuotaRemoteDataSourceImpl implements QuotaRemoteDataSource {
  final ApiClient apiClient;

  QuotaRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserQuotaModel> getUserQuota() async {
    final response = await apiClient.get<Map<String, dynamic>>(ApiEndpoints.quota);
    final data = response.data!['data'] as Map<String, dynamic>;
    return UserQuotaModel.fromJson(data);
  }
}
