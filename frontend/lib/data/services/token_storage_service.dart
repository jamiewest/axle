import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing authentication tokens.
class TokenStorageService {
  TokenStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  /// Saves authentication tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    String? userId,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(
        key: _tokenExpiryKey,
        value: expiresAt.toIso8601String(),
      ),
      if (userId != null)
        _secureStorage.write(key: _userIdKey, value: userId),
    ]);
  }

  /// Gets the stored access token.
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Gets the stored refresh token.
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  /// Gets the token expiry date.
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  /// Gets the stored user ID.
  Future<String?> getUserId() async {
    return _secureStorage.read(key: _userIdKey);
  }

  /// Checks if the access token is expired.
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Clears all stored tokens.
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenExpiryKey),
      _secureStorage.delete(key: _userIdKey),
    ]);
  }

  /// Checks if tokens are stored.
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }
}
