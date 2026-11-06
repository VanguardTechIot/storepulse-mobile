class User {
  final int id;
  final String email;
  final String role; // 'GALLERY_ADMINISTRATOR' | 'TENANT'
  final String status;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });

  bool get isGalleryAdmin => role == 'GALLERY_ADMINISTRATOR';
  bool get isTenant => role == 'TENANT';
}