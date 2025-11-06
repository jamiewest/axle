/// Request model for sending logs to the development telemetry collector.
///
/// Matches the DevLogRequest record in Axle.TelemetryCollector.
class DevLogRequest {
  const DevLogRequest({
    required this.message,
    required this.level,
    required this.deviceId,
    required this.sessionId,
    required this.platform,
    required this.appVersion,
    this.timestamp,
    this.attributes,
  });

  final String message;
  final String level;
  final String deviceId;
  final String sessionId;
  final String platform;
  final String appVersion;
  final DateTime? timestamp;
  final Map<String, dynamic>? attributes;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'level': level,
      'deviceId': deviceId,
      'sessionId': sessionId,
      'platform': platform,
      'appVersion': appVersion,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes,
    };
  }
}
