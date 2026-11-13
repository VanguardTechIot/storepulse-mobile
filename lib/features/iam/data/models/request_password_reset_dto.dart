class RequestPasswordResetDto {
  final String email;

  const RequestPasswordResetDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
