import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Handles uploading files to Firebase Storage and getting back the
/// download URL that gets saved into Firestore (posts.videoUrl,
/// users.photoUrl, etc). Firestore never stores the file itself —
/// only this URL pointing at it.
///
/// Everything here uploads from raw bytes (putData), not from a
/// dart:io File (putFile). That's deliberate: dart:io's File class
/// doesn't work on Flutter Web (it throws at runtime, not compile
/// time), and image_picker's XFile.readAsBytes() works identically
/// on web, mobile, and desktop — so bytes is the one code path that
/// runs everywhere without a platform split.
class StorageService {
  StorageService._internal();

  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a video for [uid] from raw bytes and returns its public
  /// download URL. [postId] should be a unique id you've already
  /// generated (e.g. PostService.newPostId()) so the storage path and
  /// the post document line up.
  ///
  /// [onProgress] fires with a 0.0–1.0 value as the upload proceeds —
  /// wire it to a progress bar so users see feedback for what can be
  /// a fairly large file.
  Future<String> uploadVideo({
    required String uid,
    required String postId,
    required Uint8List videoBytes,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref('videos/$uid/$postId.mp4');

    final uploadTask = ref.putData(
      videoBytes,
      SettableMetadata(contentType: 'video/mp4'),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });
    }

    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  /// Uploads a profile photo for [uid] from raw bytes (this matches
  /// how EditProfileScreen already reads the picked image — via
  /// `image.readAsBytes()` — so no extra conversion is needed there).
  Future<String> uploadProfilePhoto({
    required String uid,
    required List<int> imageBytes,
  }) async {
    final ref = _storage.ref('profile_photos/$uid/avatar.jpg');

    await ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }

  /// Deletes a user's uploaded video. Safe to call even if the file
  /// doesn't exist — Storage's "not found" is caught and ignored so
  /// callers don't need their own try/catch for that specific case.
  Future<void> deleteVideo({
    required String uid,
    required String postId,
  }) async {
    try {
      await _storage.ref('videos/$uid/$postId.mp4').delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}