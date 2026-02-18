import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class DashboardRepository {
  final Dio _client;

  DashboardRepository(this._client);

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _client.get('/analytics');
      return response.data['analytics'];
    } catch (e) {
      rethrow;
    }
  }
}
