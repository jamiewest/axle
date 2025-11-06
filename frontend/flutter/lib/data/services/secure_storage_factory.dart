import 'package:universal_platform/universal_platform.dart';
import 'secure_storage_interface.dart';
import 'secure_storage_mobile.dart';
import 'secure_storage_web.dart';

/// Factory for creating platform-specific secure storage implementations.
class SecureStorageFactory {
  /// Creates the appropriate secure storage implementation for the current platform.
  static SecureStorageInterface create() {
    if (UniversalPlatform.isWeb) {
      return SecureStorageWeb();
    } else {
      return SecureStorageMobile();
    }
  }
}
