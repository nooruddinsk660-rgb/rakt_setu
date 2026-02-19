import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reimbursement_repository.dart';

final myReimbursementsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repository = ref.read(reimbursementRepositoryProvider);
  return repository.getMyReimbursements();
});

final pendingReimbursementsProvider = FutureProvider.autoDispose<List<dynamic>>(
  (ref) async {
    final repository = ref.read(reimbursementRepositoryProvider);
    return repository.getPendingReimbursements();
  },
);
