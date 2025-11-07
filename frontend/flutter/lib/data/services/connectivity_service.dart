import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Service for monitoring network connectivity and server reachability.
///
/// Provides real-time connectivity status and server health checks.
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final _connectivityController = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream of connectivity status changes.
  Stream<ConnectivityStatus> get connectivityStream =>
      _connectivityController.stream;

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  /// Get the current connectivity status.
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Initialize the connectivity service.
  Future<void> initialize() async {
    // Set up the stream listener first
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await checkConnectivity();
      },
    );

    // Start initial connectivity check in background - don't await it
    // This prevents blocking if the check takes too long on some platforms
    checkConnectivity().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        // If timeout, assume connected
        _updateStatus(ConnectivityStatus.connected);
      },
    ).catchError((_) {
      // Ignore errors during initial check
    });
  }

  /// Check current connectivity and update status.
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 2),
      );

      if (results.contains(ConnectivityResult.none)) {
        _updateStatus(ConnectivityStatus.disconnected);
      } else {
        _updateStatus(ConnectivityStatus.connected);
      }
    } catch (e) {
      // If check fails, assume connected
      _updateStatus(ConnectivityStatus.connected);
    }
  }

  /// Check if a specific server is reachable.
  ///
  /// Returns true if the server responds within the timeout period.
  Future<bool> checkServerReachability(
    String baseUrl, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      // Try to reach the server's base URL or a health endpoint
      final uri = Uri.parse(baseUrl);
      final response = await http.head(uri).timeout(timeout);
      return response.statusCode < 500; // Accept any non-server-error response
    } catch (e) {
      return false;
    }
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _connectivityController.add(status);
    }
  }

  /// Dispose of resources.
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// Connectivity status enumeration.
enum ConnectivityStatus {
  /// Network connectivity is available.
  connected,

  /// No network connectivity.
  disconnected,

  /// Connectivity status is unknown or being determined.
  unknown,
}
