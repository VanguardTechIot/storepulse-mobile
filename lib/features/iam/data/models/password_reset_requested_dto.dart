class PasswordResetRequestedDto {
  final DateTime expiresAt;

  const PasswordResetRequestedDto({required this.expiresAt});

  factory PasswordResetRequestedDto.fromJson(Map<String, dynamic> json) =>
      PasswordResetRequestedDto(
        expiresAt:
            DateTime.tryParse(json['expiresAt'] as String? ?? '')?.toLocal() ??
            DateTime.now().add(const Duration(minutes: 15)),
      );
}
