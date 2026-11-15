import 'profiles_error.dart';

class ProfilePhoto {
  static const List<String> supportedSchemes = ['http', 'https'];
  static const List<String> supportedExtensions = ['.jpg', '.jpeg', '.png'];

  final String url;

  ProfilePhoto(String url) : url = url.trim() {
    if (!isValid(this.url)) {
      throw const ProfilesError(ProfilesErrorCode.unsupportedPhotoFormat);
    }
  }

  static bool isValid(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty) return false;
    final path = uri.path.toLowerCase();
    return supportedSchemes.contains(uri.scheme.toLowerCase()) &&
        supportedExtensions.any(path.endsWith);
  }
}
