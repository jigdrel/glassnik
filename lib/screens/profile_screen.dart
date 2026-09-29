import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/video_post_card.dart';

import 'connections_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PostService _postService = PostService();

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
    final uid = _authService.currentUser?.uid;

    if (uid == null) {
      // Shouldn't normally happen (splash screen routes signed-out users
      // to LoginScreen), but guards against a null crash if this screen
      // is ever reached without a signed-in user.
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Please sign in again'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userService.watchUserProfile(uid),
        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          final profileData = profileSnapshot.data!.data() ?? const {};

          final displayName =
              (profileData['displayName'] as String?) ?? 'Glassnik User';
          final username = (profileData['username'] as String?) ?? '@username';
          final bio = (profileData['bio'] as String?) ?? '';
          final followersCount =
              (profileData['followersCount'] as num?)?.toInt() ?? 0;
          final followingCount =
              (profileData['followingCount'] as num?)?.toInt() ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              // StreamBuilders auto-update; this just gives the pull-to-
              // refresh gesture something to do for user feedback.
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _postService.watchUserPosts(uid),
              builder: (context, postsSnapshot) {
                if (postsSnapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Could not load your videos:\n${postsSnapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final myVideos = (postsSnapshot.data?.docs ?? [])
                    .map(_postFromDoc)
                    .toList();
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                  child: Column(
                    children: [
                      // ==========================================
                      // PROFILE IMAGE
                      // ==========================================
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF6C63FF),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: const ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // DISPLAY NAME
                      // ==========================================
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ==========================================
                      // USERNAME
                      // ==========================================
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // BIO
                      // ==========================================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          bio.isEmpty ? 'No bio yet.' : bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // PROFILE STATS
                      // ==========================================
                      Row(
                        children: [
                          _ProfileStat(
                            number: followingCount.toString(),
                            label: 'Following',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionsScreen(
                                    title: 'Following',
                                  ),
                                ),
                              );
                            },
                          ),

                          _ProfileStat(
                            number: followersCount.toString(),
                            label: 'Followers',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionsScreen(
                                    title: 'Followers',
                                  ),
                                ),
                              );
                            },
                          ),

                          _ProfileStat(
                            number: myVideos.length.toString(),
                            label: 'Videos',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // EDIT PROFILE BUTTON
                      // ==========================================
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            side: const BorderSide(color: Color(0xFF6C63FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(
                                  initialUsername: username,
                                  initialBio: bio,
                                  initialDisplayName: displayName,
                                  initialPhotoUrl:
                                      profileData['photoUrl'] as String?,
                                ),
                              ),
                            );
                            // The Firestore StreamBuilder above updates
                            // automatically once EditProfileScreen saves
                            // — no manual refresh needed here.
                          },
                        ),
                      ),

                      const SizedBox(height: 28),

                      Divider(color: Theme.of(context).colorScheme.outlineVariant),

                      const SizedBox(height: 12),

                      // ==========================================
                      // MY VIDEOS HEADER
                      // ==========================================
                      Row(
                        children: [
                          const Icon(
                            Icons.grid_on_outlined,
                            size: 20,
                            color: Color(0xFF6C63FF),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            'My Videos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            '${myVideos.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ==========================================
                      // EMPTY VIDEOS
                      // ==========================================
                      if (myVideos.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.video_library_outlined,
                                size: 52,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'No videos uploaded yet',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Upload a video and it will appear here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // ==========================================
                        // MY VIDEOS GRID
                        // ==========================================
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: myVideos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (context, index) {
                            final post = myVideos[index];

                            return _ProfileVideoTile(
                              key: ValueKey(post.id),
                              post: post,
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================
// PROFILE STAT
// ==========================================================

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.number, required this.label, this.onTap});

  final String number;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 19,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// PROFILE VIDEO TILE
// ==========================================================

class _ProfileVideoTile extends StatelessWidget {
  const _ProfileVideoTile({super.key, required this.post});

  final DemoVideoPost post;

  void _openVideo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      onTap: () {
        _openVideo(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // VIDEO PLACEHOLDER
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.movie_outlined,
                  size: 38,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),

              // PLAY BUTTON
              Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, size: 28, color: Colors.white),
                ),
              ),

              // CAPTION
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
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