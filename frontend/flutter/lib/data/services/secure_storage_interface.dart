/// Abstract interface for secure storage operations.
/// Allows for platform-specific implementations.
abstract class SecureStorageInterface {
  /// Writes a key-value pair to secure storage.
  Future<void> write({required String key, required String value});

  /// Reads a value from secure storage by key.
  Future<String?> read({required String key});

  /// Deletes a value from secure storage by key.
  Future<void> delete({required String key});

  /// Deletes all values from secure storage.
  Future<void> deleteAll();

  /// Checks if a key exists in secure storage.
  Future<bool> containsKey({required String key});
}
