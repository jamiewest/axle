/// Request model for user login.
///
/// Matches ASP.NET Core Identity login endpoint requirements.
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.twoFactorCode,
    this.twoFactorRecoveryCode,
  });

  final String email;
  final String password;
  final String? twoFactorCode;
  final String? twoFactorRecoveryCode;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (twoFactorCode != null) 'twoFactorCode': twoFactorCode,
      if (twoFactorRecoveryCode != null)
        'twoFactorRecoveryCode': twoFactorRecoveryCode,
    };
  }
}
