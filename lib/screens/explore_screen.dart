import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/demo_post_store.dart';
import '../widgets/video_post_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPost(DemoVideoPost selectedPost) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Post')),
          body: ValueListenableBuilder<List<DemoVideoPost>>(
            valueListenable: DemoPostStore.posts,
            builder: (context, posts, child) {
              final post = posts.firstWhere(
                (post) => post.id == selectedPost.id,
                orElse: () => selectedPost,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: VideoPostCard(
                  key: ValueKey(post.id),
                  post: post,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, searchValue, child) {
          final query = searchValue.text.trim().toLowerCase();

          return ValueListenableBuilder<List<DemoVideoPost>>(
            valueListenable: DemoPostStore.posts,
            builder: (context, posts, child) {
              final results = posts.where((post) {
                return post.caption.toLowerCase().contains(query) ||
                    post.username.toLowerCase().contains(query);
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Glassnik...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchValue.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: _searchController.clear,
                              icon: const Icon(Icons.close),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('#Trending')),
                      Chip(label: Text('#Music')),
                      Chip(label: Text('#Gaming')),
                      Chip(label: Text('#Travel')),
                      Chip(label: Text('#Funny')),
                      Chip(label: Text('#Food')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 56,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            query.isEmpty
                                ? 'No posts yet. Upload a video to get started!'
                                : 'Try another caption or username.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ...results.map(
                      (post) => Card(
                        key: ValueKey(post.id),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () => _openPost(post),
                          leading: const Icon(Icons.video_library_outlined),
                          title: Text(
                            post.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            post.caption,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
