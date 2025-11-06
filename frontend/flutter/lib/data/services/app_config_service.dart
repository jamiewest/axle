import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing application configuration settings.
///
/// Handles persistent storage of user-configurable settings like API URL,
/// with fallback to environment variables and defaults.
class AppConfigService {
  AppConfigService._();

  static final AppConfigService _instance = AppConfigService._();
  factory AppConfigService() => _instance;

  static const String _keyApiUrl = 'api_url';
  static const String _keyUseCustomUrl = 'use_custom_url';
  static const String _defaultApiUrl = 'http://localhost:5103';

  SharedPreferences? _prefs;

  /// Initialize the service. Must be called before using other methods.
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get the current API URL.
  ///
  /// Returns the custom URL if set, otherwise returns the default URL.
  String getApiUrl() {
    if (_prefs == null) {
      return _defaultApiUrl;
    }

    final useCustom = _prefs!.getBool(_keyUseCustomUrl) ?? false;
    if (useCustom) {
      return _prefs!.getString(_keyApiUrl) ?? _defaultApiUrl;
    }

    return _defaultApiUrl;
  }

  /// Set a custom API URL.
  Future<void> setApiUrl(String url) async {
    await _prefs?.setString(_keyApiUrl, url);
    await _prefs?.setBool(_keyUseCustomUrl, true);
  }

  /// Reset to default API URL.
  Future<void> resetToDefault() async {
    await _prefs?.setBool(_keyUseCustomUrl, false);
  }

  /// Check if using a custom URL.
  bool isUsingCustomUrl() {
    return _prefs?.getBool(_keyUseCustomUrl) ?? false;
  }

  /// Get the stored custom URL (may not be the active URL).
  String? getStoredCustomUrl() {
    return _prefs?.getString(_keyApiUrl);
  }

  /// Clear all stored settings.
  Future<void> clearAll() async {
    await _prefs?.remove(_keyApiUrl);
    await _prefs?.remove(_keyUseCustomUrl);
  }
}
