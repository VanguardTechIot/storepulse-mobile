import 'package:flutter/material.dart';
import '../../domain/profile.dart';

class ProfileAvatar extends StatelessWidget {
  final Profile profile;
  final double radius;

  const ProfileAvatar({super.key, required this.profile, this.radius = 48});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final photoUrl = profile.photoUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      foregroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
      onForegroundImageError: photoUrl == null ? null : (_, _) {},
      child: profile.initials.isEmpty
          ? Icon(Icons.person, size: radius)
          : Text(
              profile.initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
