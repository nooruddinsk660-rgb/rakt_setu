import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';

class AuthRepository {
  final Dio _client;
  final SecureStorage _storage;

  AuthRepository(this._client, this._storage);

  Future<void> login(String email, String password) async {
    try {
      final response = await _client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];
      final user = response.data['user'];
      final role = user['role'];

      await _storage.saveToken(accessToken);
      await _storage.saveRefreshToken(refreshToken);
      await _storage.saveRole(role);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
    String phone,
    String city,
    String bloodGroup,
  ) async {
    try {
      await _client.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
          'city': city,
          'bloodGroup': bloodGroup,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _client.post('/auth/forgot-password', data: {'email': email});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    // Optionally call logout endpoint
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }
}
