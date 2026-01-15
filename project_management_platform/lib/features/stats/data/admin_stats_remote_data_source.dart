import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import 'admin_stats_model.dart';

abstract class AdminStatsRemoteDataSource {
  Future<AdminStatsModel> getAdminStats();
}

@LazySingleton(as: AdminStatsRemoteDataSource)
class AdminStatsRemoteDataSourceImpl implements AdminStatsRemoteDataSource {
  final Dio client;
  AdminStatsRemoteDataSourceImpl(this.client);

  @override
  Future<AdminStatsModel> getAdminStats() async {
    try {
      final response = await client.get('/stats');
      if (response.statusCode == 200) {
        return AdminStatsModel.fromJson(response.data);
      }
      throw const ServerFailure('Failed to fetch admin stats');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }
}
