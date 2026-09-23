import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/demo_post_store.dart';
import '../services/connections_store.dart';
import '../services/profile_store.dart';
import '../widgets/video_post_card.dart';

import 'connections_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,

        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      body: ValueListenableBuilder<UserProfile>(
        valueListenable: ProfileStore.profile,

        builder: (context, profile, child) {
          return ValueListenableBuilder<List<DemoVideoPost>>(
            valueListenable: DemoPostStore.posts,

            builder: (context, posts, child) {
              final myVideos = posts.where((post) {
                return post.username == '@you' ||
                    post.username == profile.username;
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),

                child: Column(
                  children: [
                    // ==================================================
                    // PROFILE IMAGE
                    // ==================================================
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6C63FF),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: ClipOval(
                        child: profile.profileImageBytes != null
                            ? Image.memory(
                                profile.profileImageBytes!,
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 52,
                                color: Colors.white,
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // DISPLAY NAME
                    // ==================================================
                    Text(
                      profile.displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ==================================================
                    // USERNAME
                    // ==================================================
                    Text(
                      profile.username,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // BIO
                    // ==================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        profile.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // PROFILE STATS
                    // ==================================================
                    ListenableBuilder(
                      listenable: ConnectionsStore.instance,
                      builder: (context, child) => Row(
                        children: [
                          _ProfileStat(
                            number: ConnectionsStore.instance.followingCount
                                .toString(),
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
                            number: ConnectionsStore.instance.followerCount
                                .toString(),
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
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // EDIT PROFILE BUTTON
                    // ==================================================
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
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF6C63FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                initialUsername: profile.username,
                                initialBio: profile.bio,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Divider(color: Colors.white12),

                    const SizedBox(height: 12),

                    // ==================================================
                    // MY VIDEOS HEADER
                    // ==================================================
                    Row(
                      children: [
                        const Icon(
                          Icons.grid_on_outlined,
                          size: 20,
                          color: Color(0xFF6C63FF),
                        ),

                        const SizedBox(width: 8),

                        const Text(
                          'My Videos',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          '${myVideos.length}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // EMPTY VIDEOS
                    // ==================================================
                    if (myVideos.isEmpty)
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

                            SizedBox(height: 6),

                            Text(
                              'Upload a video and it will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // ==================================================
                      // MY VIDEOS GRID
                      // ==================================================
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

                          return _ProfileVideoTile(post: post);
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
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onTap != null ? Colors.white70 : Colors.grey,
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
  const _ProfileVideoTile({required this.post});

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
      onTap: () {
        _openVideo(context);
      },

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
              // VIDEO PLACEHOLDER
              Container(
                color: const Color(0xFF242424),
                child: const Icon(
                  Icons.movie_outlined,
                  size: 38,
                  color: Colors.white24,
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
                  child: const Icon(
                    Icons.play_arrow,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),

              // CAPTION
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
