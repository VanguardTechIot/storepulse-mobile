import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _roleKey = 'user_role';
  static const String _statusKey = 'user_status';
  static const String _galleryIdKey = 'active_gallery_id';

  Future<void> saveSession({
    required String token,
    required int userId,
    required String email,
    required String role,
    required String status,
    int galleryId = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await saveAccount(userId: userId, email: email, role: role, status: status);
    if (!prefs.containsKey(_galleryIdKey)) {
      await prefs.setInt(_galleryIdKey, galleryId);
    }
  }

  Future<void> saveAccount({
    required int userId,
    required String email,
    required String role,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_statusKey, status);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey) ?? 'GALLERY_ADMINISTRATOR';
  }

  Future<String?> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_statusKey);
  }

  Future<int> getGalleryId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_galleryIdKey) ?? 1;
  }

  Future<void> setGalleryId(int galleryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_galleryIdKey, galleryId);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_statusKey);
    await prefs.remove(_galleryIdKey);
  }
}
