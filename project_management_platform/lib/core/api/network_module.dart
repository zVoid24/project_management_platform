import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class CoreModule {
  @lazySingleton
  Dio get dio {
    const envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final resolvedBaseUrl = envBaseUrl.isNotEmpty
        ? envBaseUrl
        : _defaultBaseUrlByPlatform();
    final dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

String _defaultBaseUrlByPlatform() {
  if (kIsWeb) {
    return 'http://localhost:8000/api/v1';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://192.168.0.108:8000/api/v1';
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return 'http://127.0.0.1:8000/api/v1';
    case TargetPlatform.fuchsia:
      return 'http://127.0.0.1:8000/api/v1';
  }
}
