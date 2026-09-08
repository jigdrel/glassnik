

import 'package:flutter/foundation.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    this.profileImageBytes,
  });

  final String displayName;
  final String username;
  final String bio;

  final int followers;
  final int following;
  final int posts;

  final Uint8List? profileImageBytes;

  UserProfile copyWith({
    String? displayName,
    String? username,
    String? bio,
    int? followers,
    int? following,
    int? posts,
    Uint8List? profileImageBytes,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
      profileImageBytes:
          profileImageBytes ?? this.profileImageBytes,
    );
  }
}

class ProfileStore {
  static final ValueNotifier<UserProfile> profile =
      ValueNotifier<UserProfile>(
    const UserProfile(
      displayName: 'Glassnik User',
      username: '@glassnik',
      bio: 'Creating and sharing moments on Glassnik 🎥',
      followers: 124,
      following: 42,
      posts: 3,
    ),
  );

  static void updateProfile({
    required String displayName,
    required String username,
    required String bio,
  }) {
    profile.value = profile.value.copyWith(
      displayName: displayName,
      username: username,
      bio: bio,
    );
  }

  static void updateProfileImage(
    Uint8List imageBytes,
  ) {
    profile.value = profile.value.copyWith(
      profileImageBytes: imageBytes,
    );
  }
}
