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
  final _searchController = TextEditingController();
  String? _genre;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(DemoVideoPost post) {
    final query = _searchController.text.trim().toLowerCase();
    final caption = post.caption.toLowerCase();
    final tags = post.allHashtags.map((tag) => tag.toLowerCase()).toSet();
    final matchesQuery = query.startsWith('#')
        ? tags.any((tag) => tag.startsWith(query.substring(1)))
        : caption.contains(query) ||
              post.username.toLowerCase().contains(query);
    return matchesQuery &&
        (_genre == null || tags.contains(_genre!.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search Glassnik...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
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
              children: DemoVideoPost.genres
                  .map(
                    (genre) => FilterChip(
                      label: Text('#$genre'),
                      selected: _genre == genre,
                      selectedColor: const Color(
                        0xFF6C63FF,
                      ).withValues(alpha: 0.25),
                      onSelected: (selected) =>
                          setState(() => _genre = selected ? genre : null),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<DemoVideoPost>>(
                valueListenable: DemoPostStore.posts,
                builder: (context, posts, child) {
                  final results = posts.where(_matches).toList();
                  if (results.isEmpty) {
                    return const Center(
                      child: Text(
                        'No videos found. Try another search or genre.',
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final post = results[index];
                      return ListTile(
                        key: ValueKey(post.id),
                        leading: const Icon(
                          Icons.play_circle_outline,
                          color: Color(0xFF6C63FF),
                        ),
                        title: Text(post.caption),
                        subtitle: Text(post.username),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text('Video')),
                              body: SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: VideoPostCard(
                                  key: ValueKey(post.id),
                                  post: post,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
