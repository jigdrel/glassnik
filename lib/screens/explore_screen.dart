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

  static const _genres = [
    'Trending',
    'Music',
    'Gaming',
    'Travel',
    'Funny',
    'Food',
    'Sports',
    'Fashion',
    'Tech',
    'Pets',
  ];

  void _selectHashtag(String tag) {
    final hashtag = '#${tag.toLowerCase()}';
    if (_searchController.text.trim().toLowerCase() == hashtag) {
      _searchController.clear();
    } else {
      _searchController.value = TextEditingValue(
        text: hashtag,
        selection: TextSelection.collapsed(offset: hashtag.length),
      );
    }
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
                child: VideoPostCard(key: ValueKey(post.id), post: post),
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
          final selectedGenre = _genres.firstWhere(
            (genre) => query == '#${genre.toLowerCase()}',
            orElse: () => '',
          );

          return ValueListenableBuilder<List<DemoVideoPost>>(
            valueListenable: DemoPostStore.posts,
            builder: (context, posts, child) {
              final suggestions = {
                ..._genres.map((genre) => genre.toLowerCase()),
                ...posts.expand((post) => post.searchableHashtags),
              }.toList()..sort();
              final results = posts.where((post) {
                if (query.startsWith('#')) {
                  return post.searchableHashtags.contains(query.substring(1));
                }
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _genres.map((genre) {
                      return FilterChip(
                        label: Text('#$genre'),
                        selected: query == '#${genre.toLowerCase()}',
                        onSelected: (_) => _selectHashtag(genre),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (query == '#') ...[
                    const Text(
                      'Choose a hashtag',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap a genre above or explore these hashtags.'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.map((tag) {
                        return ActionChip(
                          label: Text('#$tag'),
                          onPressed: () => _selectHashtag(tag),
                        );
                      }).toList(),
                    ),
                  ] else if (results.isEmpty)
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
                          Text(
                            selectedGenre.isNotEmpty
                                ? 'No #$selectedGenre videos yet'
                                : 'No results found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedGenre.isNotEmpty
                                ? 'Upload a video with #$selectedGenre in the caption to see it here.'
                                : query.isEmpty
                                ? 'No posts yet. Upload a video to get started!'
                                : 'Try another caption, username or hashtag.',
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
