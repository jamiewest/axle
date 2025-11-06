import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:axle/core/config/api_config.dart';
import 'package:axle/data/models/confirm_email_request.dart';
import 'package:axle/data/models/forgot_password_request.dart';
import 'package:axle/data/models/login_request.dart';
import 'package:axle/data/models/login_response.dart';
import 'package:axle/data/models/register_request.dart';
import 'package:axle/data/models/resend_confirmation_request.dart';
import 'package:axle/data/models/reset_password_request.dart';
import 'package:axle/data/services/token_storage_service.dart';
import 'package:axle/domain/models/auth_result.dart';
import 'package:axle/domain/services/sign_in_manager.dart';

/// ASP.NET Core Identity implementation of [SignInManager].
///
/// Integrates with ASP.NET Core Identity Web API endpoints for
/// authentication operations.
class AspNetCoreIdentitySignInManager implements SignInManager {
  AspNetCoreIdentitySignInManager({
    required ApiConfig apiConfig,
    TokenStorageService? tokenStorage,
    http.Client? httpClient,
  })  : _apiConfig = apiConfig,
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _httpClient = httpClient ?? http.Client();

  final ApiConfig _apiConfig;
  final TokenStorageService _tokenStorage;
  final http.Client _httpClient;

  String? _cachedUserId;

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _post(
        ApiConfig.loginPath,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        final expiresAt = DateTime.now().add(
          Duration(seconds: loginResponse.expiresIn),
        );

        await _tokenStorage.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          expiresAt: expiresAt,
        );

        final userId = await _fetchUserId();
        _cachedUserId = userId;

