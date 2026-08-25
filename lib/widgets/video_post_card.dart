import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/demo_video_post.dart';
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

  @override
  Widget build(BuildContext context) {
    final int likeCount = widget.post.likes + (_liked ? 1 : 0);

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _liked = !_liked;
                    });
                  },
                  icon: Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? Colors.red : Colors.white,
                  ),
                ),
                Text('$likeCount'),
                const SizedBox(width: 14),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                const Text('Comments'),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share demo clicked')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Text(
              widget.post.caption,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
