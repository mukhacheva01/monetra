import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../features/budgets/domain/budget_entry.dart';
import '../../features/transactions/domain/transaction_entry.dart';
import 'app_database.dart';

class SqliteAppDatabase implements AppDatabase {
  Database? _database;

  @override
  Future<void> initialize() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final directory = await _resolveStorageDirectory();
    final file = File(path.join(directory.path, 'monetra.sqlite'));
    await file.parent.create(recursive: true);

    final database = sqlite3.open(file.path);
    _createSchema(database);
    _database = database;
    return database;
  }

  Future<Directory> _resolveStorageDirectory() async {
    final appData = Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'];

    if (appData != null && appData.isNotEmpty) {
      final directory = Directory(path.join(appData, 'Monetra'));
      await directory.create(recursive: true);
      return directory;
    }

    final directory = Directory(path.join(Directory.current.path, '.monetra'));
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<void> clearAll() async {
    final db = await database;
    db.execute('DELETE FROM transactions;');
    db.execute('DELETE FROM budgets;');
  }

  @override
  Future<void> dispose() async {
    _database?.dispose();
    _database = null;
  }

  Future<int> transactionsCount() async {
    final db = await database;
    final result = db.select('SELECT COUNT(*) AS count FROM transactions;');
    return result.first['count'] as int;
  }

  Future<int> budgetsCount() async {
    final db = await database;
    final result = db.select('SELECT COUNT(*) AS count FROM budgets;');
    return result.first['count'] as int;
  }

  Future<List<TransactionEntry>> getTransactions() async {
    final db = await database;
    final rows = db.select(
      '''
      SELECT id, amount, type, category_id, created_at, note
      FROM transactions
      ORDER BY datetime(created_at) DESC;
      ''',
    );

    return rows.map((row) {
      return TransactionEntry(
        id: row['id'] as String,
        amount: row['amount'] as double,
        type: TransactionType.values.firstWhere(
          (item) => item.name == row['type'],
        ),
        categoryId: row['category_id'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        note: row['note'] as String?,
      );
    }).toList(growable: false);
  }

  Future<void> insertTransaction(TransactionEntry entry) async {
    final db = await database;
    final statement = db.prepare(
      '''
      INSERT INTO transactions (
        id,
        amount,
        type,
        category_id,
        created_at,
        note
      ) VALUES (?, ?, ?, ?, ?, ?);
      ''',
    );

    try {
      statement.execute([
        entry.id,
        entry.amount,
        entry.type.name,
        entry.categoryId,
        entry.createdAt.toIso8601String(),
        entry.note,
      ]);
    } finally {
      statement.dispose();
    }
  }

  Future<void> updateTransaction(TransactionEntry entry) async {
    final db = await database;
    final statement = db.prepare(
      '''
      UPDATE transactions
      SET amount = ?, type = ?, category_id = ?, created_at = ?, note = ?
      WHERE id = ?;
      ''',
    );

    try {
      statement.execute([
        entry.amount,
        entry.type.name,
        entry.categoryId,
        entry.createdAt.toIso8601String(),
        entry.note,
        entry.id,
      ]);
    } finally {
      statement.dispose();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final db = await database;
    final statement = db.prepare(
      'DELETE FROM transactions WHERE id = ?;',
    );

    try {
      statement.execute([transactionId]);
    } finally {
      statement.dispose();
    }
  }

  Future<List<BudgetEntry>> getBudgets() async {
    final db = await database;
    final rows = db.select(
      '''
      SELECT id, category_id, month_key, limit_amount
      FROM budgets
      ORDER BY month_key DESC, category_id ASC;
      ''',
    );

    return rows.map((row) {
      return BudgetEntry(
        id: row['id'] as String,
        categoryId: row['category_id'] as String,
        monthKey: row['month_key'] as String,
        limit: row['limit_amount'] as double,
      );
    }).toList(growable: false);
  }

  Future<void> insertBudget(BudgetEntry entry) async {
    final db = await database;
    final statement = db.prepare(
      '''
      INSERT INTO budgets (
        id,
        category_id,
        month_key,
        limit_amount
      ) VALUES (?, ?, ?, ?);
      ''',
    );

    try {
      statement.execute([
        entry.id,
        entry.categoryId,
        entry.monthKey,
        entry.limit,
      ]);
    } finally {
      statement.dispose();
    }
  }

  Future<void> updateBudget(BudgetEntry entry) async {
    final db = await database;
    final statement = db.prepare(
      '''
      UPDATE budgets
      SET category_id = ?, month_key = ?, limit_amount = ?
      WHERE id = ?;
      ''',
    );

    try {
      statement.execute([
        entry.categoryId,
        entry.monthKey,
        entry.limit,
        entry.id,
      ]);
    } finally {
      statement.dispose();
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    final db = await database;
    final statement = db.prepare('DELETE FROM budgets WHERE id = ?;');

    try {
      statement.execute([budgetId]);
    } finally {
      statement.dispose();
    }
  }

  Future<void> seedTransactions(List<TransactionEntry> entries) async {
    final db = await database;
    db.execute('BEGIN TRANSACTION;');

    try {
      final statement = db.prepare(
        '''
        INSERT INTO transactions (
          id,
          amount,
          type,
          category_id,
          created_at,
          note
        ) VALUES (?, ?, ?, ?, ?, ?);
        ''',
      );

      try {
        for (final entry in entries) {
          statement.execute([
            entry.id,
            entry.amount,
            entry.type.name,
            entry.categoryId,
            entry.createdAt.toIso8601String(),
            entry.note,
          ]);
        }
      } finally {
        statement.dispose();
      }

      db.execute('COMMIT;');
    } catch (_) {
      db.execute('ROLLBACK;');
      rethrow;
    }
  }

  Future<void> seedBudgets(List<BudgetEntry> entries) async {
    final db = await database;
    db.execute('BEGIN TRANSACTION;');

    try {
      final statement = db.prepare(
        '''
        INSERT INTO budgets (
          id,
          category_id,
          month_key,
          limit_amount
        ) VALUES (?, ?, ?, ?);
        ''',
      );

      try {
        for (final entry in entries) {
          statement.execute([
            entry.id,
            entry.categoryId,
            entry.monthKey,
            entry.limit,
          ]);
        }
      } finally {
        statement.dispose();
      }

      db.execute('COMMIT;');
    } catch (_) {
      db.execute('ROLLBACK;');
      rethrow;
    }
  }

  void _createSchema(Database db) {
    db.execute(
      '''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        note TEXT
      );
      ''',
    );
    db.execute(
      '''
      CREATE TABLE IF NOT EXISTS budgets (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        month_key TEXT NOT NULL,
        limit_amount REAL NOT NULL
      );
      ''',
    );
  }
}
