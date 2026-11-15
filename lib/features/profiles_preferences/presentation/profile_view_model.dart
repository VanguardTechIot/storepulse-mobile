import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/acl/iam_context_facade.dart';
import '../domain/profile.dart';
import '../domain/profiles_error.dart';
import '../domain/profiles_repository.dart';
import '../domain/update_profile_command.dart';
import '../domain/update_profile_photo_command.dart';
import 'profile_state.dart';

class ProfileViewModel extends Cubit<ProfileState> {
  final ProfilesRepository _profilesRepository;
  final IamContextFacade _iamContext;

  ProfileViewModel(this._profilesRepository, this._iamContext)
    : super(ProfileLoading());

  Future<void> load() async {
    emit(ProfileLoading());
    try {
      final owner = await _iamContext.currentOwner();
      if (owner == null) {
        throw const ProfilesError(ProfilesErrorCode.accessDenied);
      }
      final profile = await _profilesRepository.getProfile(owner.userId);
      emit(ProfileReady(owner: owner, profile: profile));
    } on ProfilesError catch (error) {
      emit(ProfileLoadFailed(error.code));
    } catch (_) {
      emit(ProfileLoadFailed(ProfilesErrorCode.unexpected));
    }
  }

  Future<void> updateDetails(UpdateProfileCommand command) =>
      _save((profile) => profile.update(command), ProfileFeedback.detailsSaved);

  Future<void> updatePhoto(UpdateProfilePhotoCommand command) => _save(
    (profile) => profile.changePhoto(command),
    command.removesPhoto
        ? ProfileFeedback.photoRemoved
        : ProfileFeedback.photoUpdated,
  );

  Future<void> _save(
    Profile Function(Profile profile) change,
    ProfileFeedback feedback,
  ) async {
    final current = state;
    if (current is! ProfileReady || current.saving) return;
    emit(
      ProfileReady(
        owner: current.owner,
        profile: current.profile,
        saving: true,
      ),
    );
    try {
      final saved = await _profilesRepository.updateProfile(
        change(current.profile),
      );
      if (saved.email != current.profile.email) {
        await _iamContext.syncAccountEmail(saved.email);
      }
      emit(
        ProfileReady(owner: current.owner, profile: saved, feedback: feedback),
      );
    } on ProfilesError catch (error) {
      emit(
        ProfileReady(
          owner: current.owner,
          profile: current.profile,
          error: error.code,
        ),
      );
    } catch (_) {
      emit(
        ProfileReady(
          owner: current.owner,
          profile: current.profile,
          error: ProfilesErrorCode.unexpected,
        ),
      );
    }
  }
}
