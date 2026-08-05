import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController captionController =
      TextEditingController();

  bool imageSelected = false;

  void selectImage() {
    setState(() {
      imageSelected = true;
    });
  }

  void submitPost() {
    final String caption = captionController.text.trim();

    if (!imageSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first.'),
        ),
      );
      return;
    }

    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a caption.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully.'),
      ),
    );

    captionController.clear();

    setState(() {
      imageSelected = false;
    });
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
              ),
              child: imageSelected
                  ? const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: Colors.green,
                        ),
                        SizedBox(height: 12),
                        Text('Image selected'),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 64,
                        ),
                        SizedBox(height: 12),
                        Text('No image selected'),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: selectImage,
              icon: const Icon(
                Icons.photo_library_outlined,
              ),
              label: const Text('Choose Image'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: captionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Write something about your post...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: submitPost,
              icon: const Icon(Icons.upload),
              label: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}