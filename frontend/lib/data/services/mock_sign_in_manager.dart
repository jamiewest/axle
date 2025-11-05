import 'dart:developer' as developer;

import 'package:axle/domain/models/auth_result.dart';
import 'package:axle/domain/services/sign_in_manager.dart';

/// Mock implementation of [SignInManager] for development and testing.
///
/// This implementation simulates authentication operations with configurable
/// delays and responses. It maintains simple in-memory state for testing
/// authentication flows.
class MockSignInManager implements SignInManager {
  MockSignInManager({
    this.simulateDelay = const Duration(milliseconds: 500),
    this.shouldSucceed = true,
  });

  /// Duration to wait before returning results (simulates network delay).
  final Duration simulateDelay;

  /// Whether operations should succeed by default.
  final bool shouldSucceed;

  String? _currentUserId;
  final Set<String> _registeredEmails = {'test@example.com'};
  final Map<String, String> _verificationCodes = {};

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    developer.log('Sign in attempt for: $email', name: 'MockSignInManager');
    await Future.delayed(simulateDelay);

    if (!shouldSucceed) {
      return AuthResult.failure('Mock: Sign in failed');
    }

    if (!_registeredEmails.contains(email)) {
      return AuthResult.failure('Account not found');
    }

    if (password.length < 8) {
      return AuthResult.failure('Invalid password');
    }

    _currentUserId = _generateUserId(email);
    return AuthResult.success(
      userId: _currentUserId,
      message: 'Successfully signed in',
    );
  }

  @override
  Future<void> signOut() async {
    developer.log('Signing out user: $_currentUserId', name: 'MockSignInManager');
    await Future.delayed(simulateDelay);
    _currentUserId = null;
  }

  @override
  Future<AuthResult> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    developer.log('Create account for: $email', name: 'MockSignInManager');
    await Future.delayed(simulateDelay);

    if (!shouldSucceed) {
      return AuthResult.failure('Mock: Account creation failed');
    }

    if (_registeredEmails.contains(email)) {
      return AuthResult.failure('Email already registered');
    }

    if (password.length < 8) {
      return AuthResult.failure('Password must be at least 8 characters');
    }

    if (name.isEmpty) {
      return AuthResult.failure('Name is required');
    }

    _registeredEmails.add(email);
    final code = _generateCode();
    _verificationCodes[email] = code;

    developer.log(
      'Mock verification code for $email: $code',
      name: 'MockSignInManager',
    );

    return AuthResult.success(
      message: 'Account created. Check logs for verification code.',
    );
  }

  @override
  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    developer.log(
      'Password reset requested for: $email',
      name: 'MockSignInManager',
    );
    await Future.delayed(simulateDelay);

    if (!shouldSucceed) {
      return AuthResult.failure('Mock: Password reset failed');
    }

    if (!_registeredEmails.contains(email)) {
      return AuthResult.success(
        message: 'If the email exists, a reset code has been sent',
      );
    }

    final code = _generateCode();
    _verificationCodes[email] = code;

    developer.log(
      'Mock reset code for $email: $code',
      name: 'MockSignInManager',
    );

    return AuthResult.success(
      message: 'Password reset email sent. Check logs for code.',
    );
  }

  @override
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    developer.log(
      'Password reset attempt for: $email',
      name: 'MockSignInManager',
    );
    await Future.delayed(simulateDelay);

    if (!shouldSucceed) {
      return AuthResult.failure('Mock: Password reset failed');
    }

    if (_verificationCodes[email] != code) {
      return AuthResult.failure('Invalid or expired verification code');
    }

    if (newPassword.length < 8) {
      return AuthResult.failure('Password must be at least 8 characters');
    }

    _verificationCodes.remove(email);
    return AuthResult.success(message: 'Password successfully reset');
  }

  @override
  Future<AuthResult> confirmAccount({
    required String email,
    required String code,
  }) async {
    developer.log(
      'Account confirmation for: $email',
      name: 'MockSignInManager',
    );
    await Future.delayed(simulateDelay);

    if (!shouldSucceed) {
      return AuthResult.failure('Mock: Account confirmation failed');
    }

    if (_verificationCodes[email] != code) {
      return AuthResult.failure('Invalid or expired verification code');
    }

    _verificationCodes.remove(email);
    return AuthResult.success(message: 'Account successfully confirmed');
  }

  @override
  Future<AuthResult> resendConfirmationCode({
    required String email,
  }) async {
    developer.log(
      'Resend confirmation code for: $email',
      name: 'MockSignInManager',
    );
    await Future.delayed(simulateDelay);

    if (!shouldSucceed) {
      return AuthResult.failure('Mock: Resend code failed');
    }

    if (!_registeredEmails.contains(email)) {
      return AuthResult.failure('Account not found');
    }

    final code = _generateCode();
    _verificationCodes[email] = code;

    developer.log(
      'Mock new verification code for $email: $code',
      name: 'MockSignInManager',
    );

    return AuthResult.success(
      message: 'Verification code resent. Check logs for code.',
    );
  }

  @override
  Future<bool> isSignedIn() async {
    return _currentUserId != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _currentUserId;
  }

  String _generateUserId(String email) {
    return 'user_${email.hashCode.abs()}';
  }

  String _generateCode() {
    return (100000 + DateTime.now().microsecond % 900000).toString();
  }
}
