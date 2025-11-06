/// Response model from ASP.NET Core Identity login endpoint.
class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final String tokenType;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      expiresIn: json['expiresIn'] as int,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }
}
