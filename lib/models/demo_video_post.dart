class DemoVideoPost {
  final String id;
  final String username;
  final String caption;
  final String videoPath;
  final bool isPickedFile;
  final int likes;
  final List<String> comments;

  const DemoVideoPost({
    required this.id,
    required this.username,
    required this.caption,
    required this.videoPath,
    required this.isPickedFile,
    this.likes = 0,
    this.comments = const [],
  });

  DemoVideoPost copyWith({
    String? id,
    String? username,
    String? caption,
    String? videoPath,
    bool? isPickedFile,
    int? likes,
    List<String>? comments,
  }) {
    return DemoVideoPost(
      id: id ?? this.id,
      username: username ?? this.username,
      caption: caption ?? this.caption,
      videoPath: videoPath ?? this.videoPath,
      isPickedFile: isPickedFile ?? this.isPickedFile,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}
