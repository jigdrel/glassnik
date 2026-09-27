import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glassnik/screens/connections_screen.dart';
import 'package:glassnik/services/connections_store.dart';

void main() {
  test('follow back and unfollow update counts without removing followers', () {
    final store = ConnectionsStore();
    addTearDown(store.dispose);
    var notifications = 0;
    store.addListener(() => notifications++);

    expect(store.followerCount, 5);
    expect(store.followingCount, 4);
    store.toggleFollowing('alex');
    expect(store.followingCount, 5);
    expect(store.following.map((user) => user.id), contains('alex'));
    store.toggleFollowing('alex');
    expect(store.followingCount, 4);
    expect(store.followers.map((user) => user.id), contains('alex'));
    store.toggleFollowing('sofia');
    expect(store.followingCount, 3);
    expect(store.following.map((user) => user.id), isNot(contains('sofia')));
    expect(store.followerCount, 5);
    expect(notifications, 3);
  });

  testWidgets(
    'filtering preserves follow identity and reopening shares state',
    (tester) async {
      final store = ConnectionsStore.instance;
      addTearDown(() {
        if (store.isFollowing('alex')) store.toggleFollowing('alex');
      });
      await tester.pumpWidget(
        const MaterialApp(home: ConnectionsScreen(title: 'Followers')),
      );
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.pump();
      await tester.tap(find.text('Follow'));
      await tester.pump();
      expect(find.text('Following'), findsOneWidget);
      expect(store.followingCount, 5);

      await tester.enterText(find.byType(TextField), 'Maya');
      await tester.pump();
      expect(find.text('Follow'), findsOneWidget);
      expect(find.text('Following'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.pump();
      expect(find.text('Following'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        const MaterialApp(home: ConnectionsScreen(title: 'Following')),
      );
      await tester.enterText(find.byType(TextField), '@alexchen');
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Following'));
      await tester.pump();
      expect(find.text('Alex Chen'), findsNothing);
      expect(store.followingCount, 4);
      expect(store.followerCount, 5);
    },
  );
}
