/// Entry point for the future local persistence layer.
///
/// Current implementation:
/// - SQLite as the storage engine
/// - feature repositories on top of the database
/// - local-first behavior as the default runtime path
abstract class AppDatabase {
  Future<void> initialize();
  Future<void> clearAll();
  Future<void> dispose();
}
