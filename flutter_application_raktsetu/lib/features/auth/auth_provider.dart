import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import 'auth_repository.dart';
import 'user_model.dart';
export 'user_model.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider).client;
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(client, storage);
});

final currentUserProvider = StateNotifierProvider<UserNotifier, AppUser?>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return UserNotifier(repository);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    final userNotifier = ref.read(currentUserProvider.notifier);
    return AuthNotifier(repository, userNotifier);
  },
);

class UserNotifier extends StateNotifier<AppUser?> {
  final AuthRepository _repository;

  UserNotifier(this._repository) : super(null) {
    refresh();
  }

  Future<void> refresh() async {
    state = await _repository.getCurrentUser();
  }

  void clear() {
    state = null;
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final UserNotifier _userNotifier;

  AuthNotifier(this._repository, this._userNotifier)
    : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.login(email, password);
      await _userNotifier.refresh();
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.logout();
      _userNotifier.clear();
    });
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.forgotPassword(email));
  }
}
