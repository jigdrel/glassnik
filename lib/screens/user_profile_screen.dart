import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/video_post_card.dart';

/// A read-only view of ANY user's profile (yours or someone else's),
/// reached by tapping a username/avatar anywhere in the app — e.g.
/// from VideoPostCard or Explore's search results.
///
/// This is deliberately a separate screen from ProfileScreen (which
/// is "your own profile with edit controls," still being built out).
/// This one only ever reads — no edit button, no settings gear — so
/// it can be finished and used immediately without waiting on or
/// conflicting with that other screen's changes.
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.uid});

  final String uid;

  static DemoVideoPost _postFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return DemoVideoPost(
      id: doc.id,
      authorId: (data['authorId'] as String?) ?? '',
      username: (data['authorUsername'] as String?) ?? '@unknown',
      caption: (data['caption'] as String?) ?? '',
      videoPath: (data['videoUrl'] as String?) ?? '',
      isPickedFile: false,
      likes: 0,
      comments: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserService().watchUserProfile(uid),

        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          final profileData = profileSnapshot.data!.data();

          if (profileData == null) {
            return const Center(
              child: Text(
                'This user could not be found.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final displayName =
              (profileData['displayName'] as String?) ?? 'Glassnik User';
          final username = (profileData['username'] as String?) ?? '@unknown';
          final bio = (profileData['bio'] as String?) ?? '';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: PostService().watchUserPosts(uid),

            builder: (context, postsSnapshot) {
              final videos = (postsSnapshot.data?.docs ?? [])
                  .map(_postFromDoc)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),

                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6C63FF),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      username,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),

                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    Text(
                      '${videos.length} ${videos.length == 1 ? 'video' : 'videos'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),

                    if (videos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 52,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No videos uploaded yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: videos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final post = videos[index];

                          return _VideoTile(
                            key: ValueKey(post.id),
                            post: post,
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({super.key, required this.post});

  final DemoVideoPost post;

  void _openVideo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Video'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: VideoPostCard(post: post),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openVideo(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: const Color(0xFF242424),
                child: const Icon(
                  Icons.movie_outlined,
                  size: 38,
                  color: Colors.white24,
                ),
              ),
              const Center(
                child: Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    post.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}