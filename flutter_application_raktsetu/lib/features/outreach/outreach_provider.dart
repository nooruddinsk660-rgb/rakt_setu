import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';
import 'outreach_repository.dart';

final outreachRepositoryProvider = Provider<OutreachRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OutreachRepository(apiClient.client);
});

final outreachLeadsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repository = ref.watch(outreachRepositoryProvider);
  return repository.getLeads();
});
