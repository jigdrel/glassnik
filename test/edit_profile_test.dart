import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glassnik/screens/edit_profile_screen.dart';
import 'package:glassnik/services/profile_store.dart';
import 'package:image_picker/image_picker.dart';

final _photo = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
);

class _Picker extends ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => XFile.fromData(_photo, mimeType: 'image/png');
}

Future<void> _openEditor(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => EditProfileScreen(
                  initialUsername: ProfileStore.profile.value.username,
                  initialBio: ProfileStore.profile.value.bio,
                  imagePicker: _Picker(),
                ),
              ),
            ),
            child: const Text('Open editor'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

void main() {
  late UserProfile original;
  setUp(() {
    original = ProfileStore.profile.value;
    ProfileStore.profile.value = original.copyWith(
      displayName: 'Glassnik User',
      username: '@glassnik',
      bio: 'Hello',
      removeProfileImage: true,
    );
  });
  tearDown(() => ProfileStore.profile.value = original);

  for (final username in [
    '@',
    'ab',
    'john smith',
    'john!',
    'a' * 21,
    '@@sonam',
    ' sonam',
  ]) {
    testWidgets('rejects invalid username "$username" without saving', (
      tester,
    ) async {
      final before = ProfileStore.profile.value;
      await _openEditor(tester);
      await tester.enterText(find.byType(TextField).at(1), username);
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.textContaining('Username must be 3'), findsOneWidget);
      expect(ProfileStore.profile.value, same(before));
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });
  }

  for (final username in [
    '@sonam',
    'sonam_123',
    'glassnikuser',
    'abc',
    'a' * 20,
  ]) {
    testWidgets('saves valid username "$username" and trimmed text', (
      tester,
    ) async {
      await _openEditor(tester);
      await tester.enterText(find.byType(TextField).at(0), '  Sonam  ');
      await tester.enterText(find.byType(TextField).at(1), username);
      await tester.enterText(find.byType(TextField).at(2), '  Hello world  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final profile = ProfileStore.profile.value;
      expect(
        profile.username,
        username.startsWith('@') ? username : '@$username',
      );
      expect(profile.displayName, 'Sonam');
      expect(profile.bio, 'Hello world');
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('Profile saved.'), findsOneWidget);
    });
  }

  testWidgets('rejects short display names and overlong bio', (tester) async {
    final before = ProfileStore.profile.value;
    await _openEditor(tester);
    for (final name in ['  ', ' A ']) {
      await tester.enterText(find.byType(TextField).at(0), name);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(ProfileStore.profile.value, same(before));
      expect(
        find.text('Display name must contain at least 2 characters.'),
        findsOneWidget,
      );
    }
    await tester.enterText(find.byType(TextField).at(0), 'Al');
    // Set the controller directly to exercise Save validation beyond the input limit.
    tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text =
        'a' * 121;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(ProfileStore.profile.value, same(before));
    expect(find.text('Bio must be 120 characters or less.'), findsOneWidget);
    tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text =
        'a' * 120;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(ProfileStore.profile.value.bio.length, 120);
  });

  testWidgets('photo preview and text changes are discarded on back', (
    tester,
  ) async {
    final before = ProfileStore.profile.value;
    await _openEditor(tester);
    await tester.tap(find.text('Change profile photo'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(ProfileStore.profile.value, same(before));
    await tester.enterText(find.byType(TextField).at(0), 'Changed');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(ProfileStore.profile.value, same(before));
  });

  testWidgets('save applies photo and text in one notification', (
    tester,
  ) async {
    await _openEditor(tester);
    var notifications = 0;
    void listener() => notifications++;
    ProfileStore.profile.addListener(listener);
    addTearDown(() => ProfileStore.profile.removeListener(listener));
    await tester.tap(find.text('Change profile photo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Sonam');
    expect(notifications, 0);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(notifications, 1);
    expect(ProfileStore.profile.value.displayName, 'Sonam');
    expect(ProfileStore.profile.value.profileImageBytes, orderedEquals(_photo));
  });

  for (final save in [false, true]) {
    testWidgets('remove photo is ${save ? "saved" : "discarded on Cancel"}', (
      tester,
    ) async {
      ProfileStore.profile.value = ProfileStore.profile.value.copyWith(
        profileImageBytes: Uint8List.fromList(_photo),
      );
      final before = ProfileStore.profile.value;
      await _openEditor(tester);
      await tester.tap(find.text('Remove Photo'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      expect(ProfileStore.profile.value, same(before));
      if (save) {
        await tester.tap(find.text('Save'));
      } else {
        await tester.ensureVisible(find.text('Cancel'));
        await tester.tap(find.text('Cancel'));
      }
      await tester.pumpAndSettle();
      if (save) {
        expect(ProfileStore.profile.value.profileImageBytes, isNull);
      } else {
        expect(ProfileStore.profile.value, same(before));
      }
    });
  }
}
