import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _roleKey = 'user_role';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> saveUser(
    String id,
    String name,
    String email, {
    String? city,
    String? phone,
    bool? availabilityStatus,
  }) async {
    await _storage.write(key: 'user_id', value: id);
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_email', value: email);
    if (city != null) await _storage.write(key: 'user_city', value: city);
    if (phone != null) await _storage.write(key: 'user_phone', value: phone);
    if (availabilityStatus != null) {
      await _storage.write(
        key: 'user_availability',
        value: availabilityStatus.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final id = await _storage.read(key: 'user_id');
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email');
    final city = await _storage.read(key: 'user_city');
    final phone = await _storage.read(key: 'user_phone');
    final availability = await _storage.read(key: 'user_availability');
    return {
      'id': id,
      'name': name,
      'email': email,
      'city': city,
      'phone': phone,
      'availabilityStatus': availability == 'true',
    };
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
