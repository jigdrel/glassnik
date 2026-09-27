class DemoVideoPost {
  static const genres = [
    'Trending',
    'Music',
    'Gaming',
    'Travel',
    'Funny',
    'Food',
    'Sports',
    'Fashion',
    'Tech',
    'Pets',
  ];

  // Stable identity for the local demo, independent of editable handles.
  static const localOwnerId = 'local-demo-user';
  final String? ownerId;
  final String id;
  final String authorId;
  final String username;
  final String caption;
  final String videoPath;
  final bool isPickedFile;
  final int likes;
  final List<String> comments;
  final List<String> hashtags;

  const DemoVideoPost({
    this.ownerId,
    required this.id,
    this.authorId = '',
    required this.username,
    required this.caption,
    required this.videoPath,
    required this.isPickedFile,
    this.likes = 0,
    this.comments = const [],
    this.hashtags = const [],
  });

  /// Combine selected tags and legacy caption tags using one extraction rule.
  /// Known genres retain their display spelling; duplicates ignore case.
  List<String> get allHashtags {
    final tags = <String, String>{};
    for (final raw in [
      ...hashtags,
      ...RegExp(r'#(\w+)').allMatches(caption).map((m) => m.group(1)!),
    ]) {
      final tag = raw.trim().replaceFirst(RegExp(r'^#'), '').toLowerCase();
      if (tag.isEmpty) continue;
      tags[tag] = genres.firstWhere(
        (genre) => genre.toLowerCase() == tag,
        orElse: () => tag,
      );
    }
    return List.unmodifiable(tags.values);
  }

  DemoVideoPost copyWith({
    String? ownerId,
    String? id,
    String? authorId,
    String? username,
    String? caption,
    String? videoPath,
    bool? isPickedFile,
    int? likes,
    List<String>? comments,
    List<String>? hashtags,
  }) {
    return DemoVideoPost(
      ownerId: ownerId ?? this.ownerId,
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
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