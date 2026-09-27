import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:glassnik/models/demo_video_post.dart';
import 'package:glassnik/screens/create_post_screen.dart';
import 'package:glassnik/screens/explore_screen.dart';
import 'package:glassnik/services/demo_post_store.dart';

class _Picker extends ImagePicker {
  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async => XFile('test-video.mp4');
}

// Keep widget tests independent of native video decoding and platform plugins.
class _Preview extends VideoPlayerController {
  _Preview() : super.networkUrl(Uri.parse('https://example.com/video.mp4'));
  @override
  Future<void> initialize() async {}
  @override
  Future<void> setLooping(bool looping) async {}
}

Finder chip(String tag) => find.widgetWithText(FilterChip, '#$tag');
Finder get submit => find.widgetWithText(ElevatedButton, 'Create Post');

Future<void> openCreator(
  WidgetTester tester, {
  Future<DemoVideoPost> Function(DemoVideoPost)? publishPost,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreatePostScreen(
                  imagePicker: _Picker(),
                  publishPost: publishPost ?? (post) async => post,
                  videoControllerFactory: (_) => _Preview(),
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  late List<DemoVideoPost> original;
  setUp(() {
    original = DemoPostStore.posts.value;
    DemoPostStore.posts.value = [];
  });
  tearDown(() => DemoPostStore.posts.value = original);

  testWidgets('failed upload retains draft and never publishes a local post', (
    tester,
  ) async {
    final upload = Completer<DemoVideoPost>();
    await openCreator(
      tester,
      publishPost: (post) {
        expect(post.hashtags, ['Sports', 'Tech']);
        return upload.future;
      },
    );
    await tester.tap(find.text('Choose Video'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Match #Tech');
    await tester.ensureVisible(chip('Sports'));
    await tester.tap(chip('Sports'));
    await tester.pump();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(DemoPostStore.posts.value, isEmpty);
    expect(tester.widget<FilterChip>(chip('Sports')).onSelected, isNull);
    upload.completeError(StateError('Upload unavailable'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Upload failed:'), findsOneWidget);
    expect(DemoPostStore.posts.value, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Match #Tech',
    );
    expect(tester.widget<FilterChip>(chip('Sports')).selected, true);
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
  });

  testWidgets(
    'picker is below caption; Sports supports multi-select and deselection',
    (tester) async {
      await openCreator(tester);
      expect(find.byType(FilterChip), findsNWidgets(10));
      for (final tag in [
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
      ]) {
        expect(chip(tag), findsOneWidget);
      }
      expect(
        tester.getTopLeft(chip('Trending')).dy,
        greaterThan(tester.getBottomLeft(find.byType(TextField)).dy),
      );
      expect(
        tester.getTopLeft(submit).dy,
        greaterThan(tester.getBottomLeft(chip('Pets')).dy),
      );
      await tester.ensureVisible(chip('Sports'));
      await tester.tap(chip('Sports'));
      await tester.pump();
      final sports = tester.widget<FilterChip>(chip('Sports'));
      expect(sports.selected, true);
      expect(sports.selectedColor, const Color(0xFF6C63FF));
      await tester.tap(chip('Tech'));
      await tester.pump();
      expect(tester.widget<FilterChip>(chip('Sports')).selected, true);
      expect(tester.widget<FilterChip>(chip('Tech')).selected, true);
      await tester.tap(chip('Tech'));
      await tester.pump();
      expect(tester.widget<FilterChip>(chip('Tech')).selected, false);
      expect(tester.widget<TextField>(find.byType(TextField)).maxLength, 150);
    },
  );

  testWidgets(
    'create saves selected Sports without caption hashtag; Explore matches it',
    (tester) async {
      await openCreator(tester);
      await tester.tap(find.text('Choose Video'));
      await tester.pumpAndSettle();
      expect(find.byType(VideoPlayer), findsOneWidget);
      expect(find.text('Change Video'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Great match');
      await tester.ensureVisible(chip('Sports'));
      await tester.tap(chip('Sports'));
      await tester.pump();
      // Changing video must retain the caption and genre selection.
      await tester.ensureVisible(find.text('Change Video'));
      await tester.tap(find.text('Change Video'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(chip('Sports')).selected, true);
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      final saved = DemoPostStore.posts.value.single;
      expect(saved.hashtags, ['Sports']);
      expect(saved.caption, 'Great match');
      expect(saved.ownerId, DemoVideoPost.localOwnerId);
      expect(DemoPostStore.currentUserPosts.single.id, saved.id);
      DemoPostStore.addComment(postId: saved.id, comment: 'Nice!');
      expect(DemoPostStore.posts.value.single.hashtags, ['Sports']);
      await tester.pumpWidget(const MaterialApp(home: ExploreScreen()));
      await tester.tap(chip('Sports'));
      await tester.pump();
      expect(find.text('Great match'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '#sPoRt');
      await tester.pump();
      expect(find.text('Great match'), findsOneWidget);
      await tester.tap(chip('Music'));
      await tester.pump();
      expect(find.text('Great match'), findsNothing);
    },
  );

  testWidgets(
    'caption hashtags merge with multiple selected genres and deduplicate',
    (tester) async {
      await openCreator(tester);
      await tester.tap(find.text('Choose Video'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Match #SPORTS #custom_tag #Music',
      );
      for (final tag in ['Sports', 'Tech']) {
        await tester.ensureVisible(chip(tag));
        await tester.tap(chip(tag));
        await tester.pump();
      }
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(DemoPostStore.posts.value.single.hashtags, [
        'Sports',
        'Tech',
        'custom_tag',
        'Music',
      ]);
      expect(
        DemoPostStore.posts.value.single.caption,
        'Match #SPORTS #custom_tag #Music',
      );
    },
  );

  testWidgets('video and caption validation still prevent invalid posts', (
    tester,
  ) async {
    await openCreator(tester);
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Please select a video first.'), findsOneWidget);
    expect(DemoPostStore.posts.value, isEmpty);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Choose Video'));
    await tester.tap(find.text('Choose Video'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Please enter a caption.'), findsOneWidget);
    expect(DemoPostStore.posts.value, isEmpty);
  });

  test(
    'legacy caption extraction and copyWith keep metadata and ownership',
    () {
      const legacy = DemoVideoPost(
        id: 'legacy',
        username: '@you',
        caption: '#Sports #ART',
        videoPath: 'video.mp4',
        isPickedFile: true,
      );
      expect(legacy.allHashtags, ['Sports', 'art']);
      DemoPostStore.addPost(legacy);
      final saved = DemoPostStore.posts.value.single;
      expect(saved.hashtags, ['Sports', 'art']);
      expect(saved.copyWith(likes: 1).hashtags, saved.hashtags);
      expect(
        saved.copyWith(comments: ['hello']).ownerId,
        DemoVideoPost.localOwnerId,
      );
    },
  );
}
