import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';

final reimbursementRepositoryProvider = Provider<ReimbursementRepository>((
  ref,
) {
  return ReimbursementRepository(ref.watch(apiClientProvider).client);
});

class ReimbursementRepository {
  final Dio _client;

  ReimbursementRepository(this._client);

  Future<List<dynamic>> getMyReimbursements() async {
    try {
      final response = await _client.get('/reimbursements/my');
      return response.data['reimbursements'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getPendingReimbursements() async {
    try {
      final response = await _client.get('/reimbursements/pending');
      return response.data['reimbursements'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> createReimbursement({
    required String eventId,
    required double amount,
    required String receiptUrl,
    required String description,
  }) async {
    try {
      await _client.post(
        '/reimbursements',
        data: {
          'eventId': eventId,
          'amount': amount,
          'receiptUrl': receiptUrl,
          'description': description,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _client.put('/reimbursements/$id/status', data: {'status': status});
    } catch (e) {
      rethrow;
    }
  }
}
