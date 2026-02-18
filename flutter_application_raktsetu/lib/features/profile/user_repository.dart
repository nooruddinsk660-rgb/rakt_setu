import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider).client);
});

class UserRepository {
  final Dio _client;

  UserRepository(this._client);

  Future<void> requestRole(String role) async {
    try {
      await _client.post('/users/request-role', data: {'requestedRole': role});
    } catch (e) {
      rethrow;
    }
  }
}
