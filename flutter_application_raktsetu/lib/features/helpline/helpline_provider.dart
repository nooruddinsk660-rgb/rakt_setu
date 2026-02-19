import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';
import 'helpline_repository.dart';

final helplineRepositoryProvider = Provider<HelplineRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HelplineRepository(apiClient.client);
});

final helplineRequestsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repository = ref.watch(helplineRepositoryProvider);
  return repository.getRequests();
});

final myRequestsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repository = ref.watch(helplineRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repository.getRequests(filters: {'requestedBy': user.id});
});
