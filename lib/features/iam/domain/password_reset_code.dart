class PasswordResetCode {
  static const int length = 6;

  static final RegExp _pattern = RegExp(r'^\d{6}$');

  final String value;

  PasswordResetCode(String value) : value = value.trim() {
    if (!_pattern.hasMatch(this.value)) {
      throw ArgumentError.value(value, 'value', 'Invalid reset code');
    }
  }

  static bool isValid(String value) => _pattern.hasMatch(value.trim());
}
