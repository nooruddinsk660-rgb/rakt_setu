import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorage _storage;
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    // For Android Emulator, use 10.0.2.2
    // For iOS Simulator, use localhost
    return 'http://10.0.2.2:5000/api/v1';
  }

  ApiClient(this._storage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token might be expired, try to refresh
            // Note: This is a simplified implementation.
            // Real-world would need a lock to prevent multiple refreshes.
            final refreshToken = await _storage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final response = await _dio.post(
                  '/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                );

                final newToken = response.data['accessToken'];
                await _storage.saveToken(newToken);

                // Retry original request
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';
                final clonedRequest = await _dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                    contentType: opts.contentType,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(clonedRequest);
              } catch (refreshError) {
                // Refresh failed, logout
                await _storage.clearAll();
                return handler.next(e);
              }
            } else {
              await _storage.clearAll();
            }
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  Dio get client => _dio;
}
