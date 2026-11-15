class UpdateProfileCommand {
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;

  const UpdateProfileCommand({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
  });
}
