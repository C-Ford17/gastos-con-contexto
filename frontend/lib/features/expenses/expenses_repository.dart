import '../../core/network/api_client.dart';
import 'expense_model.dart';

class ExpensesRepository {
  ExpensesRepository(this.api);
  final ApiClient api;

  Future<({int count, List<Expense> results})> list({
    required String from,
    required String to,
    required String type, // expense|income
    required int limit,
    required int offset,
    String? q,
    String? categoryId,
  }) async {
    final res = await api.dio.get(
      '/api/expenses',
      queryParameters: {
        'from': from,
        'to': to,
        'type': type,
        'limit': limit,
        'offset': offset,
        if (q != null && q.isNotEmpty) 'q': q,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
      },
    );

    final map = Map<String, dynamic>.from(res.data as Map);
    final results = (map['results'] as List).cast<Map<String, dynamic>>();
    return (
      count: map['count'] as int,
      results: results.map(Expense.fromJson).toList(),
    );
  }

  Future<Expense> create({
    required String type,
    required double amount,
    required String categoryId,
    required DateTime dateUtc,
    String currency = 'COP',
    int? mood,
    String? reason,
    String note = '',
    List<String> tags = const [],
  }) async {
    final res = await api.dio.post(
      '/api/expenses',
      data: {
        'type': type,
        'amount': amount,
        'currency': currency,
        'date': dateUtc.toIso8601String(),
        'categoryId': categoryId,
        if (mood != null) 'mood': mood,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        'note': note,
        'tags': tags,
      },
    );
    return Expense.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
