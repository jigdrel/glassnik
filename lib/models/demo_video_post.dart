class DemoVideoPost {
  final String id;
  final String username;
  final String caption;
  final String videoPath;
  final bool isPickedFile;
  final int likes;
  final List<String> comments;
  final List<String> hashtags;

  const DemoVideoPost({
    required this.id,
    required this.username,
    required this.caption,
    required this.videoPath,
    required this.isPickedFile,
    this.likes = 0,
    this.comments = const [],
    this.hashtags = const [],
  });

  // Include caption tags so existing uploads need no migration.
  Set<String> get searchableHashtags {
    return {
      ...hashtags.map(
        (tag) => tag.trim().replaceFirst(RegExp(r'^#'), '').toLowerCase(),
      ),
      ...RegExp(
        r'(?:^|[^\w#])#(\w+)',
      ).allMatches(caption).map((match) => match.group(1)!.toLowerCase()),
    }..remove('');
  }

  DemoVideoPost copyWith({
    String? id,
    String? username,
    String? caption,
    String? videoPath,
    bool? isPickedFile,
    int? likes,
    List<String>? comments,
    List<String>? hashtags,
  }) {
    return DemoVideoPost(
      id: id ?? this.id,
      username: username ?? this.username,
      caption: caption ?? this.caption,
      videoPath: videoPath ?? this.videoPath,
      isPickedFile: isPickedFile ?? this.isPickedFile,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      hashtags: hashtags ?? this.hashtags,
    );
  }
}
