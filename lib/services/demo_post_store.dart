import 'package:flutter/foundation.dart';

import '../models/demo_video_post.dart';

class DemoPostStore {
  DemoPostStore._();

  static final ValueNotifier<List<DemoVideoPost>>
  posts = ValueNotifier<List<DemoVideoPost>>([
    const DemoVideoPost(
      id: 'sample-1',
      username: '@glassnik',
      caption: 'Welcome to Glassnik 👓',
      videoPath:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      isPickedFile: false,
      likes: 124,
      comments: [],
    ),
  ]);

  static void addPost(DemoVideoPost post) {
    posts.value = [
      _withLegacyOwnership(post.copyWith(hashtags: post.allHashtags)),
      ...posts.value,
    ];
  }

  static void addComment({required String postId, required String comment}) {
    final trimmedComment = comment.trim();

    if (trimmedComment.isEmpty) {
      return;
    }

    posts.value = posts.value.map((post) {
      if (post.id != postId) {
        return post;
      }

      return post.copyWith(comments: [...post.comments, trimmedComment]);
    }).toList();
  }

  // Legacy local uploads used @you or picked files before owner IDs existed.
  // An explicit owner always takes precedence over those legacy markers.
  static DemoVideoPost _withLegacyOwnership(DemoVideoPost post) {
    if (post.ownerId == null &&
        (post.isPickedFile || post.username == '@you')) {
      return post.copyWith(ownerId: DemoVideoPost.localOwnerId);
    }
    return post;
  }

  /// Upgrade pre-owner-ID posts while the original profile handle is known.
  /// Handle matching is used only for migration, never for owned-post filtering.
  static void migrateLegacyOwnership(String username) {
    final handle = username.trim();
    var changed = false;
    final migrated = posts.value.map((post) {
      if (post.ownerId != null) return post;
      final legacy = _withLegacyOwnership(post);
      if (legacy.ownerId != null ||
          (handle.isNotEmpty && post.username == handle)) {
        changed = true;
        return post.copyWith(ownerId: DemoVideoPost.localOwnerId);
      }
      return post;
    }).toList();
    if (changed) posts.value = migrated;
  }

  static List<DemoVideoPost> get currentUserPosts {
    return posts.value
        .map(_withLegacyOwnership)
        .where((post) => post.ownerId == DemoVideoPost.localOwnerId)
        .toList();
  }
}
