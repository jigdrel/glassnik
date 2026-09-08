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
    posts.value = [post, ...posts.value];
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

  static List<DemoVideoPost> get currentUserPosts {
    return posts.value.where((post) => post.username == '@you').toList();
  }
}
