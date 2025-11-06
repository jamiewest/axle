import 'package:axle/domain/models/auth_result.dart';

/// Interface for authentication operations.
///
/// This abstract class defines the contract for all authentication-related
/// operations. Implementations can be real (calling a backend API) or mock
/// (for development and testing).
abstract class SignInManager {
  /// Signs in a user with email and password.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Creates a new user account.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> createAccount({
    required String email,
    required String password,
    required String name,
  });

  /// Sends a password reset email to the specified address.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  });

  /// Resets the password using a verification code.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Confirms a user account with a verification code.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> confirmAccount({
    required String email,
    required String code,
  });

  /// Resends the account confirmation code.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  Future<AuthResult> resendConfirmationCode({
    required String email,
  });

  /// Checks if a user is currently signed in.
  Future<bool> isSignedIn();

  /// Gets the current user's ID, if signed in.
  Future<String?> getCurrentUserId();
}
