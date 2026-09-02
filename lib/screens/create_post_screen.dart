import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/demo_video_post.dart';
import '../services/demo_post_store.dart';
import '../utils/video_controller_factory.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController captionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? _selectedVideo;
  VideoPlayerController? _previewController;

  bool _isUploading = false;

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

    setState(() {
      _isUploading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    DemoPostStore.addPost(
      DemoVideoPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: '@you',
        caption: caption,
        videoPath: _selectedVideo!.path,
        isPickedFile: true,
        likes: 0,
      ),
    );

    if (!mounted) {
      return;
    }

    captionController.clear();

    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video uploaded successfully!')),
    );

    Navigator.pop(context);
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
