import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:axle/data/services/dev_logs_telemetry_provider.dart';
import 'package:axle/domain/models/telemetry_config.dart';
import 'package:axle/domain/models/telemetry_log_level.dart';
import 'package:axle/domain/services/telemetry_provider.dart';

/// Singleton service for application telemetry.
///
/// Provides a unified interface for logging, tracing, and metrics.
/// Automatically handles device identification and graceful fallback
/// if telemetry service is unavailable.
///
/// Usage:
/// ```dart
/// await TelemetryService().initialize(config: config);
/// TelemetryService().logInfo('User logged in', attributes: {'userId': '123'});
/// ```
class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  TelemetryProvider? _provider;
  late String _deviceId;
  late String _sessionId;
  late Map<String, dynamic> _resourceAttributes;

  bool _isInitialized = false;
  bool _isEnabled = false;

  /// Initialize telemetry with configuration.
  ///
  /// This should be called early in app startup (before runApp).
  /// If initialization fails, the service gracefully degrades to no-op.
  Future<void> initialize({
    required TelemetryConfig config,
    TelemetryProvider? customProvider,
  }) async {
    // Check if telemetry should be enabled
    if (!config.enabled) {
      developer.log('Telemetry disabled by configuration', name: 'Telemetry');
      _isInitialized = true;
      _isEnabled = false;
      return;
    }

    // Never enable in production unless explicitly allowed
    if (kReleaseMode && !config.enabledInProduction) {
      developer.log(
        'Telemetry disabled in production (use dedicated analytics)',
        name: 'Telemetry',
      );
      _isInitialized = true;
      _isEnabled = false;
      return;
    }

    try {
      // Generate or load device ID (persistent across app restarts)
      _deviceId = await _getOrCreateDeviceId();

      // Generate new session ID (unique per app launch)
      _sessionId = const Uuid().v4();

      // Collect device information
      _resourceAttributes = await _collectResourceAttributes(config);

      // Create provider
      _provider = customProvider ??
          DevLogsTelemetryProvider(serviceUrl: config.serviceUrl);

      // Initialize provider
      await _provider!.initialize(
        deviceId: _deviceId,
        sessionId: _sessionId,
        resourceAttributes: _resourceAttributes,
      );

      // Check if provider is healthy
      final isHealthy = await _provider!.healthCheck();

      if (isHealthy) {
        _isEnabled = true;
        developer.log(
          'Telemetry initialized successfully',
          name: 'Telemetry',
        );

        // Log initialization event
        await logInfo(
          'Telemetry initialized',
          attributes: {
            'device_id': _deviceId,
            'session_id': _sessionId,
          },
        );
      } else {
        developer.log(
          'Telemetry service unavailable - continuing without telemetry',
          name: 'Telemetry',
        );
        _isEnabled = false;
      }
    } catch (e, stack) {
      developer.log(
        'Telemetry initialization failed - continuing without telemetry',
        name: 'Telemetry',
        error: e,
        stackTrace: stack,
      );
      _isEnabled = false;
    } finally {
      _isInitialized = true;
    }
  }

  /// Log an informational message.
  Future<void> logInfo(String message,
      {Map<String, dynamic>? attributes}) async {
    await _logEvent(message, TelemetryLogLevel.info, attributes: attributes);
  }

  /// Log a debug message.
  Future<void> logDebug(String message,
      {Map<String, dynamic>? attributes}) async {
    await _logEvent(message, TelemetryLogLevel.debug, attributes: attributes);
  }

  /// Log a warning message.
  Future<void> logWarning(String message,
      {Map<String, dynamic>? attributes}) async {
    await _logEvent(message, TelemetryLogLevel.warning,
        attributes: attributes);
  }

  /// Log an error with optional exception and stack trace.
  Future<void> logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? attributes,
  }) async {
    final enrichedAttributes = {
      ...?attributes,
      if (error != null) 'error.type': error.runtimeType.toString(),
      if (error != null) 'error.message': error.toString(),
      if (stackTrace != null) 'error.stack_trace': stackTrace.toString(),
    };

    await _logEvent(
      message,
      TelemetryLogLevel.error,
      attributes: enrichedAttributes,
    );
  }

  /// Record a trace/span for tracking user flows or operations.
  Future<void> recordTrace(String name,
      {Map<String, dynamic>? attributes}) async {
    if (!_isInitialized || !_isEnabled || _provider == null) return;

    try {
      await _provider!.recordTrace(name, attributes: attributes);
    } catch (e) {
      // Silently handle - telemetry should never crash the app
      developer.log('Telemetry error: $e', name: 'Telemetry');
    }
  }

  /// Record a metric value.
  Future<void> recordMetric(
    String name,
    double value, {
    Map<String, dynamic>? attributes,
  }) async {
    if (!_isInitialized || !_isEnabled || _provider == null) return;

    try {
      await _provider!.recordMetric(name, value, attributes: attributes);
    } catch (e) {
      developer.log('Telemetry error: $e', name: 'Telemetry');
    }
  }

  /// Shutdown telemetry and flush any pending events.
  Future<void> shutdown() async {
    if (_provider != null) {
      await _provider!.shutdown();
    }
    developer.log('Telemetry shutdown', name: 'Telemetry');
  }

  /// Internal method to log events.
  Future<void> _logEvent(
    String message,
    TelemetryLogLevel level, {
    Map<String, dynamic>? attributes,
  }) async {
    if (!_isInitialized || !_isEnabled || _provider == null) return;

    try {
      await _provider!.logEvent(
        message,
        level,
        attributes: attributes,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Silently handle - telemetry should never crash the app
      developer.log('Telemetry error: $e', name: 'Telemetry');
    }
  }

  /// Get or create persistent device ID.
  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('telemetry_device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('telemetry_device_id', deviceId);
      developer.log('Created new device ID: $deviceId', name: 'Telemetry');
    }

    return deviceId;
  }

  /// Collect resource attributes about the device and environment.
  Future<Map<String, dynamic>> _collectResourceAttributes(
      TelemetryConfig config) async {
    final attributes = <String, dynamic>{
      'service.name': 'axle-flutter',
      'service.version': config.appVersion,
      'deployment.environment': config.environment,
      'session.id': _sessionId,
      'device.id': _deviceId,
    };

    try {
      if (kIsWeb) {
        attributes['device.platform'] = 'web';
        final browserInfo = await DeviceInfoPlugin().webBrowserInfo;
        attributes['device.browser'] = browserInfo.browserName.name;
      } else if (UniversalPlatform.isIOS) {
        attributes['device.platform'] = 'iOS';
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        attributes['device.model'] = iosInfo.utsname.machine;
        attributes['device.os.version'] = iosInfo.systemVersion;
      } else if (UniversalPlatform.isAndroid) {
        attributes['device.platform'] = 'Android';
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        attributes['device.model'] = androidInfo.model;
        attributes['device.os.version'] = androidInfo.version.release;
      } else if (UniversalPlatform.isMacOS) {
        attributes['device.platform'] = 'macOS';
        final macOsInfo = await DeviceInfoPlugin().macOsInfo;
        attributes['device.model'] = macOsInfo.model;
      } else if (UniversalPlatform.isWindows) {
        attributes['device.platform'] = 'Windows';
      } else if (UniversalPlatform.isLinux) {
        attributes['device.platform'] = 'Linux';
      }
    } catch (e) {
      developer.log('Failed to collect device info: $e', name: 'Telemetry');
      attributes['device.platform'] = 'unknown';
    }

    return attributes;
  }

  /// Setup global error handlers to capture uncaught errors.
  void setupErrorHandlers() {
    if (!_isInitialized || !_isEnabled) return;

    // Capture Flutter framework errors
    FlutterError.onError = (details) {
      logError(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
        attributes: {
          'error.source': 'FlutterError.onError',
          'error.context': details.context?.toString(),
        },
      );
    };

    // Capture platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(
        'Platform Error',
        error: error,
        stackTrace: stack,
        attributes: {
          'error.source': 'PlatformDispatcher.onError',
        },
      );
      return true; // Handled
    };

    developer.log('Global error handlers configured', name: 'Telemetry');
  }

  /// Get current device ID (for debugging).
  String? get deviceId => _isInitialized ? _deviceId : null;

  /// Get current session ID (for debugging).
  String? get sessionId => _isInitialized ? _sessionId : null;

  /// Check if telemetry is enabled and operational.
  bool get isEnabled => _isEnabled;
}
