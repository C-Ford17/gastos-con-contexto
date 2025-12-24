import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import '../categories/categories_repository.dart';
import '../categories/category_model.dart';
import '../expenses/expenses_repository.dart';
import '../expenses/expense_model.dart';

final categoriesRepositoryProvider = Provider((ref) {
  return CategoriesRepository(ref.watch(apiClientProvider));
});

final expensesRepositoryProvider = Provider((ref) {
  return ExpensesRepository(ref.watch(apiClientProvider));
});

final categoriesProvider = FutureProvider.family<List<Category>, String>((
  ref,
  type,
) async {
  return ref.watch(categoriesRepositoryProvider).list(type: type);
});

class ExpensesQuery {
  const ExpensesQuery({
    required this.type,
    required this.from,
    required this.to,
    this.q,
    this.categoryId,
    this.limit = 50,
    this.offset = 0,
  });

  final String type; // expense|income
  final String from;
  final String to;
  final String? q;
  final String? categoryId;
  final int limit;
  final int offset;
}

final expensesProvider =
    FutureProvider.family<({int count, List<Expense> results}), ExpensesQuery>((
      ref,
      query,
    ) async {
      return ref
          .watch(expensesRepositoryProvider)
          .list(
            from: query.from,
            to: query.to,
            type: query.type,
            limit: query.limit,
            offset: query.offset,
            q: query.q,
            categoryId: query.categoryId,
          );
    });
