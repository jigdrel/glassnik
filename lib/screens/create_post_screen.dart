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

  static const _captionLimit = 150;
  static const _genres = [
    'Trending',
    'Music',
    'Gaming',
    'Travel',
    'Funny',
    'Food',
    'Sports',
    'Fashion',
    'Tech',
    'Pets',
  ];
  static final _captionHashtags = RegExp(r'(?:^|[^\w#])#(\w+)');

  void _toggleHashtag(String genre) {
    final caption = captionController.text;
    final tag = genre.toLowerCase();
    final selected = _captionHashtags
        .allMatches(caption)
        .any((match) => match.group(1)!.toLowerCase() == tag);
    final String updatedCaption;

    if (selected) {
      updatedCaption = caption.replaceAllMapped(_captionHashtags, (match) {
        if (match.group(1)!.toLowerCase() != tag) {
          return match.group(0)!;
        }
        // Preserve the whitespace or punctuation before the hashtag.
        final matchedText = match.group(0)!;
        return matchedText.substring(0, matchedText.indexOf('#'));
      }).trim();
    } else {
      final separator = caption.isEmpty || RegExp(r'\s$').hasMatch(caption)
          ? ''
          : ' ';
      updatedCaption = '$caption$separator#$genre';
      if (updatedCaption.characters.length > _captionLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Adding this hashtag would exceed the 150-character caption limit.',
            ),
          ),
        );
        return;
      }
    }

    captionController.value = TextEditingValue(
      text: updatedCaption,
      selection: TextSelection.collapsed(offset: updatedCaption.length),
    );
  }

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
              maxLength: _captionLimit,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Write something about your video...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Add hashtags',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: captionController,
              builder: (context, captionValue, child) {
                final selectedTags = _captionHashtags
                    .allMatches(captionValue.text)
                    .map((match) => match.group(1)!.toLowerCase())
                    .toSet();

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _genres.map((genre) {
                    final selected = selectedTags.contains(genre.toLowerCase());
                    return FilterChip(
                      label: Text('#$genre'),
                      selected: selected,
                      selectedColor: const Color(0xFF6C63FF),
                      checkmarkColor: Colors.white,
                      labelStyle: selected
                          ? const TextStyle(color: Colors.white)
                          : null,
                      onSelected: _isUploading
                          ? null
                          : (_) => _toggleHashtag(genre),
                    );
                  }).toList(),
                );
              },
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
