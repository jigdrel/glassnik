import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  // Temporary empty profile while Firebase data is loading.
  static final ValueNotifier<UserProfile> profile =
      ValueNotifier<UserProfile>(
    const UserProfile(
      displayName: 'Loading...',
      username: '',
      bio: '',
      followers: 0,
      following: 0,
      posts: 0,
    ),
  );

  // -------------------------------------------------------
  // LOAD CURRENT USER PROFILE FROM FIRESTORE
  // -------------------------------------------------------

  static Future<void> loadCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      profile.value = const UserProfile(
        displayName: 'Guest',
        username: '',
        bio: '',
        followers: 0,
        following: 0,
        posts: 0,
      );

      return;
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (document.exists) {
        final data = document.data()!;

        String username =
            (data['username'] ?? '').toString().trim();

        if (username.isNotEmpty &&
            !username.startsWith('@')) {
          username = '@$username';
        }

        profile.value = UserProfile(
          displayName:
              (data['displayName'] ??
                      user.displayName ??
                      'Glassnik User')
                  .toString(),
          username: username,
          bio: (data['bio'] ?? '').toString(),
          followers: _toInt(data['followers']),
          following: _toInt(data['following']),
          posts: _toInt(data['posts']),
        );
      } else {
        // Older Firebase accounts may not have a
        // Firestore profile document yet.
        profile.value = UserProfile(
          displayName:
              user.displayName ?? 'Glassnik User',
          username: '',
          bio: '',
          followers: 0,
          following: 0,
          posts: 0,
        );
      }
    } catch (error) {
      debugPrint(
        'Error loading user profile: $error',
      );

      profile.value = UserProfile(
        displayName:
            user.displayName ?? 'Glassnik User',
        username: '',
        bio: '',
        followers: 0,
        following: 0,
        posts: 0,
      );
    }
  }

  // -------------------------------------------------------
  // UPDATE PROFILE
  // -------------------------------------------------------

  static Future<void> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    final cleanUsername =
        username.replaceFirst('@', '').trim().toLowerCase();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'displayName': displayName.trim(),
      'username': cleanUsername,
      'email': user.email,
      'bio': bio.trim(),
    }, SetOptions(merge: true));

    await user.updateDisplayName(
      displayName.trim(),
    );

    profile.value = profile.value.copyWith(
      displayName: displayName.trim(),
      username: cleanUsername.isEmpty
          ? ''
          : '@$cleanUsername',
      bio: bio.trim(),
    );
  }

  // -------------------------------------------------------
  // UPDATE LOCAL PROFILE IMAGE
  // -------------------------------------------------------

  static void updateProfileImage(
    Uint8List imageBytes,
  ) {
    profile.value = profile.value.copyWith(
      profileImageBytes: imageBytes,
    );
  }

  // -------------------------------------------------------
  // HELPER
  // -------------------------------------------------------

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }
}