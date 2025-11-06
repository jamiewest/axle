/// Represents the result of an authentication operation.
class AuthResult {
  const AuthResult({
    required this.success,
    this.message,
    this.userId,
    this.errors,
    this.requiresEmailConfirmation = false,
    this.requiresTwoFactor = false,
  });

  /// Whether the operation succeeded.
  final bool success;

  /// Optional message describing the result.
  final String? message;

  /// User ID if authentication was successful.
  final String? userId;

  /// Validation errors from the API (ASP.NET Core Identity format).
  final Map<String, List<String>>? errors;

  /// Whether email confirmation is required.
  final bool requiresEmailConfirmation;

  /// Whether two-factor authentication is required.
  final bool requiresTwoFactor;

  /// Creates a successful authentication result.
  factory AuthResult.success({String? userId, String? message}) {
    return AuthResult(
      success: true,
      userId: userId,
      message: message,
    );
  }

  /// Creates a failed authentication result.
  factory AuthResult.failure(
    String message, {
    Map<String, List<String>>? errors,
  }) {
    return AuthResult(
      success: false,
      message: message,
      errors: errors,
    );
  }

  /// Creates result requiring email confirmation.
  factory AuthResult.requiresConfirmation({
    required String userId,
    String? message,
  }) {
    return AuthResult(
      success: false,
      userId: userId,
      message: message ?? 'Email confirmation required',
      requiresEmailConfirmation: true,
    );
  }

  /// Creates result requiring two-factor authentication.
  factory AuthResult.requiresTwoFactorAuth({String? message}) {
    return AuthResult(
      success: false,
      message: message ?? 'Two-factor authentication required',
      requiresTwoFactor: true,
    );
  }

  /// Gets formatted error messages from validation errors.
  String? get formattedErrors {
    if (errors == null || errors!.isEmpty) return null;

    final messages = <String>[];
    errors!.forEach((field, fieldErrors) {
      for (final error in fieldErrors) {
        messages.add('$field: $error');
      }
    });
    return messages.join('\n');
  }
}
