import 'profile.dart';

abstract class ProfilesRepository {
  Future<Profile> getProfile(int userId);

  Future<Profile> updateProfile(Profile profile);
}
