/// Request model for user registration.
///
/// Matches ASP.NET Core Identity registration endpoint requirements.
class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    this.userName,
  });

  final String email;
  final String password;
  final String? userName;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (userName != null) 'userName': userName,
    };
  }
}
