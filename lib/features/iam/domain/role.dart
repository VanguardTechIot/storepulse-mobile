enum Role {
  galleryAdministrator('GALLERY_ADMINISTRATOR'),
  tenant('TENANT');

  final String value;

  const Role(this.value);

  static Role fromValue(String? value) => Role.values.firstWhere(
    (role) => role.value == value,
    orElse: () => Role.tenant,
  );
}
