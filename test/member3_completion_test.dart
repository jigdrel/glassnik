import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glassnik/models/demo_video_post.dart';
import 'package:glassnik/screens/explore_screen.dart';
import 'package:glassnik/screens/profile_screen.dart';
import 'package:glassnik/screens/settings_screen.dart';
import 'package:glassnik/screens/privacy_settings_screen.dart';
import 'package:glassnik/screens/edit_profile_screen.dart';
import 'package:glassnik/screens/main_navigation_screen.dart';
import 'package:glassnik/screens/create_post_screen.dart';
import 'package:glassnik/services/demo_post_store.dart';
import 'package:glassnik/services/profile_store.dart';
import 'package:glassnik/services/preferences_store.dart';
import 'package:glassnik/services/connections_store.dart';
import 'package:glassnik/services/theme_store.dart';
import 'package:glassnik/theme/app_theme.dart';
import 'package:glassnik/widgets/video_post_card.dart';

DemoVideoPost post(
  String id, {
  String username = '@oldname',
  String? owner,
  bool picked = false,
  String caption = 'A #Music video',
}) => DemoVideoPost(
  id: id,
  username: username,
  caption: caption,
  ownerId: owner,
  videoPath: 'https://example.com/video.mp4',
  isPickedFile: picked,
);

Widget app(Widget home) => ValueListenableBuilder<ThemeMode>(
  valueListenable: ThemeStore.themeMode,
  builder: (context, mode, child) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
    ),
    darkTheme: AppTheme.darkTheme,
    themeMode: mode,
    home: home,
  ),
);

Finder toggle(String title) => find.widgetWithText(SwitchListTile, title);

