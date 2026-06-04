import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/sqlite_app_database.dart';
import '../../../core/demo/demo_data.dart';
import '../../budgets/domain/budget_summary.dart';
import '../../categories/domain/category_item.dart';
import '../data/sqlite_transactions_repository.dart';
import '../data/transactions_repository.dart';
import '../domain/transaction_entry.dart';

final categoriesProvider = Provider<List<CategoryItem>>((ref) {
  return DemoData.categories;
});

final appDatabaseProvider = Provider<SqliteAppDatabase>((ref) {
  final database = SqliteAppDatabase();
  ref.onDispose(database.dispose);
  return database;
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return SqliteTransactionsRepository(ref.watch(appDatabaseProvider));
});

final transactionsProvider =
    StateNotifierProvider<TransactionsController, List<TransactionEntry>>((ref) {
  final repository = ref.watch(transactionsRepositoryProvider);
  return TransactionsController(repository);
});

final expenseTransactionsProvider = Provider<List<TransactionEntry>>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((entry) => entry.isExpense)
      .toList(growable: false);
});

final totalExpensesProvider = Provider<double>((ref) {
  return ref
      .watch(expenseTransactionsProvider)
      .fold<double>(0, (sum, entry) => sum + entry.amount);
});

final totalIncomeProvider = Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((entry) => !entry.isExpense)
      .fold<double>(0, (sum, entry) => sum + entry.amount);
});

final budgetSummariesProvider = Provider<List<BudgetSummary>>((ref) {
  final transactions = ref.watch(expenseTransactionsProvider);
  final categories = ref.watch(categoriesProvider);
  final baseBudgets = DemoData.budgets;

  return baseBudgets.map((budget) {
    final category = categories.firstWhere(
      (item) => item.id == budget.categoryId,
      orElse: () => CategoryItem(
        id: budget.categoryId,
        name: budget.title,
        emoji: '*',
        colorHex: 0xFF1DAA7A,
      ),
    );

    final spent = transactions
        .where((entry) => entry.categoryId == budget.categoryId)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    return BudgetSummary(
      categoryId: budget.categoryId,
      title: category.name,
      spent: spent,
      limit: budget.limit,
    );
  }).toList(growable: false);
});

final topExpenseCategoryProvider = Provider<CategoryItem?>((ref) {
  final expenses = ref.watch(expenseTransactionsProvider);
  final categories = ref.watch(categoriesProvider);
  final totals = <String, double>{};

  for (final entry in expenses) {
    totals.update(
      entry.categoryId,
      (value) => value + entry.amount,
      ifAbsent: () => entry.amount,
    );
  }

  if (totals.isEmpty) {
    return null;
  }

  final topId = totals.entries.reduce((left, right) {
    return left.value >= right.value ? left : right;
  }).key;

  for (final item in categories) {
    if (item.id == topId) {
      return item;
    }
  }

  return null;
});

class TransactionsController extends StateNotifier<List<TransactionEntry>> {
  TransactionsController(this._repository) : super(_repository.getInitial()) {
    _hydrate();
  }

  final TransactionsRepository _repository;

  Future<void> _hydrate() async {
    state = await _repository.loadAll();
  }

  Future<void> addExpense({
    required double amount,
    required String categoryId,
    required String note,
  }) async {
    await addTransaction(
      amount: amount,
      categoryId: categoryId,
      note: note,
      type: TransactionType.expense,
    );
  }

  Future<void> addTransaction({
    required double amount,
    required String categoryId,
    required String note,
    required TransactionType type,
  }) async {
    final entry = TransactionEntry(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      type: type,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      note: note.isEmpty ? null : note,
    );

    state = await _repository.add(entry);
  }

  Future<void> updateTransaction({
    required TransactionEntry original,
    required double amount,
    required String categoryId,
    required String note,
    required TransactionType type,
  }) async {
    final updated = original.copyWith(
      amount: amount,
      categoryId: categoryId,
      note: note.isEmpty ? null : note,
      type: type,
    );

    state = await _repository.update(updated);
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = await _repository.delete(transactionId);
  }
}
