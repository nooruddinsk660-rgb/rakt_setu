import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';
import 'outreach_repository.dart';

final outreachRepositoryProvider = Provider<OutreachRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OutreachRepository(apiClient.client);
});

final outreachFilterProvider = StateProvider.autoDispose<Map<String, dynamic>>(
  (ref) => {},
);

final outreachLeadsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repository = ref.watch(outreachRepositoryProvider);
  final filters = ref.watch(outreachFilterProvider);
  // Remove null or empty filters
  final activeFilters = Map<String, dynamic>.from(filters)
    ..removeWhere((k, v) => v == null || v.toString().isEmpty);

  return repository.getLeads(filters: activeFilters);
});
