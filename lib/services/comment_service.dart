import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles comments as a subcollection (posts/{postId}/comments/{id}).
/// Same reasoning as LikeService: counted live from the subcollection
/// rather than a stored counter field, since only a post's author can
/// update the post document itself under your current rules.
class CommentService {
  CommentService._internal();

  static final CommentService _instance = CommentService._internal();

  factory CommentService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _commentsOf(String postId) =>
      _firestore.collection('posts').doc(postId).collection('comments');

  /// Live stream of a post's comments, oldest first (reads naturally
  /// top-to-bottom like a conversation).
  Stream<QuerySnapshot<Map<String, dynamic>>> watchComments(String postId) {
    return _commentsOf(postId).orderBy('createdAt').snapshots();
  }

  /// Adds a comment as the current user. [authorUsername] is the
  /// COMMENTER's own username (not the post's author) — callers look
  /// this up before calling, e.g. via UserService.getUserProfile.
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorUsername,
    required String text,
  }) async {
    await _commentsOf(postId).add({
      'authorId': authorId,
      'authorUsername': authorUsername,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}