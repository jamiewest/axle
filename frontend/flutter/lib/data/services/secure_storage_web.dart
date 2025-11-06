import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_interface.dart';

/// Web implementation using shared_preferences.
/// Uses browser's localStorage. Note: This is NOT encrypted on web.
/// For better security on web, consider using httpOnly cookies set by your backend.
class SecureStorageWeb implements SecureStorageInterface {
  SecureStorageWeb({SharedPreferences? preferences})
      : _preferences = preferences;

  SharedPreferences? _preferences;

  // Prefix to namespace our keys
  static const String _keyPrefix = 'secure_';

  Future<SharedPreferences> get _prefs async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  String _prefixKey(String key) => '$_keyPrefix$key';

  @override
  Future<void> write({required String key, required String value}) async {
    final prefs = await _prefs;
    await prefs.setString(_prefixKey(key), value);
  }

  @override
  Future<String?> read({required String key}) async {
    final prefs = await _prefs;
    return prefs.getString(_prefixKey(key));
  }

  @override
  Future<void> delete({required String key}) async {
    final prefs = await _prefs;
    await prefs.remove(_prefixKey(key));
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    final prefs = await _prefs;
    return prefs.containsKey(_prefixKey(key));
  }
}
