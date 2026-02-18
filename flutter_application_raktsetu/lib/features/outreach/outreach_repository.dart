import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class OutreachRepository {
  final Dio _client;

  OutreachRepository(this._client);

  Future<List<dynamic>> getLeads({Map<String, dynamic>? filters}) async {
    try {
      final response = await _client.get('/outreach', queryParameters: filters);
      return response.data['leads'];
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> createLead(Map<String, dynamic> data) async {
    try {
      await _client.post('/outreach', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _client.put('/outreach/$id/status', data: {'status': status});
    } catch (e) {
      rethrow;
    }
  }
}
