import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../utils/video_controller_factory.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController captionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final PostService _postService = PostService();

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

    final VideoPlayerController controller = createPickedVideoController(
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

    final user = _authService.currentUser;

    if (user == null) {
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
      final postId = _postService.newPostId();

      // Read as bytes rather than using dart:io File — this is the
      // one path that works identically on web, mobile, and desktop.
      // (A dart:io File built from an image_picker XFile's path does
      // NOT work on Flutter Web — it throws at runtime.)
      final videoBytes = await _selectedVideo!.readAsBytes();

      final videoUrl = await _storageService.uploadVideo(
        uid: user.uid,
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
      final authorUsername =
          (profile?['username'] as String?) ?? '@unknown';

      await _postService.createPost(
        postId: postId,
        authorId: user.uid,
        authorUsername: authorUsername,
        videoUrl: videoUrl,
        caption: caption,
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
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