class PasswordRecovery {
  final String email;
  final DateTime expiresAt;

  const PasswordRecovery({required this.email, required this.expiresAt});

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);
}
