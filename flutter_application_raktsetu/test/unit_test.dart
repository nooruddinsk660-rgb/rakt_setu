import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_raktsetu/features/auth/auth_repository.dart';
import 'package:flutter_application_raktsetu/core/storage/secure_storage.dart';

// Mock SecureStorage
class MockSecureStorage extends Fake implements SecureStorage {
  String? _token;
  String? _refreshToken;
  String? _role;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
  }

  @override
  Future<void> saveRole(String role) async {
    _role = role;
  }

  @override
  Future<void> clearAll() async {
    _token = null;
    _refreshToken = null;
    _role = null;
  }
}

// Mock Dio
class MockDio extends Fake implements Dio {
  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    if (path == '/auth/login') {
      final mapData = data as Map<String, dynamic>;
      if (mapData['email'] == 'test@example.com' &&
          mapData['password'] == 'password') {
        return Response(
          requestOptions: RequestOptions(path: path),
          data:
              {
                    'accessToken': 'fake_access_token',
                    'refreshToken': 'fake_refresh_token',
                    'user': {'role': 'donor'},
                  }
                  as T,
          statusCode: 200,
        );
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          response: Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 401,
          ),
        );
      }
    }
    throw UnimplementedError('PATH: $path is not implemented');
  }
}

void main() {
  late AuthRepository authRepository;
  late MockDio mockDio;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockDio = MockDio();
    mockSecureStorage = MockSecureStorage();
    authRepository = AuthRepository(mockDio, mockSecureStorage);
  });

  group('AuthRepository Tests', () {
    test('login success should save tokens', () async {
      await authRepository.login('test@example.com', 'password');

      expect(await mockSecureStorage.getToken(), 'fake_access_token');
    });

    test('login failure should throw DioException', () async {
      expect(
        () => authRepository.login('wrong@example.com', 'password'),
        throwsA(isA<DioException>()),
      );
    });

    test('logout should clear storage', () async {
      await mockSecureStorage.saveToken('token');
      await authRepository.logout();
      expect(await mockSecureStorage.getToken(), null);
    });
  });
}
