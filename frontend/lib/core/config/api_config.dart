/// Configuration for API endpoints and settings.
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  });

  /// Base URL for the API server.
  final String baseUrl;

  /// Request timeout duration.
  final Duration timeout;

  /// ASP.NET Core Identity endpoint paths.
  static const String registerPath = '/register';
  static const String loginPath = '/login';
  static const String refreshPath = '/refresh';
  static const String confirmEmailPath = '/confirmEmail';
  static const String resendConfirmationEmailPath = '/resendConfirmationEmail';
  static const String forgotPasswordPath = '/forgotPassword';
  static const String resetPasswordPath = '/resetPassword';
  static const String manage2faPath = '/manage/2fa';
  static const String manageInfoPath = '/manage/info';

  /// Default development configuration.
  factory ApiConfig.development() {
    return const ApiConfig(
      baseUrl: 'http://localhost:5000',
    );
  }

  /// Production configuration.
  factory ApiConfig.production(String baseUrl) {
    return ApiConfig(
      baseUrl: baseUrl,
      timeout: Duration(seconds: 30),
    );
  }
}
