import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'username': email.split('@').first,
      'displayName': '',
      'bio': '',
      'profileImageUrl': '',
      'followersCount': 0,
      'followingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}