import 'package:flutter/material.dart';

import '../services/demo_post_store.dart';
import '../widgets/video_post_card.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Glassnik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: onProfileTap,
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: DemoPostStore.posts,
        builder: (context, posts, child) {
          if (posts.isEmpty) {
            return const Center(child: Text('No videos yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return VideoPostCard(post: posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
