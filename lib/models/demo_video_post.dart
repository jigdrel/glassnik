class DemoVideoPost {
  final String id;
  final String username;
  final String caption;
  final String videoPath;
  final bool isPickedFile;
  final int likes;

  const DemoVideoPost({
    required this.id,
    required this.username,
    required this.caption,
    required this.videoPath,
    required this.isPickedFile,
    this.likes = 0,
  });
}
