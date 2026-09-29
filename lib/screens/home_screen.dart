import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/auth_service.dart';
import '../services/block_service.dart';
import '../services/post_service.dart';
import '../widgets/video_post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final BlockService _blockService = BlockService();
  final AuthService _authService = AuthService();

  DemoVideoPost _postFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return DemoVideoPost(
      id: doc.id,
      authorId: (data['authorId'] as String?) ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
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
    final myUid = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'Glassnik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      // Wrapped in a stream of who you've blocked, so the feed below
      // can filter their posts out client-side — Firestore security
      // rules can't do a "not in my blocked list" check for you,
      // since a post document has no idea who's viewing it.
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myUid == null
            ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
            : _blockService.watchBlockedUsers(myUid),

        builder: (context, blockedSnapshot) {
          final blockedUids = (blockedSnapshot.data?.docs ?? [])
              .map((doc) => doc.id)
              .toSet();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _postService.watchFeed(),

            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Something went wrong loading the feed.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                );
              }

              final docs = snapshot.data!.docs.where((doc) {
                final authorId = (doc.data()['authorId'] as String?) ?? '';
                return !blockedUids.contains(authorId);
              }).toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_outlined, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'No videos yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'Tap Upload below to add your first video.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),

                itemCount: docs.length,

                itemBuilder: (context, index) {
                  final post = _postFromDoc(docs[index]);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: VideoPostCard(key: ValueKey(post.id), post: post),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}