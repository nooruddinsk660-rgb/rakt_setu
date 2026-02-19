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

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? city,
    String? phone,
    bool? availabilityStatus,
  }) async {
    try {
      final response = await _client.put(
        '/users/update-profile',
        data: {
          if (name != null) 'name': name,
          if (city != null) 'city': city,
          if (phone != null) 'phone': phone,
          if (availabilityStatus != null)
            'availabilityStatus': availabilityStatus,
        },
      );
      return response.data['user'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _client.get('/users/me');
      return response.data['user'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRoleRequests() async {
    try {
      final response = await _client.get('/users/role-requests');
      return List<Map<String, dynamic>>.from(response.data['requests']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actionRoleRequest(String userId, String status) async {
    try {
      await _client.put(
        '/users/role-requests',
        data: {'userId': userId, 'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }
}
