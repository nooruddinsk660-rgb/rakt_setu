import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class DonorRepository {
  final Dio _client;

  DonorRepository(this._client);

  Future<List<dynamic>> getDonors({Map<String, dynamic>? filters}) async {
    try {
      final response = await _client.get('/donor', queryParameters: filters);
      return response.data['donors']; // Assuming backend returns { donors: [] }
    } catch (e) {
      // Return empty list on 404 or handle error gracefully if needed
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> addDonor(Map<String, dynamic> data) async {
    try {
      await _client.post('/donor', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDonorContact(
    String id,
    String purpose,
  ) async {
    try {
      final response = await _client.post(
        '/donor/$id/contact',
        data: {'purpose': purpose},
      );
      return response.data['contact'];
    } catch (e) {
      rethrow;
    }
  }
}
