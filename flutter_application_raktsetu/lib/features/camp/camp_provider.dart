import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';
import 'camp_repository.dart';

final campRepositoryProvider = Provider<CampRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CampRepository(apiClient.client);
});

final campsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(campRepositoryProvider);
  return repository.getCamps();
});
