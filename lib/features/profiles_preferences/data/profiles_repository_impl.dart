import '../domain/profile.dart';
import '../domain/profiles_repository.dart';
import 'models/update_profile_request_dto.dart';
import 'profiles_service.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  final ProfilesService _profilesService;

  ProfilesRepositoryImpl(this._profilesService);

  @override
  Future<Profile> getProfile(int userId) async =>
      (await _profilesService.fetchProfile(userId)).toDomain();

  @override
  Future<Profile> updateProfile(Profile profile) async =>
      (await _profilesService.updateProfile(
        profile.userId,
        UpdateProfileRequestDto.fromDomain(profile),
      )).toDomain();
}
