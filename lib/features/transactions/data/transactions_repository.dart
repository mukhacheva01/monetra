import '../domain/transaction_entry.dart';

abstract class TransactionsRepository {
  List<TransactionEntry> getInitial();

  Future<List<TransactionEntry>> loadAll();

  Future<List<TransactionEntry>> add(TransactionEntry entry);

  Future<List<TransactionEntry>> update(TransactionEntry entry);

  Future<List<TransactionEntry>> delete(String transactionId);
}
