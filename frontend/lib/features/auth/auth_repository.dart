import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository(this.api, this.storage);

  final ApiClient api;
  final TokenStorage storage;

  Future<void> login(String email, String password) async {
    final res = await api.dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final access = res.data['access'] as String;
    await storage.saveAccess(access);
  }

  Future<void> logout() => storage.clear();
}
