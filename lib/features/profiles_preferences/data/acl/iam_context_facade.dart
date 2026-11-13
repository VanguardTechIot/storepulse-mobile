import '../../../iam/domain/iam_repository.dart';
import '../../../iam/domain/role.dart';
import '../../domain/account_role.dart';
import '../../domain/profile_owner.dart';

class IamContextFacade {
  final IamRepository _iamRepository;

  IamContextFacade(this._iamRepository);

  Future<ProfileOwner?> currentOwner() async {
    final user = await _iamRepository.currentUser();
    if (user == null) return null;
    return ProfileOwner(
      userId: user.id,
      role: switch (user.role) {
        Role.galleryAdministrator => AccountRole.galleryAdministrator,
        Role.tenant => AccountRole.tenant,
      },
    );
  }

  Future<void> syncAccountEmail(String email) =>
      _iamRepository.syncAccountEmail(email);
}
