import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import 'user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;
  final SharedPreferences prefs;

  AuthRemoteDataSourceImpl({required this.client, required this.prefs});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // 1. Get Token
      final response = await client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await prefs.setString('access_token', token);

        // 2. Get User Details
        // The interceptor will attach the token automatically
        final userResponse = await client.get('/users/me');
        if (userResponse.statusCode == 200) {
          final user = UserModel.fromJson(userResponse.data);
          await prefs.setString('user_role', user.role);
          await prefs.setInt('user_id', user.id);
          return user;
        } else {
          throw const ServerFailure('Failed to fetch user details');
        }
      } else {
        throw const ServerFailure('Login failed');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }
}
