import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController captionController = TextEditingController();

  final StorageService storageService = StorageService();
  final FirestoreService firestoreService = FirestoreService();

  Uint8List? selectedFileBytes;
  String? selectedFileName;

  bool isUploading = false;

  Future<void> selectImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.image,
    );

    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();

    if (!mounted) return;

    setState(() {
      selectedFileBytes = bytes;
      selectedFileName = file.name;
    });
  }

  Future<void> submitPost() async {
    final caption = captionController.text.trim();

    if (selectedFileBytes == null || selectedFileName == null) {
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

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to create a post.'),
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final imageUrl = await storageService.uploadPostFile(
        fileBytes: selectedFileBytes!,
        userId: user.uid,
        fileName: selectedFileName!,
        contentType: 'image/jpeg',
      );

      await firestoreService.createPost(
        userId: user.uid,
        username: user.email?.split('@').first ?? 'user',
        caption: caption,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully.'),
        ),
      );

      captionController.clear();

      setState(() {
        selectedFileBytes = null;
        selectedFileName = null;
      });

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
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
              child: selectedFileBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        selectedFileBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: isUploading ? null : selectImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose Image'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: captionController,
              maxLines: 4,
              enabled: !isUploading,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Write something about your post...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: isUploading ? null : submitPost,
              icon: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(
                isUploading ? 'Uploading...' : 'Create Post',
              ),
            ),
          ],
        ),
      ),
    );
  }
}