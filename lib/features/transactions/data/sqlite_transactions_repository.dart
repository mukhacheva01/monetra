import '../../../core/database/sqlite_app_database.dart';
import '../../../core/demo/demo_data.dart';
import '../domain/transaction_entry.dart';
import 'transactions_repository.dart';

class SqliteTransactionsRepository implements TransactionsRepository {
  SqliteTransactionsRepository(this._database);

  final SqliteAppDatabase _database;

  @override
  List<TransactionEntry> getInitial() {
    return List.of(DemoData.transactions)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }

  @override
  Future<List<TransactionEntry>> loadAll() async {
    await _database.initialize();

    if (await _database.transactionsCount() == 0) {
      await _database.seedTransactions(getInitial());
    }

    return _database.getTransactions();
  }

  @override
  Future<List<TransactionEntry>> add(TransactionEntry entry) async {
    await _database.insertTransaction(entry);
    return _database.getTransactions();
  }

  @override
  Future<List<TransactionEntry>> update(TransactionEntry entry) async {
    await _database.updateTransaction(entry);
    return _database.getTransactions();
  }

  @override
  Future<List<TransactionEntry>> delete(String transactionId) async {
    await _database.deleteTransaction(transactionId);
    return _database.getTransactions();
  }
}
