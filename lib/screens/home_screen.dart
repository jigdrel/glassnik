import 'package:flutter/material.dart';

import '../models/post.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Post> posts = [
    const Post(
      username: 'Alex',
      profileImage: 'https://i.pravatar.cc/150?img=1',
      postImage: 'https://picsum.photos/600/800?random=1',
      caption: 'Amazing hike today! 🏔️',
      likes: 1240,
      comments: 87,
    ),
    const Post(
      username: 'Sarah',
      profileImage: 'https://i.pravatar.cc/150?img=2',
      postImage: 'https://picsum.photos/600/800?random=2',
      caption: 'Sunset drive around Canberra 🌅',
      likes: 890,
      comments: 34,
    ),
    const Post(
      username: 'Mike',
      profileImage: 'https://i.pravatar.cc/150?img=3',
      postImage: 'https://picsum.photos/600/800?random=3',
      caption: 'Weekend adventures 🚗',
      likes: 560,
      comments: 19,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Glassnik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
        },
      ),
    );
  }
}
