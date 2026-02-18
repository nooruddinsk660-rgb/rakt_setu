import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';

final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return OperationsRepository(ref.watch(apiClientProvider).client);
});

class OperationsRepository {
  final Dio _client;

  OperationsRepository(this._client);

  Future<Map<String, dynamic>> getOverview() async {
    try {
      final response = await _client.get('/operations/overview');
      return response.data['overview'] ?? {};
    } catch (e) {
      return {};
    }
  }
}
