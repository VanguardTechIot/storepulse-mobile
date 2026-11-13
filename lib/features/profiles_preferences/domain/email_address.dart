import 'profiles_error.dart';

class EmailAddress {
  static final RegExp _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final String value;

  EmailAddress(String value) : value = value.trim().toLowerCase() {
    if (!_pattern.hasMatch(this.value)) {
      throw const ProfilesError(ProfilesErrorCode.invalidEmail);
    }
  }

  static bool isValid(String value) =>
      _pattern.hasMatch(value.trim().toLowerCase());
}
