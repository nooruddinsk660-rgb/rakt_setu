import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'operations_repository.dart';

final operationsOverviewProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final repository = ref.read(operationsRepositoryProvider);
      return repository.getOverview();
    });
