import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorage _storage;
  bool _isRefreshing = false;

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
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print('[ApiClient] 401 Error: ${e.requestOptions.path}');

            // If the path is login or refresh-token, don't try to refresh
            if (e.requestOptions.path.contains('/auth/login') ||
                e.requestOptions.path.contains('/auth/refresh-token')) {
              return handler.next(e);
            }

            try {
              print('[ApiClient] Attempting token refresh...');
              final refreshToken = await _storage.getRefreshToken();

              if (refreshToken == null) {
                print('[ApiClient] No refresh token found. Logging out.');
                await _storage.clearAll();
                return handler.next(e);
              }

              // Create a separate Dio instance for refresh to avoid interceptor loops
              final tokenDio = Dio(BaseOptions(baseUrl: _baseUrl));

              final response = await tokenDio.post(
                '/auth/refresh-token',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['accessToken'];
                print('[ApiClient] Token refresh successful.');

                await _storage.saveToken(newAccessToken);
                // Optionally update refresh token if API returns a new one
                // await _storage.saveRefreshToken(response.data['refreshToken']);

                // Retry original request with new token
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';

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
              }
            } catch (refreshError) {
              print('[ApiClient] Token refresh failed: $refreshError');
              await _storage.clearAll();
              return handler.next(e);
            }
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
  }

  Dio get client => _dio;
}
