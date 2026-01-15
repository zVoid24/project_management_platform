import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../auth/data/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getDevelopers();
}

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio client;
  UserRemoteDataSourceImpl(this.client);

  @override
  Future<List<UserModel>> getDevelopers() async {
    try {
      final response = await client.get('/users/developers');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
      } else {
        throw const ServerFailure('Failed to fetch developers');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }
}
