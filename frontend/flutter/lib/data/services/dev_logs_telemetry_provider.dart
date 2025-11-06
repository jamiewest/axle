import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:axle/data/models/dev_log_request.dart';
import 'package:axle/domain/models/telemetry_log_level.dart';
import 'package:axle/domain/services/telemetry_provider.dart';

/// Telemetry provider that sends logs via HTTP to /devlogs endpoint.
///
/// This is a fallback provider until OTLP log export is stable in Flutter.
/// Works with the Axle.TelemetryCollector development service.
class DevLogsTelemetryProvider implements TelemetryProvider {
  DevLogsTelemetryProvider({
    required this.serviceUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String serviceUrl;
  final http.Client _httpClient;

  late String _deviceId;
  late String _sessionId;
  late String _platform;
  late String _appVersion;

  bool _isHealthy = false;
  bool _isInitialized = false;

  @override
  Future<void> initialize({
    required String deviceId,
    required String sessionId,
    required Map<String, dynamic> resourceAttributes,
  }) async {
    _deviceId = deviceId;
    _sessionId = sessionId;
    _platform = resourceAttributes['device.platform'] as String? ?? 'unknown';
    _appVersion = resourceAttributes['service.version'] as String? ?? '0.0.0';

    // Check if service is available
    _isHealthy = await healthCheck();
    _isInitialized = true;

    developer.log(
      'DevLogs telemetry initialized (healthy: $_isHealthy)',
      name: 'Telemetry',
    );
  }

  @override
  Future<void> logEvent(
    String message,
    TelemetryLogLevel level, {
    Map<String, dynamic>? attributes,
    DateTime? timestamp,
  }) async {
    if (!_isInitialized || !_isHealthy) {
      // Silently fail if service unavailable
      return;
    }

    final request = DevLogRequest(
      message: message,
      level: level.name,
      deviceId: _deviceId,
      sessionId: _sessionId,
      platform: _platform,
      appVersion: _appVersion,
      timestamp: timestamp,
      attributes: attributes,
    );

    try {
      final response = await _httpClient
          .post(
            Uri.parse('$serviceUrl/devlogs'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // Mark as unhealthy if timeout
              _isHealthy = false;
              throw TimeoutException('Telemetry service timeout');
            },
          );

      if (response.statusCode != 200) {
        developer.log(
          'Telemetry failed: ${response.statusCode}',
          name: 'Telemetry',
        );
        _isHealthy = false;
      }
    } catch (e) {
      // Silently handle errors - telemetry should never crash the app
      _isHealthy = false;
      developer.log('Telemetry error: $e', name: 'Telemetry');
    }
  }

  @override
  Future<void> recordTrace(
    String name, {
    Map<String, dynamic>? attributes,
  }) async {
    // Convert trace to log event for now
    await logEvent(
      'Trace: $name',
      TelemetryLogLevel.debug,
      attributes: attributes,
    );
  }

  @override
  Future<void> recordMetric(
    String name,
    double value, {
    Map<String, dynamic>? attributes,
  }) async {
    // Convert metric to log event for now
    await logEvent(
      'Metric: $name = $value',
      TelemetryLogLevel.info,
      attributes: attributes,
    );
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$serviceUrl/health'))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        'Telemetry service unavailable: $e',
        name: 'Telemetry',
      );
      return false;
    }
  }

  @override
  Future<void> shutdown() async {
    _httpClient.close();
    developer.log('DevLogs telemetry shutdown', name: 'Telemetry');
  }
}
