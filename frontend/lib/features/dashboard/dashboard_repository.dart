import '../../core/network/api_client.dart';

class DashboardRepository {
  DashboardRepository(this.api);
  final ApiClient api;

  Future<Map<String, dynamic>> getSummary({
    required String from,
    required String to,
  }) async {
    final res = await api.dio.get(
      '/api/insights/summary',
      queryParameters: {'from': from, 'to': to},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
