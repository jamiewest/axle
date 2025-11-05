/// Request model for resending confirmation email.
class ResendConfirmationRequest {
  const ResendConfirmationRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}
