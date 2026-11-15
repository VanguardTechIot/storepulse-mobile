import '../domain/profile.dart';
import '../domain/profile_owner.dart';
import '../domain/profiles_error.dart';

enum ProfileFeedback { detailsSaved, photoUpdated, photoRemoved }

sealed class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadFailed extends ProfileState {
  final ProfilesErrorCode error;
  ProfileLoadFailed(this.error);
}

class ProfileReady extends ProfileState {
  final ProfileOwner owner;
  final Profile profile;
  final bool saving;
  final ProfileFeedback? feedback;
  final ProfilesErrorCode? error;

  ProfileReady({
    required this.owner,
    required this.profile,
    this.saving = false,
    this.feedback,
    this.error,
  });
}
