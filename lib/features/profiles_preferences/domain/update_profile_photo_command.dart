class UpdateProfilePhotoCommand {
  final String? photoUrl;

  const UpdateProfilePhotoCommand({this.photoUrl});

  const UpdateProfilePhotoCommand.remove() : photoUrl = null;

  bool get removesPhoto => photoUrl == null || photoUrl!.trim().isEmpty;
}
