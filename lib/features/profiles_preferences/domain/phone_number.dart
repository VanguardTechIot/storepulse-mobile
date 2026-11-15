import 'profiles_error.dart';

class PhoneNumber {
  static const int minDigits = 7;
  static const int maxDigits = 15;

  static final RegExp _pattern = RegExp(r'^\+?[\d\s()-]+$');

  final String value;

  PhoneNumber(String value) : value = _normalize(value) {
    if (!isValid(this.value)) {
      throw const ProfilesError(ProfilesErrorCode.invalidPhoneNumber);
    }
  }

  static bool isValid(String value) {
    final normalized = _normalize(value);
    final digits = normalized.replaceAll(RegExp(r'\D'), '').length;
    return _pattern.hasMatch(normalized) &&
        digits >= minDigits &&
        digits <= maxDigits;
  }

  static String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
