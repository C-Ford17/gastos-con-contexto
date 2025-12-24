import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import 'auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthLoggedIn extends AuthState {
  const AuthLoggedIn();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

final tokenStorageProvider = Provider((ref) => TokenStorage());

final apiClientProvider = Provider((ref) {
  return ApiClient(
    baseUrl: 'http://localhost:8000',
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repo;
  late final TokenStorage _storage;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    _storage = ref.read(tokenStorageProvider);

    // “bootstrap” async sin bloquear build:
    _bootstrap();

    return const AuthUnknown();
  }

  Future<void> _bootstrap() async {
    final token = await _storage.readAccess();
    state = (token == null || token.isEmpty)
        ? const AuthLoggedOut()
        : const AuthLoggedIn();
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    await _repo.login(email, password);
    state = const AuthLoggedIn();
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthLoggedOut();
  }
}
