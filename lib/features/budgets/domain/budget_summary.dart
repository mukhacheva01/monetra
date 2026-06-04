class BudgetSummary {
  const BudgetSummary({
    required this.categoryId,
    required this.title,
    required this.spent,
    required this.limit,
  });

  final String categoryId;
  final String title;
  final double spent;
  final double limit;

  double get progress => limit == 0 ? 0 : (spent / limit).clamp(0, 1);
  double get left => limit - spent;
}
