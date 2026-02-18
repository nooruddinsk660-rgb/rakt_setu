import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';

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

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _client.get('/hr/dashboard');
      return response.data['stats'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getBurnoutRisks() async {
    try {
      final response = await _client.get('/hr/burnout');
      return response.data['highLoadVolunteers'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> toggleLock(String userId) async {
    try {
      // Backend expects PUT /hr/schedule-lock/:userId
      await _client.put('/hr/schedule-lock/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getVolunteers() async {
    try {
      final response = await _client.get('/hr/volunteers');
      return response.data['volunteers'] ?? [];
    } catch (e) {
      return [];
    }
  }
}
