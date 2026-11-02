/// Captures stored values exactly as they are, and puts them back, so a
/// restore that fails part-way leaves the app's data as it found it.
///
/// Works on the raw stored values rather than through the sections, so even
/// data a section cannot read is put back untouched.
abstract interface class BackupSnapshotStore {
  /// The stored value of each of [keys]; `null` for a key with no value.
  Map<String, Object?> capture(Set<String> keys);

  /// Writes back every value of [snapshot], removing the keys that held
  /// none. Whether every write succeeded.
  Future<bool> putBack(Map<String, Object?> snapshot);
}
