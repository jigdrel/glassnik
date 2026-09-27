import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/demo_post_store.dart';
import '../services/profile_store.dart';
import '../services/connections_store.dart';
import '../widgets/video_post_card.dart';

import 'connections_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      await ProfileStore.loadCurrentUserProfile();
    } catch (error) {
      debugPrint('Unable to load profile: $error');
    } finally {
      DemoPostStore.migrateLegacyOwnership(ProfileStore.profile.value.username);
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoadingProfile
          ? Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ValueListenableBuilder<UserProfile>(
                valueListenable: ProfileStore.profile,
                builder: (context, profile, child) {
                  return ListenableBuilder(
                    listenable: Listenable.merge([
                      DemoPostStore.posts,
                      ConnectionsStore.instance,
                    ]),
                    builder: (context, child) {
                      final myVideos = DemoPostStore.currentUserPosts;

                      return SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(18, 12, 18, 30),
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
                                color: Color(0xFF6C63FF),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: profile.profileImageBytes != null
                                    ? Image.memory(
                                        profile.profileImageBytes!,
                                        width: 92,
                                        height: 92,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                              ),
                            ),

                            SizedBox(height: 14),

                            // ==========================================
                            // DISPLAY NAME
                            // ==========================================
                            Text(
                              profile.displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            // ==========================================
                            // USERNAME
                            // ==========================================
                            Text(
                              profile.username.isEmpty
                                  ? '@username'
                                  : profile.username,
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),

                            SizedBox(height: 14),

                            // ==========================================
                            // BIO
                            // ==========================================
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                profile.bio.isEmpty
                                    ? 'No bio yet.'
                                    : profile.bio,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),

                            SizedBox(height: 24),

                            // ==========================================
                            // PROFILE STATS
                            // ==========================================
                            Row(
                              children: [
                                _ProfileStat(
                                  number: ConnectionsStore
                                      .instance
                                      .followingCount
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
                                  number: ConnectionsStore
                                      .instance
                                      .followerCount
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

                            SizedBox(height: 24),

                            // ==========================================
                            // EDIT PROFILE BUTTON
                            // ==========================================
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.edit_outlined),
                                label: Text(
                                  'Edit Profile',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  side: BorderSide(color: Color(0xFF6C63FF)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProfileScreen(
                                        initialUsername: profile.username,
                                        initialBio: profile.bio,
                                      ),
                                    ),
                                  );

                                  // The editor publishes the saved profile to ProfileStore.
                                },
                              ),
                            ),

                            SizedBox(height: 28),

                            Divider(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),

                            SizedBox(height: 12),

                            // ==========================================
                            // MY VIDEOS HEADER
                            // ==========================================
                            Row(
                              children: [
                                Icon(
                                  Icons.grid_on_outlined,
                                  size: 20,
                                  color: Color(0xFF6C63FF),
                                ),

                                SizedBox(width: 8),

                                Text(
                                  'My Videos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Spacer(),

                                Text(
                                  '${myVideos.length}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // ==========================================
                            // EMPTY VIDEOS
                            // ==========================================
                            if (myVideos.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.video_library_outlined,
                                      size: 52,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      'No videos uploaded yet',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontSize: 15,
                                      ),
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      'Upload a video and it will appear here.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
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
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: myVideos.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
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
                  );
                },
              ),
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
          padding: EdgeInsets.symmetric(vertical: 8),
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

              SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onTap != null
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
            title: Text('Video'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(12),
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
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, size: 28, color: Colors.white),
                ),
              ),

              // CAPTION
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    post.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
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
