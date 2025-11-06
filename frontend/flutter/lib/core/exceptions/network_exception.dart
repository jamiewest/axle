import 'dart:io';
import 'dart:async';

/// Helper class for identifying and handling network-related exceptions.
class NetworkExceptionHelper {
  /// Check if an exception is network-related.
  static bool isNetworkException(dynamic error) {
    return error is SocketException ||
        error is TimeoutException ||
        error is HttpException ||
        (error.toString().contains('Failed host lookup')) ||
        (error.toString().contains('Connection refused')) ||
        (error.toString().contains('Network is unreachable'));
  }

  /// Get a user-friendly error message for a network exception.
  static String getUserFriendlyMessage(dynamic error) {
    if (error is SocketException) {
      return 'Cannot connect to server. Please check your network connection and server settings.';
    } else if (error is TimeoutException) {
      return 'Connection timed out. The server is taking too long to respond.';
    } else if (error is HttpException) {
      return 'HTTP error: ${error.message}';
    } else if (error.toString().contains('Failed host lookup')) {
      return 'Cannot find server. Please check the server URL in settings.';
    } else if (error.toString().contains('Connection refused')) {
      return 'Server connection refused. Please verify the server is running.';
    } else if (error.toString().contains('Network is unreachable')) {
      return 'Network is unreachable. Please check your internet connection.';
    }

    return 'Network error. Please check your connection and try again.';
  }

  /// Check if the error suggests the server is offline.
  static bool isServerOffline(dynamic error) {
    return error is SocketException ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('Failed host lookup');
  }

  /// Check if the error is a timeout.
  static bool isTimeout(dynamic error) {
    return error is TimeoutException;
  }
}
