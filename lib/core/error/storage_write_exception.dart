/// Thrown by a local data source when the platform refuses a write. The
/// repository converts it into a `StorageWriteFailed`.
class StorageWriteException implements Exception {
  const new(this.key);

  final String key;

  @override
  String toString() => 'StorageWriteException($key)';
}
