class ResetPasswordRequestDto {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordRequestDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'code': code,
    'newPassword': newPassword,
  };
}
