import 'email_address.dart';
import 'phone_number.dart';
import 'profile_photo.dart';
import 'profiles_error.dart';
import 'update_profile_command.dart';
import 'update_profile_photo_command.dart';

class Profile {
  static const int nameMaxLength = 50;

  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;

  const Profile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials => [firstName, lastName]
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .map((name) => name[0])
      .join()
      .toUpperCase();

  bool get hasPhoto => photoUrl != null;

  static bool isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && trimmed.length <= nameMaxLength;
  }

  Profile update(UpdateProfileCommand command) {
    if (!isValidName(command.firstName) || !isValidName(command.lastName)) {
      throw const ProfilesError(ProfilesErrorCode.invalidName);
    }
    final phoneNumber = command.phoneNumber?.trim() ?? '';
    return Profile(
      id: id,
      userId: userId,
      firstName: command.firstName.trim(),
      lastName: command.lastName.trim(),
      email: EmailAddress(command.email).value,
      phoneNumber: phoneNumber.isEmpty ? null : PhoneNumber(phoneNumber).value,
      photoUrl: photoUrl,
    );
  }

  Profile changePhoto(UpdateProfilePhotoCommand command) => Profile(
    id: id,
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: phoneNumber,
    photoUrl: command.removesPhoto ? null : ProfilePhoto(command.photoUrl!).url,
  );
}
