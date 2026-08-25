import 'package:video_player/video_player.dart';

import 'video_controller_factory_web.dart'
    if (dart.library.io) 'video_controller_factory_io.dart'
    as platform;

VideoPlayerController createPickedVideoController(String path) {
  return platform.createPickedVideoController(path);
}
