/// Request model for email confirmation.
class ConfirmEmailRequest {
  const ConfirmEmailRequest({
    required this.userId,
    required this.code,
    this.changedEmail,
  });

  final String userId;
  final String code;
  final String? changedEmail;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'code': code,
      if (changedEmail != null) 'changedEmail': changedEmail,
    };
  }
}
