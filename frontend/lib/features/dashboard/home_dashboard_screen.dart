import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_controller.dart';

final dashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(
    '/api/insights/summary',
    queryParameters: {
      'from': '2025-12-01T00:00:00Z',
      'to': '2025-12-31T23:59:59Z',
    },
  );
  return Map<String, dynamic>.from(res.data as Map);
});

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: summary.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Total income: ${data['totalIncome']}'),
            Text('Total expense: ${data['totalExpense']}'),
            Text('Balance: ${data['balance']}'),
            const SizedBox(height: 12),
            Text('Top categories: ${data['topCategories']}'),
            const SizedBox(height: 12),
            Text('Expense by day: ${data['expenseByDay']}'),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
