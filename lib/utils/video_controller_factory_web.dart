import 'package:video_player/video_player.dart';

VideoPlayerController createPickedVideoController(String path) {
  return VideoPlayerController.networkUrl(Uri.parse(path));
}
