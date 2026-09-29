import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles the Firestore side of posts: creating a post document and
/// keeping the author's postsCount in sync. Storage upload itself is
/// StorageService's job -- this only ever deals with Firestore.
class PostService {
  PostService._internal();

  static final PostService _instance = PostService._internal();

  factory PostService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Reserves a new post ID before the video is uploaded, so the
  /// Storage path (videos/{uid}/{postId}.mp4) and the eventual
  /// Firestore document can share the same ID from the start.
  String newPostId() => _posts.doc().id;

  /// Creates the post document for a video that has ALREADY been
  /// uploaded to Storage (call StorageService.uploadVideo first and
  /// pass its result as [videoUrl]).
  ///
  /// [authorPhotoUrl] is denormalized onto the post at creation time so
  /// the feed can show the author's avatar without an extra per-post
  /// Firestore read. Pass whatever the author's profile photoUrl is at
  /// upload time (or null if they haven't set one) -- it won't update
  /// retroactively on old posts if they change their photo later.
  ///
  /// Uses a batch so the new post and the author's incremented
  /// postsCount are written together -- if one failed silently on its
  /// own, you could end up with a post that doesn't count toward the
  /// author's total, or vice versa.
  Future<void> createPost({
    required String postId,
    required String authorId,
    required String authorUsername,
    String? authorPhotoUrl,
    required String videoUrl,
    required String caption,
    List<String> genres = const [],
    String? musicTrackId,
  }) async {
    final batch = _firestore.batch();

    final postRef = _posts.doc(postId);
    final userRef = _users.doc(authorId);

    batch.set(postRef, {
      'authorId': authorId,
      'authorUsername': authorUsername,
      'authorPhotoUrl': authorPhotoUrl,
      'videoUrl': videoUrl,
      'caption': caption,
      'genres': genres,
      'musicTrackId': musicTrackId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(userRef, {
      'postsCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Live stream of posts for the home feed, newest first. Swap the
  /// `.limit()` value or add a `.where('genres', arrayContainsAny: ...)`
  /// clause here later for the personalized-feed feature.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchFeed({int limit = 30}) {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Live stream of just one user's own posts, newest first -- used by
  /// ProfileScreen's "My Videos" grid and UserProfileScreen. Filtered
  /// server-side by authorId, not a client-side filter of watchFeed(),
  /// so it stays cheap no matter how big the overall feed gets.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserPosts(String uid) {
    return _posts
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}