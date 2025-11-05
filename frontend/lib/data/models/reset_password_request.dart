/// Request model for password reset.
class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.resetCode,
    required this.newPassword,
  });

  final String email;
  final String resetCode;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'resetCode': resetCode,
      'newPassword': newPassword,
    };
  }
}
