import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_interface.dart';

/// Mobile implementation using flutter_secure_storage.
/// Uses the device's secure keychain (iOS Keychain, Android Keystore).
class SecureStorageMobile implements SecureStorageInterface {
  SecureStorageMobile({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    final value = await _secureStorage.read(key: key);
    return value != null;
  }
}
