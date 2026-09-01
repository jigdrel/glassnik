import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPostFile({
    required Uint8List fileBytes,
    required String userId,
    required String fileName,
    required String contentType,
  }) async {
    final ref = _storage.ref().child(
      'posts/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );

    await ref.putData(
      fileBytes,
      SettableMetadata(contentType: contentType),
    );

    return ref.getDownloadURL();
  }
}