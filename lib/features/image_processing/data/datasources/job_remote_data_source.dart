import 'dart:io';
import 'package:dio/dio.dart';
import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/features/image_processing/data/models/job_model.dart';

abstract class JobRemoteDataSource {
  Future<JobModel> uploadImage(
    File file, {
    void Function(int sent, int total)? onProgress,
  });

  Future<JobModel> getJobStatus(String jobId);

  Future<JobModel> claimJob(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiClient apiClient;

  JobRemoteDataSourceImpl(this.apiClient);

  @override
  Future<JobModel> uploadImage(
    File file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.jobs,
      data: formData,
      onSendProgress: onProgress,
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    return JobModel.fromJson(data);
  }

  @override
  Future<JobModel> getJobStatus(String jobId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.jobDetail(jobId),
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    return JobModel.fromJson(data);
  }

  @override
  Future<JobModel> claimJob(String jobId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.jobClaim(jobId),
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    return JobModel.fromJson(data);
  }
}
