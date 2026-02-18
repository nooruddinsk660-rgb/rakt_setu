import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';
import 'hr_repository.dart';

final hrRepositoryProvider = Provider<HrRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HrRepository(apiClient.client);
});

final hrDashboardStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final repository = ref.watch(hrRepositoryProvider);
      return repository.getDashboardStats();
    });

final hrBurnoutRisksProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repository = ref.watch(hrRepositoryProvider);
  return repository.getBurnoutRisks();
});
