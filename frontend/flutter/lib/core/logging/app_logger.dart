import 'dart:developer' as developer;
import 'package:axle/data/services/telemetry_service.dart';

/// Centralized logging service for consistent log formatting across the app.
///
/// Provides structured logging with common verbiage matching the backend.
/// All logs are sent to both the console (developer.log) and telemetry service.
class AppLogger {
  AppLogger(this._name);

  final String _name;

  /// Log an informational message about a successful operation.
  /// Example: "User authentication completed successfully"
  void logInfo(String message, {Map<String, dynamic>? attributes}) {
    final enriched = _enrichAttributes(attributes);
    developer.log(message, name: _name, level: 800);
    TelemetryService().logInfo(message, attributes: enriched);
  }

  /// Log a debug message for troubleshooting.
  /// Example: "Attempting to parse response body"
  void logDebug(String message, {Map<String, dynamic>? attributes}) {
    final enriched = _enrichAttributes(attributes);
    developer.log(message, name: _name, level: 500);
    TelemetryService().logDebug(message, attributes: enriched);
  }

  /// Log a warning about a recoverable issue.
  /// Example: "Token refresh failed, user will be signed out"
  void logWarning(String message, {Map<String, dynamic>? attributes}) {
    final enriched = _enrichAttributes(attributes);
    developer.log(message, name: _name, level: 900);
    TelemetryService().logWarning(message, attributes: enriched);
  }

  /// Log an error with optional exception details.
  /// Example: "Failed to authenticate user"
  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? attributes,
  }) {
    final enriched = _enrichAttributes(attributes);
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
    TelemetryService().logError(
      message,
      error: error,
      stackTrace: stackTrace,
      attributes: enriched,
    );
  }

  /// Log the start of an operation.
  /// Example: "Starting user authentication"
  void logOperationStart(String operation, {Map<String, dynamic>? attributes}) {
    logInfo('Starting $operation', attributes: attributes);
  }

  /// Log the successful completion of an operation.
  /// Example: "User authentication completed successfully"
  void logOperationSuccess(
    String operation, {
    Map<String, dynamic>? attributes,
  }) {
    logInfo('$operation completed successfully', attributes: attributes);
  }

  /// Log the failure of an operation.
  /// Example: "User authentication failed"
  void logOperationFailure(
    String operation, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? attributes,
  }) {
    logError(
      '$operation failed',
      error: error,
      stackTrace: stackTrace,
      attributes: attributes,
    );
  }

  /// Enrich attributes with logger name.
  Map<String, dynamic> _enrichAttributes(Map<String, dynamic>? attributes) {
    return {
      'logger': _name,
      ...?attributes,
    };
  }
}

/// Extension to make it easy to create loggers for any class.
extension LoggerExtension on Object {
  AppLogger get logger => AppLogger(runtimeType.toString());
}
