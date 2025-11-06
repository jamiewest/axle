/// Log levels for telemetry events.
enum TelemetryLogLevel {
  trace,
  debug,
  info,
  warning,
  error,
  fatal;

  String get name {
    switch (this) {
      case TelemetryLogLevel.trace:
        return 'trace';
      case TelemetryLogLevel.debug:
        return 'debug';
      case TelemetryLogLevel.info:
        return 'info';
      case TelemetryLogLevel.warning:
        return 'warning';
      case TelemetryLogLevel.error:
        return 'error';
      case TelemetryLogLevel.fatal:
        return 'fatal';
    }
  }
}
