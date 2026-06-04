import '../../../core/database/sqlite_app_database.dart';
import '../../../core/demo/demo_data.dart';
import '../domain/budget_entry.dart';
import 'budgets_repository.dart';

class SqliteBudgetsRepository implements BudgetsRepository {
  SqliteBudgetsRepository(this._database);

  final SqliteAppDatabase _database;

  @override
  List<BudgetEntry> getInitial() {
    return List.of(DemoData.budgetEntries);
  }

  @override
  Future<List<BudgetEntry>> loadAll() async {
    await _database.initialize();

    if (await _database.budgetsCount() == 0) {
      await _database.seedBudgets(getInitial());
    }

    return _database.getBudgets();
  }

  @override
  Future<List<BudgetEntry>> add(BudgetEntry entry) async {
    await _database.insertBudget(entry);
    return _database.getBudgets();
  }

  @override
  Future<List<BudgetEntry>> update(BudgetEntry entry) async {
    await _database.updateBudget(entry);
    return _database.getBudgets();
  }

  @override
  Future<List<BudgetEntry>> delete(String budgetId) async {
    await _database.deleteBudget(budgetId);
    return _database.getBudgets();
  }
}
