import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles likes as a subcollection (posts/{postId}/likes/{uid}),
/// NOT as a counter field on the post document.
///
/// Why: your Firestore rules only allow a post's own author to update
/// that post document. If likesCount lived on the post itself,
/// anyone liking someone else's video would be denied by the rules
/// the moment they tried to increment it. Counting the subcollection
/// live sidesteps that entirely — no rule changes needed, and the
/// count can never go stale or drift from reality.
class LikeService {
  LikeService._internal();

  static final LikeService _instance = LikeService._internal();

  factory LikeService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _likesOf(String postId) =>
      _firestore.collection('posts').doc(postId).collection('likes');

  /// Live stream of everyone who's liked this post. Use
  /// `.docs.length` for the count and `.docs.any((d) => d.id == uid)`
  /// to check whether the current user has liked it.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchLikes(String postId) {
    return _likesOf(postId).snapshots();
  }

  /// Toggles the current user's like on a post: creates
  /// posts/{postId}/likes/{uid} if it doesn't exist, deletes it if it
  /// does. The document ID being the liker's own uid is what the
  /// security rules check against, so this can only ever affect your
  /// own like — never someone else's.
  Future<void> toggleLike({
    required String postId,
    required String uid,
  }) async {
    final likeRef = _likesOf(postId).doc(uid);
    final existing = await likeRef.get();

    if (existing.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}