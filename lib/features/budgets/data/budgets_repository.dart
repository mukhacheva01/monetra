import '../domain/budget_entry.dart';

abstract class BudgetsRepository {
  List<BudgetEntry> getInitial();

  Future<List<BudgetEntry>> loadAll();

  Future<List<BudgetEntry>> add(BudgetEntry entry);

  Future<List<BudgetEntry>> update(BudgetEntry entry);

  Future<List<BudgetEntry>> delete(String budgetId);
}
