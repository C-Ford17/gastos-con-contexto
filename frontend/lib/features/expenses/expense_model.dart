class Expense {
  Expense({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.categoryId,
    required this.categoryNameSnapshot,
    this.mood,
    this.reason,
    required this.note,
    required this.tags,
  });

  final String id;
  final String type; // expense|income
  final double amount;
  final String currency;
  final DateTime date;

  final String categoryId;
  final String categoryNameSnapshot;

  final int? mood;
  final String? reason;
  final String note;
  final List<String> tags;

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    type: json['type'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: (json['currency'] ?? 'COP') as String,
    date: DateTime.parse(json['date'] as String),
    categoryId: json['categoryId'] as String,
    categoryNameSnapshot: (json['categoryNameSnapshot'] ?? '') as String,
    mood: json['mood'] as int?,
    reason: json['reason'] as String?,
    note: (json['note'] ?? '') as String,
    tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
  );
}
