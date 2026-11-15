enum UserStatus {
  active('ACTIVE'),
  inactive('INACTIVE');

  final String value;

  const UserStatus(this.value);

  static UserStatus fromValue(String? value) => UserStatus.values.firstWhere(
    (status) => status.value == value,
    orElse: () => UserStatus.inactive,
  );
}
