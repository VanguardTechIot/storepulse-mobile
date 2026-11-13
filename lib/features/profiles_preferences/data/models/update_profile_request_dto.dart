import '../../domain/profile.dart';

class UpdateProfileRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;

  const UpdateProfileRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  factory UpdateProfileRequestDto.fromDomain(Profile profile) =>
      UpdateProfileRequestDto(
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
        photoUrl: profile.photoUrl,
      );

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
  };
}
