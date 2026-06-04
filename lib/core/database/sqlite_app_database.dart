import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

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
  }
}
