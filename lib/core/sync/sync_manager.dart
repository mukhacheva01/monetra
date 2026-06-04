/// Coordinates background sync when cloud backup is enabled.
///
/// MVP can ship with a no-op implementation while keeping the interface stable.
abstract class SyncManager {
  Future<void> enqueue(String entityType, String entityId);
  Future<void> runPending();
}
