import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final String profileImage;
  final String postImage;
  final String caption;
  final int likes;
  final int comments;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImage,
    required this.postImage,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Post(
      id: document.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      profileImage: data['profileImageUrl'] ?? '',
      postImage: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      likes: data['likesCount'] ?? 0,
      comments: data['commentsCount'] ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}