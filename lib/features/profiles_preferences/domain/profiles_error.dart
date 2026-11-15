enum ProfilesErrorCode {
  invalidName('invalid_name'),
  invalidEmail('invalid_email'),
  invalidPhoneNumber('invalid_phone_number'),
  unsupportedPhotoFormat('unsupported_photo_format'),
  emailAlreadyRegistered('email_already_registered'),
  profileNotFound('profile_not_found'),
  accessDenied('access_denied'),
  unreachable('unreachable'),
  unexpected('unexpected');

  final String value;

  const ProfilesErrorCode(this.value);

  static ProfilesErrorCode fromValue(String? value) =>
      ProfilesErrorCode.values.firstWhere(
        (code) => code.value == value,
        orElse: () => ProfilesErrorCode.unexpected,
      );
}

class ProfilesError implements Exception {
  final ProfilesErrorCode code;

  const ProfilesError(this.code);

  @override
  String toString() => 'ProfilesError(${code.value})';
}
