class DemoVideoPost {
  final String id;
  final String authorId;
  final String username;
  final String caption;
  final String videoPath;
  final bool isPickedFile;
  final int likes;
  final List<String> comments;

  const DemoVideoPost({
    required this.id,
    this.authorId = '',
    required this.username,
    required this.caption,
    required this.videoPath,
    required this.isPickedFile,
    this.likes = 0,
    this.comments = const [],
  });

  DemoVideoPost copyWith({
    String? id,
    String? authorId,
    String? username,
    String? caption,
    String? videoPath,
    bool? isPickedFile,
    int? likes,
    List<String>? comments,
  }) {
    return DemoVideoPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      username: username ?? this.username,
      caption: caption ?? this.caption,
      videoPath: videoPath ?? this.videoPath,
      isPickedFile: isPickedFile ?? this.isPickedFile,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}