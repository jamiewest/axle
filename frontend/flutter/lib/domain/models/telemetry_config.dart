/// Configuration for telemetry service.
class TelemetryConfig {
  const TelemetryConfig({
    required this.enabled,
    required this.serviceUrl,
    required this.appVersion,
    this.environment = 'development',
    this.enabledInProduction = false,
  });

  /// Whether telemetry is enabled.
  final bool enabled;

  /// Base URL of the telemetry collector service.
  final String serviceUrl;

  /// Application version for resource attributes.
  final String appVersion;

  /// Deployment environment (development, staging, production).
  final String environment;

  /// Whether to enable telemetry in production.
  /// Should be false - use dedicated analytics in production.
  final bool enabledInProduction;

  /// Development configuration.
  factory TelemetryConfig.development({
    bool enabled = true,
    String serviceUrl = 'http://localhost:5200',
    required String appVersion,
  }) {
    return TelemetryConfig(
      enabled: enabled,
      serviceUrl: serviceUrl,
      appVersion: appVersion,
      environment: 'development',
      enabledInProduction: false,
    );
  }

  /// Disabled configuration (for production or when telemetry not needed).
  factory TelemetryConfig.disabled() {
    return const TelemetryConfig(
      enabled: false,
      serviceUrl: '',
      appVersion: '',
      environment: 'production',
      enabledInProduction: false,
    );
  }
}
