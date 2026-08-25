import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'profile_stats.dart';
import 'user_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.username,
    required this.bio,
    required this.posts,
    required this.followers,
    required this.following,
    this.imageUrl,
    this.onEditProfile,
  });

  final String username;
  final String bio;
  final int posts;
  final int followers;
  final int following;
  final String? imageUrl;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(imageUrl: imageUrl, radius: 48),

          const SizedBox(height: 12),

          Text(
            username,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(bio, style: textTheme.bodyMedium, textAlign: TextAlign.center),

          const SizedBox(height: 20),

          ProfileStats(
            posts: posts,
            followers: followers,
            following: following,
          ),

          const SizedBox(height: 20),

          CustomButton(
            text: 'Edit Profile',
            icon: Icons.edit_outlined,
            onPressed: onEditProfile,
          ),
        ],
      ),
    );
  }
}