void main() {
  late List<DemoVideoPost> originalPosts;
  late UserProfile originalProfile;
  late ThemeMode originalTheme;
  setUp(() {
    originalPosts = DemoPostStore.posts.value;
    originalProfile = ProfileStore.profile.value;
    originalTheme = ThemeStore.themeMode.value;
    DemoPostStore.posts.value = [];
    ProfileStore.profile.value = originalProfile.copyWith(
      displayName: 'Demo User',
      username: '@oldname',
    );
  });
  tearDown(() {
    DemoPostStore.posts.value = originalPosts;
    ProfileStore.profile.value = originalProfile;
    ThemeStore.themeMode.value = originalTheme;
    PreferencesStore.notifications.value = true;
    PreferencesStore.privateAccount.value = false;
    PreferencesStore.allowComments.value = true;
    PreferencesStore.allowSharing.value = true;
    PreferencesStore.activityStatus.value = true;
  });

  test(
    'ownership survives rename and comments, preserving legacy uploads',
    () async {
      DemoPostStore.addPost(post('owned', owner: DemoVideoPost.localOwnerId));
      DemoPostStore.addPost(post('legacy-picked', picked: true));
      DemoPostStore.addPost(post('legacy-you', username: '@you'));
      DemoPostStore.addPost(
        post('other', owner: 'other-user', username: '@you', picked: true),
      );
      DemoPostStore.addPost(post('same-handle'));
      await ProfileStore.updateProfile(
        displayName: 'Demo User',
        username: 'newname',
        bio: '',
      );
      DemoPostStore.addComment(postId: 'owned', comment: 'Hello');
      expect(DemoPostStore.currentUserPosts.map((p) => p.id), [
        'legacy-you',
        'legacy-picked',
        'owned',
      ]);
      expect(DemoPostStore.currentUserPosts.last.comments, ['Hello']);
      expect(
        DemoPostStore.posts.value.last.ownerId,
        DemoVideoPost.localOwnerId,
      );
    },
  );

  test(
    'legacy handle migration survives rename and respects explicit owners',
    () async {
      DemoPostStore.posts.value = [
        post('legacy-handle'),
        post('other-owner', owner: 'other-user'),
        post('unrelated', username: '@someone'),
      ];
      DemoPostStore.migrateLegacyOwnership('@oldname');
      await ProfileStore.updateProfile(
        displayName: 'Demo User',
        username: 'newname',
        bio: '',
      );
      DemoPostStore.migrateLegacyOwnership('@newname');
      expect(DemoPostStore.currentUserPosts.map((post) => post.id), [
        'legacy-handle',
      ]);
      expect(
        DemoPostStore.posts.value.first.ownerId,
        DemoVideoPost.localOwnerId,
      );
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'profile counts, rename, video navigation and theme dark=$dark',
      (tester) async {
        ThemeStore.setDarkMode(dark);
        DemoPostStore.posts.value = [
          post(
            'first',
            owner: DemoVideoPost.localOwnerId,
            caption: 'First upload',
          ),
          post('second', username: '@you', caption: 'Second upload'),
          post('other', owner: 'another-user'),
        ];
        await tester.pumpWidget(app(const ProfileScreen()));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsNWidgets(2));
        final screen = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(
          screen.backgroundColor,
          Theme.of(
            tester.element(find.text('My Videos')),
          ).scaffoldBackgroundColor,
        );
        ConnectionsStore.instance.toggleFollowing('alex');
        await tester.pump();
        expect(find.text('5'), findsNWidgets(2));
        ConnectionsStore.instance.toggleFollowing('alex');
        await ProfileStore.updateProfile(
          displayName: 'New Name',
          username: 'newname',
          bio: '',
        );
        await tester.pump();
        expect(find.text('2'), findsNWidgets(2));
        await tester.ensureVisible(find.text('Second upload'));
        await tester.tap(find.text('Second upload'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<VideoPostCard>(find.byType(VideoPostCard)).post.id,
          'second',
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        await tester.tap(find.text('Edit Profile'));
        await tester.pumpAndSettle();
        expect(find.byType(EditProfileScreen), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(1))
              .controller!
              .text,
          '@newname',
        );
      },
    );
  }

  testWidgets('all preferences survive route recreation and theme toggles', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SettingsScreen()));
    await tester.tap(toggle('Notifications'));
    await tester.pump();
    await tester.tap(toggle('Dark Mode'));
    await tester.pumpAndSettle();
    final mode = ThemeStore.themeMode.value;
    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();
    for (final title in [
      'Private Account',
      'Allow Comments',
      'Allow Sharing',
      'Activity Status',
    ]) {
      await tester.ensureVisible(toggle(title));
      await tester.tap(toggle(title));
      await tester.pumpAndSettle();
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app(const SettingsScreen()));
    expect(tester.widget<SwitchListTile>(toggle('Notifications')).value, false);
    expect(ThemeStore.themeMode.value, mode);
    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    for (final title in [
      'Private Account',
      'Allow Comments',
      'Allow Sharing',
      'Activity Status',
    ]) {
      await tester.ensureVisible(toggle(title));
      expect(
        tester.widget<SwitchListTile>(toggle(title)).value,
        title == 'Private Account',
      );
    }
    PreferencesStore.allowSharing.value = true;
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle('Allow Sharing')).value, true);
  });

  testWidgets(
    'Explore search, ten genres, clear, live results and exact navigation',
    (tester) async {
      DemoPostStore.posts.value = [
        post('music', username: '@Alice', caption: 'Piano #Music'),
        post('food', username: '@Bob', caption: 'Cake #Food'),
      ];
      await tester.pumpWidget(app(const ExploreScreen()));
      expect(find.byType(FilterChip), findsNWidgets(10));
      for (final query in ['PIANO', '@alice', '#mus']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pump();
        expect(find.text('Piano #Music'), findsOneWidget);
        expect(find.text('Cake #Food'), findsNothing);
      }
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilterChip, '#Food'));
      await tester.pump();
      expect(find.text('Piano #Music'), findsNothing);
      await tester.enterText(find.byType(TextField), 'absent');
      await tester.pump();
      expect(find.textContaining('No videos found'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      DemoPostStore.addPost(post('new-food', caption: 'New #Food'));
      await tester.pump();
      expect(find.text('New #Food'), findsOneWidget);
      await tester.tap(find.text('Cake #Food'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<VideoPostCard>(find.byType(VideoPostCard)).post.id,
        'food',
      );
    },
  );

  testWidgets('bottom tabs and upload return retain navigation', (
    tester,
  ) async {
    await tester.pumpWidget(app(const MainNavigationScreen()));
    await tester.pumpAndSettle();
    final nav = find.byType(NavigationBar);
    await tester.tap(find.descendant(of: nav, matching: find.text('Explore')));
    await tester.pumpAndSettle();
    expect(find.text('Discover'), findsOneWidget);
    await tester.tap(find.descendant(of: nav, matching: find.text('Upload')));
    await tester.pumpAndSettle();
    expect(find.byType(CreatePostScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.widget<NavigationBar>(nav).selectedIndex, 1);
    await tester.tap(find.descendant(of: nav, matching: find.text('Profile')));
    await tester.pumpAndSettle();
    expect(find.text('My Videos'), findsOneWidget);
    await tester.tap(find.descendant(of: nav, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(find.text('No videos yet'), findsOneWidget);
  });
}
