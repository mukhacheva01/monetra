class BudgetSummary {
  const BudgetSummary({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.spent,
    required this.limit,
    required this.monthKey,
  });

  final String id;
  final String categoryId;
  final String title;
  final double spent;
  final double limit;
  final String monthKey;

  double get progress => limit == 0 ? 0 : (spent / limit).clamp(0, 1);
  double get left => limit - spent;
}
