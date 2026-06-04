import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/domain/category_item.dart';
import '../../transactions/application/transactions_controller.dart';
import '../data/budgets_repository.dart';
import '../data/sqlite_budgets_repository.dart';
import '../domain/budget_entry.dart';
import '../domain/budget_summary.dart';

String currentMonthKey([DateTime? date]) {
  final value = date ?? DateTime.now();
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}

final budgetsRepositoryProvider = Provider<BudgetsRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SqliteBudgetsRepository(database);
});

final budgetEntriesProvider =
    StateNotifierProvider<BudgetsController, List<BudgetEntry>>((ref) {
  final repository = ref.watch(budgetsRepositoryProvider);
  return BudgetsController(repository);
});

final currentMonthBudgetsProvider = Provider<List<BudgetEntry>>((ref) {
  final monthKey = currentMonthKey();
  return ref
      .watch(budgetEntriesProvider)
      .where((entry) => entry.monthKey == monthKey)
      .toList(growable: false);
});

final budgetSummariesProvider = Provider<List<BudgetSummary>>((ref) {
  final budgets = ref.watch(currentMonthBudgetsProvider);
  final categories = ref.watch(categoriesProvider);
  final transactions = ref.watch(expenseTransactionsProvider);
  final monthKey = currentMonthKey();

  final monthlyTransactions = transactions.where((entry) {
    return currentMonthKey(entry.createdAt) == monthKey;
  }).toList(growable: false);

  return budgets.map((budget) {
    final category = categories.firstWhere(
      (item) => item.id == budget.categoryId,
      orElse: () => CategoryItem(
        id: budget.categoryId,
        name: budget.categoryId,
        emoji: '*',
        colorHex: 0xFF1DAA7A,
      ),
    );

    final spent = monthlyTransactions
        .where((entry) => entry.categoryId == budget.categoryId)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    return BudgetSummary(
      id: budget.id,
      categoryId: budget.categoryId,
      title: category.name,
      spent: spent,
      limit: budget.limit,
      monthKey: budget.monthKey,
    );
  }).toList(growable: false);
});

final uncategorizedMonthlySpendProvider = Provider<double>((ref) {
  final transactions = ref.watch(expenseTransactionsProvider);
  final budgets = ref.watch(currentMonthBudgetsProvider);
  final monthKey = currentMonthKey();
  final budgetedCategoryIds = budgets.map((item) => item.categoryId).toSet();

  return transactions.where((entry) {
    return currentMonthKey(entry.createdAt) == monthKey &&
        !budgetedCategoryIds.contains(entry.categoryId);
  }).fold<double>(0, (sum, entry) => sum + entry.amount);
});

class BudgetsController extends StateNotifier<List<BudgetEntry>> {
  BudgetsController(this._repository) : super(_repository.getInitial()) {
    _hydrate();
  }

  final BudgetsRepository _repository;

  Future<void> _hydrate() async {
    state = await _repository.loadAll();
  }

  Future<void> addBudget({
    required String categoryId,
    required double limit,
    String? monthKey,
  }) async {
    final entry = BudgetEntry(
      id: 'budget_${DateTime.now().microsecondsSinceEpoch}',
      categoryId: categoryId,
      monthKey: monthKey ?? currentMonthKey(),
      limit: limit,
    );

    state = await _repository.add(entry);
  }

  Future<void> updateBudget({
    required BudgetEntry original,
    required String categoryId,
    required double limit,
    required String monthKey,
  }) async {
    state = await _repository.update(
      original.copyWith(
        categoryId: categoryId,
        limit: limit,
        monthKey: monthKey,
      ),
    );
  }

  Future<void> deleteBudget(String budgetId) async {
    state = await _repository.delete(budgetId);
  }
}