        developer.log('Sign in successful', name: 'AspNetCoreIdentity');
        return AuthResult.success(userId: userId);
      } else if (response.statusCode == 401) {
        return AuthResult.failure('Invalid email or password');
      } else {
        final errorData = _parseErrorResponse(response);
        return AuthResult.failure(
          errorData['message'] ?? 'Sign in failed',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Sign in error',
        name: 'AspNetCoreIdentity',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clearTokens();
    _cachedUserId = null;
    developer.log('Sign out successful', name: 'AspNetCoreIdentity');
  }

  @override
  Future<AuthResult> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        userName: email,
      );

      final response = await _post(
        ApiConfig.registerPath,
        body: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log('Account created', name: 'AspNetCoreIdentity');

        // Extract userId from response
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        final userId = responseBody['userId'] as String?;

        return AuthResult.success(
          message: 'Account created. Please check your email to confirm.',
          userId: userId,
        );
      } else {
        final errorData = _parseErrorResponse(response);
        return AuthResult.failure(
          errorData['message'] ?? 'Account creation failed',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Create account error',
        name: 'AspNetCoreIdentity',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _post(
        ApiConfig.forgotPasswordPath,
        body: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log('Password reset email sent', name: 'AspNetCoreIdentity');
        return AuthResult.success(
          message: 'If the email exists, a reset code has been sent.',
        );
      } else {
        final errorData = _parseErrorResponse(response);
        return AuthResult.failure(
          errorData['message'] ?? 'Failed to send reset email',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Send password reset error',
        name: 'AspNetCoreIdentity',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        email: email,
        resetCode: code,
        newPassword: newPassword,
      );

      final response = await _post(
        ApiConfig.resetPasswordPath,
        body: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log('Password reset successful', name: 'AspNetCoreIdentity');
        return AuthResult.success(message: 'Password successfully reset');
      } else {
        final errorData = _parseErrorResponse(response);
        return AuthResult.failure(
          errorData['message'] ?? 'Password reset failed',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Reset password error',
        name: 'AspNetCoreIdentity',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> confirmAccount({
    required String email,
    required String code,
  }) async {
    try {
      final userId = email;
      final request = ConfirmEmailRequest(userId: userId, code: code);

      final response = await _get(
        ApiConfig.confirmEmailPath,
        queryParams: {
          'userId': request.userId,
          'code': request.code,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log('Account confirmed', name: 'AspNetCoreIdentity');
        return AuthResult.success(message: 'Account successfully confirmed');
      } else {
        final errorData = _parseErrorResponse(response);
        return AuthResult.failure(
          errorData['message'] ?? 'Account confirmation failed',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Confirm account error',
        name: 'AspNetCoreIdentity',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> resendConfirmationCode({
    required String email,
  }) async {
    try {
      final request = ResendConfirmationRequest(email: email);
      final response = await _post(
        ApiConfig.resendConfirmationEmailPath,
        body: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log(
          'Confirmation email resent',
          name: 'AspNetCoreIdentity',
        );
        return AuthResult.success(
          message: 'Verification code resent. Check your email.',
        );
      } else {
        final errorData = _parseErrorResponse(response);
        return AuthResult.failure(
          errorData['message'] ?? 'Failed to resend confirmation',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Resend confirmation error',
        name: 'AspNetCoreIdentity',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Development-only: Get the last verification code sent to an email.
  /// Returns null if not in development mode or if no code is available.
  Future<String?> getDevVerificationCode(String email) async {
    try {
      final response = await _get(
        ApiConfig.devVerificationCodePath,
        queryParams: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final code = data['verificationCode'] as String?;
        developer.log(
          'Dev verification code retrieved',
          name: 'AspNetCoreIdentity',
        );
        return code;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get dev verification code',
        name: 'AspNetCoreIdentity',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  @override
  Future<bool> isSignedIn() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) return false;

    final isExpired = await _tokenStorage.isTokenExpired();
    if (isExpired) {
      final refreshed = await _refreshAccessToken();
      return refreshed;
    }

    return true;
  }

  @override
  Future<String?> getCurrentUserId() async {
    if (_cachedUserId != null) return _cachedUserId;

    final isSignedIn = await this.isSignedIn();
    if (!isSignedIn) return null;

    _cachedUserId = await _fetchUserId();
    return _cachedUserId;
  }

  Future<String?> _fetchUserId() async {
    try {
      final response = await _get(ApiConfig.manageInfoPath);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userId = data['email'] as String?;
        if (userId != null) {
          await _tokenStorage.saveTokens(
            accessToken: (await _tokenStorage.getAccessToken())!,
            refreshToken: (await _tokenStorage.getRefreshToken())!,
            expiresAt: (await _tokenStorage.getTokenExpiry())!,
            userId: userId,
          );
        }
        return userId;
      }
    } catch (e) {
      developer.log('Failed to fetch user ID', name: 'AspNetCoreIdentity');
    }
    return _tokenStorage.getUserId();
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _post(
        ApiConfig.refreshPath,
        body: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        final expiresAt = DateTime.now().add(
          Duration(seconds: loginResponse.expiresIn),
        );

        final userId = await _tokenStorage.getUserId();
        await _tokenStorage.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          expiresAt: expiresAt,
          userId: userId,
        );

        developer.log('Token refreshed', name: 'AspNetCoreIdentity');
        return true;
      }
    } catch (e) {
      developer.log('Token refresh failed', name: 'AspNetCoreIdentity');
    }

    await _tokenStorage.clearTokens();
    return false;
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}$path');
    final headers = await _buildHeaders();

    return _httpClient
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_apiConfig.timeout);
  }

  Future<http.Response> _get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}$path').replace(
      queryParameters: queryParams,
    );
    final headers = await _buildHeaders();

    return _httpClient.get(uri, headers: headers).timeout(_apiConfig.timeout);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  Map<String, dynamic> _parseErrorResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body.containsKey('errors')) {
        final errorsValue = body['errors'];

        // Handle errors as an array (ASP.NET Core Identity format)
        if (errorsValue is List) {
          final errorMessages = errorsValue.cast<String>();
          return {
            'message': errorMessages.join('\n'),
            'errors': <String, List<String>>{'general': errorMessages},
          };
        }

        // Handle errors as a map (validation errors format)
        if (errorsValue is Map<String, dynamic>) {
          final formattedErrors = <String, List<String>>{};

          errorsValue.forEach((key, value) {
            if (value is List) {
              formattedErrors[key] = value.cast<String>();
            } else if (value is String) {
              formattedErrors[key] = [value];
            }
          });

          return {
            'message': body['title'] as String? ?? 'Validation failed',
            'errors': formattedErrors,
          };
        }
      }

      if (body.containsKey('title')) {
        return {'message': body['title'] as String};
      }

      if (body.containsKey('message')) {
        return {'message': body['message'] as String};
      }
    } catch (e) {
      developer.log('Error parsing response', name: 'AspNetCoreIdentity');
    }

    return {'message': 'An error occurred (${response.statusCode})'};
  }
}
