import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';

final hrRepositoryProvider = Provider<HrRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HrRepository(apiClient.client);
});

class HrRepository {
  final Dio _client;

  HrRepository(this._client);

  Future<void> addTeamMember({
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    try {
      await _client.post(
        '/hr/members',
        data: {'name': name, 'email': email, 'phone': phone, 'role': role},
      );
    } catch (e) {
      rethrow;
    }
  }
}
