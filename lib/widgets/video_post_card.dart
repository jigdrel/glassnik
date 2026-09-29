import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/demo_video_post.dart';
import '../screens/user_profile_screen.dart';
import '../services/auth_service.dart';
import '../services/comment_service.dart';
import '../services/like_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../utils/video_controller_factory.dart';

class VideoPostCard extends StatefulWidget {
  final DemoVideoPost post;

  const VideoPostCard({super.key, required this.post});

  @override
  State<VideoPostCard> createState() => _VideoPostCardState();
}

class _VideoPostCardState extends State<VideoPostCard> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoFuture;

  final LikeService _likeService = LikeService();
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    if (widget.post.isPickedFile) {
      _controller = createPickedVideoController(widget.post.videoPath);
    } else {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.post.videoPath),
      );
    }

    _initializeVideoFuture = _controller.initialize().then((_) {
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  Future<void> _toggleLike() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    // No optimistic setState here — the StreamBuilder wrapping the
    // like button already updates the instant Firestore confirms the
    // write, which for a single small document is fast enough that a
    // separate local "pending" state would be more complexity than
    // it's worth.
    await _likeService.toggleLike(postId: widget.post.id, uid: uid);
  }

  void _openAuthorProfile() {
    if (widget.post.authorId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(uid: widget.post.authorId),
      ),
    );
  }

  Future<void> _openCommentDialog() async {
    final commentController = TextEditingController();

    final comment = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add comment'),
          content: TextField(
            controller: commentController,
            autofocus: true,
            maxLength: 150,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Write a comment...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.pop(dialogContext, value.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = commentController.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    commentController.dispose();

    if (!mounted || comment == null || comment.isEmpty) {
      return;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    // Look up the COMMENTER's own username (not the post's author) —
    // a small extra read, but the comment needs to be attributed to
    // whoever is actually posting it.
    final myProfile = await _userService.getUserProfile(user.uid);
    final myUsername = (myProfile?['username'] as String?) ?? '@unknown';

    try {
      await _commentService.addComment(
        postId: widget.post.id,
        authorId: user.uid,
        authorUsername: myUsername,
        text: comment,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comment added')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not post comment: $error')),
      );
    }
  }

  Future<void> _sharePost() async {
    final shareText =
        '''
Check out this Glassnik post by ${widget.post.username} 👓

${widget.post.caption}

https://glassnik.app/post/${widget.post.id}
''';

    await Clipboard.setData(ClipboardData(text: shareText));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myUid = _authService.currentUser?.uid;
    final authorPhotoUrl = widget.post.authorPhotoUrl;
    final hasAuthorPhoto =
        authorPhotoUrl != null && authorPhotoUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: InkWell(
              onTap: _openAuthorProfile,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    backgroundImage: hasAuthorPhoto
                        ? NetworkImage(authorPhotoUrl)
                        : null,
                    onBackgroundImageError: hasAuthorPhoto
                        ? (exception, stackTrace) {}
                        : null,
                    child: hasAuthorPhoto
                        ? null
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          FutureBuilder<void>(
            future: _initializeVideoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              return GestureDetector(
                onTap: _toggleVideo,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio == 0
                      ? 16 / 9
                      : _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(child: VideoPlayer(_controller)),
                      if (!_controller.value.isPlaying)
                        Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // Live like button + count, driven by the
                // posts/{postId}/likes subcollection rather than a
                // stored counter (see LikeService for why).
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _likeService.watchLikes(widget.post.id),
                  builder: (context, likeSnapshot) {
                    final likeDocs = likeSnapshot.data?.docs ?? [];
                    final likeCount = likeDocs.length;
                    final isLiked =
                        myUid != null && likeDocs.any((d) => d.id == myUid);

                    return Row(
                      children: [
                        IconButton(
                          onPressed: _toggleLike,
                          tooltip: 'Like',
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? Colors.red
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text('$likeCount'),
                      ],
                    );
                  },
                ),

                const SizedBox(width: 12),

                IconButton(
                  onPressed: _openCommentDialog,
                  tooltip: 'Comment',
                  icon: const Icon(Icons.mode_comment_outlined),
                ),

                // Live comment count, same subcollection-based
                // approach as likes.
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _commentService.watchComments(widget.post.id),
                  builder: (context, commentSnapshot) {
                    final commentCount = commentSnapshot.data?.docs.length ?? 0;
                    return Text('$commentCount');
                  },
                ),

                const Spacer(),

                IconButton(
                  onPressed: _sharePost,
                  tooltip: 'Share',
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              widget.post.caption,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          // Live comments list, replacing the old widget.post.comments
          // (which only ever held local demo data and is no longer
          // populated for real posts).
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _commentService.watchComments(widget.post.id),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...docs.map((doc) {
                      final data = doc.data();
                      final commentAuthor =
                          (data['authorUsername'] as String?) ?? '@unknown';
                      final commentText = (data['text'] as String?) ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$commentAuthor ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(child: Text(commentText)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}