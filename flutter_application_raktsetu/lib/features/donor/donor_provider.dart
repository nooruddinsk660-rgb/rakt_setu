import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';
import 'donor_repository.dart';

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DonorRepository(apiClient.client);
});

final donorFilterProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final donorsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(donorRepositoryProvider);
  final filters = ref.watch(donorFilterProvider);
  return repository.getDonors(filters: filters);
});
