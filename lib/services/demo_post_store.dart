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
    ),
  ]);

  static void addPost(DemoVideoPost post) {
    posts.value = [post, ...posts.value];
  }

  static List<DemoVideoPost> get currentUserPosts {
    return posts.value.where((post) => post.username == '@you').toList();
  }
}
