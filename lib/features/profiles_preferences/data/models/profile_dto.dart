import '../../domain/profile.dart';

class ProfileDto {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;

  const ProfileDto({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) => ProfileDto(
    id: (json['id'] as num?)?.toInt() ?? 0,
    userId: (json['userId'] as num?)?.toInt() ?? 0,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phoneNumber: _optional(json['phoneNumber']),
    photoUrl: _optional(json['photoUrl']),
  );

  Profile toDomain() => Profile(
    id: id,
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: phoneNumber,
    photoUrl: photoUrl,
  );

  static String? _optional(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
}
