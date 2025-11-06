import 'package:axle/domain/models/telemetry_log_level.dart';

/// Abstract interface for telemetry providers.
///
/// Implementations can send telemetry via different protocols:
/// - DevLogs (HTTP REST endpoint)
/// - OTLP (OpenTelemetry Protocol)
/// - Mock (for testing)
abstract class TelemetryProvider {
  /// Initialize the provider with device and session information.
  Future<void> initialize({
    required String deviceId,
    required String sessionId,
    required Map<String, dynamic> resourceAttributes,
  });

  /// Log an event with a message, level, and optional attributes.
  Future<void> logEvent(
    String message,
    TelemetryLogLevel level, {
    Map<String, dynamic>? attributes,
    DateTime? timestamp,
  });

  /// Record a trace/span (for tracking user flows, API calls, etc.).
  Future<void> recordTrace(
    String name, {
    Map<String, dynamic>? attributes,
  });

  /// Record a metric (for performance monitoring, counters, etc.).
  Future<void> recordMetric(
    String name,
    double value, {
    Map<String, dynamic>? attributes,
  });

  /// Shutdown the provider and flush any pending telemetry.
  Future<void> shutdown();

  /// Check if the provider is healthy and can send telemetry.
  Future<bool> healthCheck();
}
