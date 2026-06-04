class BudgetEntry {
  const BudgetEntry({
    required this.id,
    required this.categoryId,
    required this.monthKey,
    required this.limit,
  });

  final String id;
  final String categoryId;
  final String monthKey;
  final double limit;

  BudgetEntry copyWith({
    String? id,
    String? categoryId,
    String? monthKey,
    double? limit,
  }) {
    return BudgetEntry(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthKey: monthKey ?? this.monthKey,
      limit: limit ?? this.limit,
    );
  }
}
