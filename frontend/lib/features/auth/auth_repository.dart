import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository(this.api, this.tokenStorage);

  final ApiClient api;
  final TokenStorage tokenStorage;

  Future<void> login({required String email, required String password}) async {
    final res = await api.dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final access = res.data['access'] as String;
    await tokenStorage.saveAccessToken(access);
  }

  Future<void> logout() => tokenStorage.clear();
}
