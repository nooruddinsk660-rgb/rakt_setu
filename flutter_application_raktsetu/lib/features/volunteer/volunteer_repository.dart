import 'package:dio/dio.dart';

class VolunteerRepository {
  final Dio _client;

  VolunteerRepository(this._client);

  Future<Map<String, dynamic>> onboarding({required String bloodGroup}) async {
    try {
      final response = await _client.post(
        '/volunteer/onboard',
        data: {'bloodGroup': bloodGroup},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _client.get('/volunteer/profile');
      return response.data['profile'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus({bool? availabilityStatus, String? status}) async {
    try {
      await _client.put(
        '/volunteer/status',
        data: {
          if (availabilityStatus != null)
            'availabilityStatus': availabilityStatus,
          if (status != null) 'status': status,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
