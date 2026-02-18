import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class CampRepository {
  final Dio _client;

  CampRepository(this._client);

  Future<List<dynamic>> getCamps() async {
    try {
      final response = await _client.get('/camp');
      return response.data['camps'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createCamp(Map<String, dynamic> data) async {
    try {
      await _client.post('/camp', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _client.put('/camp/$id/status', data: {'status': status});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDonationCount(String id, int count) async {
    try {
      await _client.put('/camp/$id/stats', data: {'count': count});
    } catch (e) {
      rethrow;
    }
  }
}
