import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/demo_video_post.dart';
import '../services/demo_post_store.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../utils/video_controller_factory.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({
    super.key,
    this.imagePicker,
    this.publishPost,
    this.videoControllerFactory = createPickedVideoController,
  });

  final ImagePicker? imagePicker;

  /// Optional publisher for standalone demos and tests; production uses the backend.
  final Future<DemoVideoPost> Function(DemoVideoPost)? publishPost;
  final VideoPlayerController Function(String) videoControllerFactory;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController captionController = TextEditingController();

  late final ImagePicker _picker = widget.imagePicker ?? ImagePicker();
  final Set<String> _selectedHashtags = {};

  late final AuthService _authService = AuthService();
  late final UserService _userService = UserService();
  late final StorageService _storageService = StorageService();
  late final PostService _postService = PostService();

  XFile? _selectedVideo;
  VideoPlayerController? _previewController;

  bool _isUploading = false;
  double _uploadProgress = 0;

  Future<void> selectVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video == null) {
      return;
    }

    await _previewController?.dispose();

    final VideoPlayerController controller = widget.videoControllerFactory(
      video.path,
    );

    await controller.initialize();
    await controller.setLooping(true);

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _selectedVideo = video;
      _previewController = controller;
    });
  }

  Future<void> submitPost() async {
    final String caption = captionController.text.trim();

    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first.')),
      );
      return;
    }

    if (caption.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a caption.')));
      return;
    }

    final user = widget.publishPost == null ? _authService.currentUser : null;

    if (widget.publishPost == null && user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be signed in to upload a video.'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final draft = DemoVideoPost(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        ownerId: DemoVideoPost.localOwnerId,
        username: '@you',
        caption: caption,
        hashtags: List.unmodifiable(_selectedHashtags),
        videoPath: _selectedVideo!.path,
        isPickedFile: true,
      );
      final tags = draft.allHashtags;
      final DemoVideoPost published;
      if (widget.publishPost != null) {
        published = await widget.publishPost!(draft.copyWith(hashtags: tags));
      } else {
        final postId = _postService.newPostId();

        // Read as bytes rather than using dart:io File — this is the
        // one path that works identically on web, mobile, and desktop.
        // (A dart:io File built from an image_picker XFile's path does
        // NOT work on Flutter Web — it throws at runtime.)
        final videoBytes = await _selectedVideo!.readAsBytes();

        final videoUrl = await _storageService.uploadVideo(
          uid: user!.uid,
          postId: postId,
          videoBytes: videoBytes,
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        final profile = await _userService.getUserProfile(user.uid);
        final authorUsername = (profile?['username'] as String?) ?? '@unknown';

        await _postService.createPost(
          postId: postId,
          authorId: user.uid,
          authorUsername: authorUsername,
          videoUrl: videoUrl,
          caption: caption,
          genres: tags,
        );
        published = draft.copyWith(
          id: postId,
          username: authorUsername,
          videoPath: videoUrl,
          isPickedFile: false,
          hashtags: tags,
        );
      }

      // Publish locally only after the backend (or injected publisher) succeeds.
      DemoPostStore.addPost(published);

      if (!mounted) {
        return;
      }

      captionController.clear();

      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });

      // Show the real error instead of a generic message — while
      // you're still shaking out bugs like the web/dart:io one,
      // seeing the actual exception text saves a lot of guessing.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $error')));
    }
  }

  void togglePreview() {
    if (_previewController == null) {
      return;
    }

    setState(() {
      if (_previewController!.value.isPlaying) {
        _previewController!.pause();
      } else {
        _previewController!.play();
      }
    });
  }

  @override
  void dispose() {
    captionController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              clipBehavior: Clip.antiAlias,
              child: _previewController == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_outlined, size: 64),
                        SizedBox(height: 12),
                        Text('No video selected'),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: VideoPlayer(_previewController!),
                        ),
                        IconButton.filled(
                          onPressed: togglePreview,
                          icon: Icon(
                            _previewController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _isUploading ? null : selectVideo,
              icon: const Icon(Icons.video_library_outlined),
              label: Text(
                _selectedVideo == null ? 'Choose Video' : 'Change Video',
              ),
            ),

            if (_selectedVideo != null) ...[
              const SizedBox(height: 8),
              Text(_selectedVideo!.name, textAlign: TextAlign.center),
            ],

            const SizedBox(height: 20),

            TextField(
              enabled: !_isUploading,
              controller: captionController,
              maxLines: 4,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Write something about your video...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Hashtags',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DemoVideoPost.genres
                  .map(
                    (genre) => FilterChip(
                      label: Text('#$genre'),
                      selected: _selectedHashtags.contains(genre),
                      selectedColor: const Color(0xFF6C63FF),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedHashtags.contains(genre)
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onSelected: _isUploading
                          ? null
                          : (selected) => setState(() {
                              if (selected) {
                                _selectedHashtags.add(genre);
                              } else {
                                _selectedHashtags.remove(genre);
                              }
                            }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            if (_isUploading) ...[
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 8),
              Text(
                'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            ElevatedButton.icon(
              onPressed: _isUploading ? null : submitPost,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Uploading...' : 'Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
