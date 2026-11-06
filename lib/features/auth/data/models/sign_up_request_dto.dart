class SignUpRequestDto {
  final String fullName;
  final String email;
  final String password;

  const SignUpRequestDto({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
      };
}