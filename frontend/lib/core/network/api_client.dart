import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({required this.baseUrl, required this.tokenStorage}) {
    dio = Dio(BaseOptions(baseUrl: baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  final String baseUrl;
  final TokenStorage tokenStorage;
  late final Dio dio;
}
