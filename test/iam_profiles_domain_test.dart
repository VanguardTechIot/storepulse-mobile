import 'package:flutter_test/flutter_test.dart';
import 'package:storepulse_mobile/features/iam/domain/email.dart';
import 'package:storepulse_mobile/features/iam/domain/password_policy.dart';
import 'package:storepulse_mobile/features/iam/domain/password_reset_code.dart';
import 'package:storepulse_mobile/features/iam/domain/role.dart';
import 'package:storepulse_mobile/features/profiles_preferences/domain/phone_number.dart';
import 'package:storepulse_mobile/features/profiles_preferences/domain/profile.dart';
import 'package:storepulse_mobile/features/profiles_preferences/domain/profile_photo.dart';
import 'package:storepulse_mobile/features/profiles_preferences/domain/profiles_error.dart';
import 'package:storepulse_mobile/features/profiles_preferences/domain/update_profile_command.dart';
import 'package:storepulse_mobile/features/profiles_preferences/domain/update_profile_photo_command.dart';

void main() {
  group('IAM domain', () {
    test('password policy requires eight characters and a number', () {
      expect(PasswordPolicy.isSatisfiedBy('abcdefgh'), isFalse);
      expect(PasswordPolicy.isSatisfiedBy('abc1'), isFalse);
      expect(PasswordPolicy.isSatisfiedBy('abcdefg1'), isTrue);
      expect(PasswordPolicy.isSatisfiedBy('a1' * 37), isFalse);
    });

    test('email is normalized and validated', () {
      expect(Email('  Admin@StorePulse.PE ').address, 'admin@storepulse.pe');
      expect(Email.isValid('admin@storepulse'), isFalse);
    });

    test('reset code has exactly six digits', () {
      expect(PasswordResetCode.isValid(' 123456 '), isTrue);
      expect(PasswordResetCode.isValid('12345'), isFalse);
      expect(PasswordResetCode.isValid('12a456'), isFalse);
    });

    test('unknown roles fall back to tenant', () {
      expect(
        Role.fromValue('GALLERY_ADMINISTRATOR'),
        Role.galleryAdministrator,
      );
      expect(Role.fromValue('OTHER'), Role.tenant);
    });
  });

  group('Profiles domain', () {
    const profile = Profile(
      id: 1,
      userId: 7,
      firstName: 'Ana',
      lastName: 'Torres',
      email: 'ana@storepulse.pe',
    );

    test('update normalizes the details', () {
      final updated = profile.update(
        const UpdateProfileCommand(
          firstName: ' Ana María ',
          lastName: 'Torres',
          email: 'ANA@StorePulse.pe',
          phoneNumber: ' +51   987 654 321 ',
        ),
      );
      expect(updated.firstName, 'Ana María');
      expect(updated.email, 'ana@storepulse.pe');
      expect(updated.phoneNumber, '+51 987 654 321');
      expect(updated.initials, 'AT');
    });

    test('update rejects an invalid phone number', () {
      expect(
        () => profile.update(
          const UpdateProfileCommand(
            firstName: 'Ana',
            lastName: 'Torres',
            email: 'ana@storepulse.pe',
            phoneNumber: '12-34',
          ),
        ),
        throwsA(
          isA<ProfilesError>().having(
            (error) => error.code,
            'code',
            ProfilesErrorCode.invalidPhoneNumber,
          ),
        ),
      );
      expect(PhoneNumber.isValid('(01) 555-1234'), isTrue);
    });

    test('photo accepts only http(s) JPG or PNG links', () {
      expect(ProfilePhoto.isValid('https://cdn.example.com/a.PNG'), isTrue);
      expect(ProfilePhoto.isValid('ftp://cdn.example.com/a.png'), isFalse);
      expect(ProfilePhoto.isValid('https://cdn.example.com/a.gif'), isFalse);
      final withPhoto = profile.changePhoto(
        const UpdateProfilePhotoCommand(
          photoUrl: 'https://cdn.example.com/a.jpg',
        ),
      );
      expect(withPhoto.hasPhoto, isTrue);
      expect(
        withPhoto
            .changePhoto(const UpdateProfilePhotoCommand.remove())
            .hasPhoto,
        isFalse,
      );
    });
  });
}
