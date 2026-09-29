import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/auth_service.dart';
import '../services/block_service.dart';
import '../services/follow_service.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/video_post_card.dart';

/// A read-only-ish view of ANY user's profile (yours or someone
/// else's), reached by tapping a username/avatar anywhere in the
/// app — e.g. from VideoPostCard or Explore's search results.
///
/// This is deliberately a separate screen from ProfileScreen (which
/// is "your own profile with edit controls"). This one has no edit
/// button or settings gear — the interactive pieces are the
/// Follow/Unfollow button and the Block menu, both hidden when
/// viewing your own profile.
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

  Future<void> _confirmAndToggleBlock(
    BuildContext context, {
    required String myUid,
    required String theirUid,
    required bool currentlyBlocked,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(currentlyBlocked ? 'Unblock user?' : 'Block user?'),
          content: Text(
            currentlyBlocked
                ? 'They will be able to see your profile and posts again, and you can follow each other again.'
                : 'They won\'t be shown in your feed or search, and any follow between you two will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: currentlyBlocked ? null : Colors.red,
              ),
              child: Text(currentlyBlocked ? 'Unblock' : 'Block'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final blockService = BlockService();

    try {
      if (currentlyBlocked) {
        await blockService.unblock(myUid: myUid, targetUid: theirUid);
      } else {
        await blockService.block(myUid: myUid, targetUid: theirUid);
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update block: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService().currentUser?.uid;
    final isOwnProfile = myUid != null && myUid == uid;

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
        actions: [
          if (!isOwnProfile && myUid != null)
            StreamBuilder<bool>(
              stream: BlockService().watchIsBlocked(
                myUid: myUid,
                targetUid: uid,
              ),
              builder: (context, snapshot) {
                final isBlocked = snapshot.data ?? false;

                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (_) => _confirmAndToggleBlock(
                    context,
                    myUid: myUid,
                    theirUid: uid,
                    currentlyBlocked: isBlocked,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'block',
                      child: Text(isBlocked ? 'Unblock user' : 'Block user'),
                    ),
                  ],
                );
              },
            ),
        ],
      ),

      body: (!isOwnProfile && myUid != null)
          ? StreamBuilder<bool>(
              stream: BlockService().watchIsBlocked(
                myUid: myUid,
                targetUid: uid,
              ),
              builder: (context, blockedSnapshot) {
                if (blockedSnapshot.data == true) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.block, size: 52, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'You have blocked this user.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Unblock them from the menu above to see their profile again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _ProfileBody(uid: uid, myUid: myUid, isOwnProfile: false);
              },
            )
          : _ProfileBody(uid: uid, myUid: myUid, isOwnProfile: isOwnProfile),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.uid,
    required this.myUid,
    required this.isOwnProfile,
  });

  final String uid;
  final String? myUid;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
        final photoUrl = profileData['photoUrl'] as String?;
        final followersCount =
            (profileData['followersCount'] as num?)?.toInt() ?? 0;
        final followingCount =
            (profileData['followingCount'] as num?)?.toInt() ?? 0;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: PostService().watchUserPosts(uid),

          builder: (context, postsSnapshot) {
            final videos = (postsSnapshot.data?.docs ?? [])
                .map(UserProfileScreen._postFromDoc)
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
                    child: ClipOval(
                      child: (photoUrl != null && photoUrl.isNotEmpty)
                          ? Image.network(
                              photoUrl,
                              // Cache-busting the request key by the
                              // full URL (which already includes a
                              // Firebase Storage token that changes
                              // per upload) means a new photo here
                              // always fetches fresh instead of
                              // showing a stale cached one from a
                              // previous uid's request.
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: Colors.white,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                              size: 52,
                              color: Colors.white,
                            ),
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatColumn(number: followersCount, label: 'Followers'),
                      const SizedBox(width: 28),
                      _StatColumn(number: followingCount, label: 'Following'),
                      const SizedBox(width: 28),
                      _StatColumn(number: videos.length, label: 'Videos'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!isOwnProfile && myUid != null)
                    _FollowButton(myUid: myUid!, theirUid: uid),

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
                            style: TextStyle(color: Colors.grey, fontSize: 15),
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

                        return _VideoTile(key: ValueKey(post.id), post: post);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton({required this.myUid, required this.theirUid});

  final String myUid;
  final String theirUid;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  final FollowService _followService = FollowService();

  // Tracks an in-flight tap so a fast double-tap can't fire two
  // opposite writes (follow then unfollow) before the first finishes.
  bool _busy = false;

  Future<void> _handleTap(bool currentlyFollowing) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      if (currentlyFollowing) {
        await _followService.unfollow(
          myUid: widget.myUid,
          theirUid: widget.theirUid,
        );
      } else {
        await _followService.follow(
          myUid: widget.myUid,
          theirUid: widget.theirUid,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update follow status: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _followService.watchIsFollowing(
        myUid: widget.myUid,
        theirUid: widget.theirUid,
      ),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;

        return SizedBox(
          width: 160,
          height: 42,
          child: isFollowing
              ? OutlinedButton(
                  onPressed: _busy ? null : () => _handleTap(true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_busy ? '...' : 'Following'),
                )
              : ElevatedButton(
                  onPressed: _busy ? null : () => _handleTap(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_busy ? '...' : 'Follow'),
                ),
        );
      },
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
                child: Icon(Icons.play_arrow, size: 28, color: Colors.white),
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