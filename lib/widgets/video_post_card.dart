import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/demo_video_post.dart';
import '../services/demo_post_store.dart';
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

  bool _liked = false;

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

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
    });
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

    DemoPostStore.addComment(postId: widget.post.id, comment: comment);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Comment added')));
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
    final likeCount = widget.post.likes + (_liked ? 1 : 0);
    final commentCount = widget.post.comments.length;

    final theme = Theme.of(context);

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
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
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
                IconButton(
                  onPressed: _toggleLike,
                  tooltip: 'Like',
                  icon: Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? Colors.red : theme.colorScheme.onSurface,
                  ),
                ),

                Text('$likeCount'),

                const SizedBox(width: 12),

                IconButton(
                  onPressed: _openCommentDialog,
                  tooltip: 'Comment',
                  icon: const Icon(Icons.mode_comment_outlined),
                ),

                Text('$commentCount'),

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

          if (widget.post.comments.isNotEmpty)
            Padding(
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

                  ...widget.post.comments.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '@you ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text(comment)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
