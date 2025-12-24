import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses/expenses_providers.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  const NewTransactionScreen({super.key, required this.initialType});
  final String initialType; // expense|income

  @override
  ConsumerState<NewTransactionScreen> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  late String _type;
  String _currency = 'COP';
  String? _categoryId;
  int? _mood;
  String? _reason;
  DateTime _dateLocal = DateTime.now(); // UI en local, se manda UTC

  bool _saving = false;
  String? _error;

  static const _currencies = ['COP', 'USD', 'EUR', 'MXN', 'BRL'];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesProvider(_type));

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva transacción')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Gasto')),
                      ButtonSegment(value: 'income', label: Text('Ingreso')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) {
                      setState(() {
                        _type = s.first;
                        _categoryId = null;
                        _reason = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monto'),
                    validator: (v) {
                      final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                      if (n == null || n <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _currency,
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v ?? 'COP'),
                    decoration: const InputDecoration(labelText: 'Moneda'),
                  ),
                  const SizedBox(height: 12),

                  catsAsync.when(
                    data: (cats) => DropdownButtonFormField<String>(
                      value: _categoryId,
                      items: cats
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.emoji} ${c.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Elige una categoría'
                          : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, st) => Text('Error categorías: $e'),
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha'),
                    subtitle: Text(_dateLocal.toString().split('.').first),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: _dateLocal,
                      );
                      if (picked == null) return;
                      setState(() {
                        _dateLocal = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          _dateLocal.hour,
                          _dateLocal.minute,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _reason,
                    items: const [
                      DropdownMenuItem(value: 'need', child: Text('Necesidad')),
                      DropdownMenuItem(value: 'craving', child: Text('Antojo')),
                      DropdownMenuItem(
                        value: 'impulse',
                        child: Text('Impulso'),
                      ),
                      DropdownMenuItem(value: 'other', child: Text('Otro')),
                    ],
                    onChanged: (v) => setState(() => _reason = v),
                    decoration: const InputDecoration(
                      labelText: 'Razón (opcional)',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text('Mood (opcional): '),
                      Expanded(
                        child: Slider(
                          min: 1,
                          max: 10,
                          divisions: 9,
                          value: (_mood ?? 7).toDouble(),
                          label: (_mood ?? 7).toString(),
                          onChanged: (v) => setState(() => _mood = v.round()),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Quitar',
                        onPressed: () => setState(() => _mood = null),
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),

                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nota (opcional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tags (opcional)',
                      hintText: 'Ej: social, unplanned',
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() {
                              _error = null;
                              _saving = true;
                            });

                            try {
                              if (!_formKey.currentState!.validate()) {
                                setState(() => _saving = false);
                                return;
                              }

                              final amount = double.parse(
                                _amountCtrl.text.replaceAll(',', '.'),
                              );
                              final note = _noteCtrl.text.trim();
                              final tags = _tagsCtrl.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();

                              // mandamos en UTC
                              final dateUtc = _dateLocal.toUtc();

                              await ref
                                  .read(expensesRepositoryProvider)
                                  .create(
                                    type: _type,
                                    amount: amount,
                                    currency: _currency,
                                    categoryId: _categoryId!,
                                    dateUtc: dateUtc,
                                    mood: _mood,
                                    reason: _reason,
                                    note: note,
                                    tags: tags,
                                  );

                              if (!mounted) return;
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _error = 'No se pudo guardar: $e');
                            } finally {
                              if (!mounted) return;
                              setState(() => _saving = false);
                            }
                          },
                    child: Text(_saving ? 'Guardando...' : 'Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
