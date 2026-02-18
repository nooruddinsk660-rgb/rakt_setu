import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/auth_provider.dart';
import 'volunteer_repository.dart';

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VolunteerRepository(apiClient.client);
});

final volunteerProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final repo = ref.watch(volunteerRepositoryProvider);
      return repo.getProfile();
    });
