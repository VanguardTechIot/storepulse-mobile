import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../domain/account_role.dart';
import '../domain/update_profile_photo_command.dart';
import 'profile_state.dart';
import 'profile_view_model.dart';
import 'profiles_error_messages.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_details_form.dart';
import 'widgets/profile_photo_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileViewModel>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: BlocConsumer<ProfileViewModel, ProfileState>(
          listenWhen: (_, current) =>
              current is ProfileReady &&
              (current.feedback != null || current.error != null),
          listener: (context, state) {
            final ready = state as ProfileReady;
            if (ready.error != null) {
              showAppSnackBar(context, ready.error!.message, error: true);
            } else if (ready.feedback != null) {
              showAppSnackBar(context, _feedbackMessage(ready.feedback!));
            }
          },
          builder: (context, state) => switch (state) {
            ProfileLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProfileLoadFailed(:final error) => _LoadFailure(
              message: error.message,
              onRetry: () => context.read<ProfileViewModel>().load(),
            ),
            ProfileReady() => _ProfileContent(state: state),
          },
        ),
      ),
    );
  }

  static String _feedbackMessage(ProfileFeedback feedback) =>
      switch (feedback) {
        ProfileFeedback.detailsSaved => 'Tus datos se actualizaron.',
        ProfileFeedback.photoUpdated => 'Tu foto de perfil se actualizó.',
        ProfileFeedback.photoRemoved => 'Se quitó tu foto de perfil.',
      };
}

class _ProfileContent extends StatelessWidget {
  final ProfileReady state;

  const _ProfileContent({required this.state});

  Future<void> _changePhoto(BuildContext context) async {
    final viewModel = context.read<ProfileViewModel>();
    final url = await showProfilePhotoDialog(
      context,
      currentUrl: state.profile.photoUrl,
    );
    if (url == null) return;
    viewModel.updatePhoto(UpdateProfilePhotoCommand(photoUrl: url));
  }

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isAdministrator =
        state.owner.role == AccountRole.galleryAdministrator;

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileViewModel>().load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.saving) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Center(child: ProfileAvatar(profile: profile)),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Chip(
              avatar: Icon(
                isAdministrator ? Icons.domain : Icons.storefront,
                size: 18,
              ),
              label: Text(
                isAdministrator
                    ? 'Administrador de Galería'
                    : 'Inquilino de Local Comercial',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: state.saving ? null : () => _changePhoto(context),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(profile.hasPhoto ? 'Cambiar foto' : 'Agregar foto'),
              ),
              if (profile.hasPhoto)
                TextButton.icon(
                  onPressed: state.saving
                      ? null
                      : () => context.read<ProfileViewModel>().updatePhoto(
                          const UpdateProfilePhotoCommand.remove(),
                        ),
                  icon: const Icon(Icons.hide_image_outlined),
                  label: const Text('Quitar foto'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ProfileDetailsForm(
                profile: profile,
                saving: state.saving,
                onSubmit: context.read<ProfileViewModel>().updateDetails,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadFailure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
