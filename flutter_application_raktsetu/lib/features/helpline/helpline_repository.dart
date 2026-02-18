import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class HelplineRepository {
  final Dio _client;

  HelplineRepository(this._client);

  Future<List<dynamic>> getRequests({Map<String, dynamic>? filters}) async {
    try {
      final response = await _client.get('/helpline', queryParameters: filters);
      return response.data['requests'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createRequest(Map<String, dynamic> data) async {
    try {
      await _client.post('/helpline', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(
    String id,
    String status, {
    String? callRemark,
    String? assignedVolunteerId,
  }) async {
    try {
      await _client.put(
        '/helpline/$id/status',
        data: {
          'status': status,
          if (callRemark != null) 'callRemark': callRemark,
          if (assignedVolunteerId != null)
            'assignedVolunteer': assignedVolunteerId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
