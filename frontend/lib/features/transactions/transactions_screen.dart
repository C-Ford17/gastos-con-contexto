import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses/expenses_providers.dart';
import '../expenses/expense_model.dart';
// Import circular: se declara aquí para evitar extra archivos
import 'new_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final _qCtrl = TextEditingController();
  String? _categoryId;
  int _limit = 50;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      setState(() {
        _categoryId = null;
        _offset = 0;
      });
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _qCtrl.dispose();
    super.dispose();
  }

  String get _type => _tab.index == 0 ? 'expense' : 'income';

  // Este mes (UTC)
  Map<String, String> _monthRangeUtc() {
    final now = DateTime.now().toUtc();
    final from = DateTime.utc(now.year, now.month, 1);
    final to = DateTime.utc(
      now.year,
      now.month + 1,
      1,
    ).subtract(const Duration(seconds: 1));
    return {'from': from.toIso8601String(), 'to': to.toIso8601String()};
  }

  @override
  Widget build(BuildContext context) {
    final range = _monthRangeUtc();
    final query = ExpensesQuery(
      type: _type,
      from: range['from']!,
      to: range['to']!,
      q: _qCtrl.text.trim().isEmpty ? null : _qCtrl.text.trim(),
      categoryId: _categoryId,
      limit: _limit,
      offset: _offset,
    );

    final catsAsync = ref.watch(categoriesProvider(_type));
    final expensesAsync = ref.watch(expensesProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Gastos'),
            Tab(text: 'Ingresos'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => NewTransactionScreen(initialType: _type),
            ),
          );

          if (ok == true) {
            // refrescar lista (y dashboard si lo tienes en provider global)
            ref.invalidate(expensesProvider);
            // si tu dashboardSummaryProvider está en home_dashboard_screen.dart como provider global,
            // muévelo a un archivo providers.dart para poder invalidarlo aquí también.
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                TextField(
                  controller: _qCtrl,
                  decoration: InputDecoration(
                    labelText: 'Buscar (nota)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() => _offset = 0),
                    ),
                  ),
                  onSubmitted: (_) => setState(() => _offset = 0),
                ),
                const SizedBox(height: 12),
                catsAsync.when(
                  data: (cats) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _categoryId,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Todas las categorías'),
                              ),
                              ...cats.map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text('${c.emoji} ${c.name}'),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              _categoryId = v;
                              _offset = 0;
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Refrescar',
                          onPressed: () {
                            ref.invalidate(categoriesProvider(_type));
                            ref.invalidate(expensesProvider);
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('Error categorías: $e'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: expensesAsync.when(
              data: (data) => _ResultsList(
                items: data.results,
                count: data.count,
                limit: _limit,
                offset: _offset,
                onPrev: _offset <= 0
                    ? null
                    : () => setState(
                        () => _offset = (_offset - _limit).clamp(0, 1 << 30),
                      ),
                onNext: (_offset + _limit) >= data.count
                    ? null
                    : () => setState(() => _offset = _offset + _limit),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.items,
    required this.count,
    required this.limit,
    required this.offset,
    required this.onPrev,
    required this.onNext,
  });

  final List<Expense> items;
  final int count;
  final int limit;
  final int offset;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text('Mostrando ${items.length} de $count'),
              const Spacer(),
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${offset + 1}-${(offset + items.length).clamp(0, count)}'),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final x = items[i];
              final sign = x.type == 'expense' ? '-' : '+';
              return ListTile(
                title: Text(
                  '$sign ${x.amount.toStringAsFixed(0)} ${x.currency}',
                ),
                subtitle: Text('${x.categoryNameSnapshot} • ${x.note}'),
                trailing: Text('${x.date.toLocal()}'.split('.').first),
              );
            },
          ),
        ),
      ],
    );
  }
}
