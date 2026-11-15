class Email {
  static final RegExp _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final String address;

  Email(String address) : address = normalize(address) {
    if (!_pattern.hasMatch(this.address)) {
      throw ArgumentError.value(address, 'address', 'Invalid email');
    }
  }

  static String normalize(String address) => address.trim().toLowerCase();

  static bool isValid(String address) => _pattern.hasMatch(normalize(address));
}
