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

  /// The author's profile photo, denormalized onto the post at upload
  /// time so the feed can show it without an extra Firestore read per
  /// video. Null/empty for posts created before this field existed, or
  /// for an author who never set a photo -- either way the UI falls
  /// back to the placeholder icon.
  final String? authorPhotoUrl;
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
    this.authorPhotoUrl,
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
    String? authorPhotoUrl,
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
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
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