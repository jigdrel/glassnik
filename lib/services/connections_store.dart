import 'package:flutter/foundation.dart';

class DemoUser {
  const DemoUser({
    required this.id,
    required this.name,
    required this.username,
    required this.initials,
  });

  final String id;
  final String name;
  final String username;
  final String initials;
}

/// Shared demo relationships. Changes last until the app is restarted.
class ConnectionsStore extends ChangeNotifier {
  ConnectionsStore();

  static final ConnectionsStore instance = ConnectionsStore();

  static const users = [
    DemoUser(
      id: 'alex',
      name: 'Alex Chen',
      username: '@alexchen',
      initials: 'AC',
    ),
    DemoUser(
      id: 'maya',
      name: 'Maya Wilson',
      username: '@mayaw',
      initials: 'MW',
    ),
    DemoUser(
      id: 'noah',
      name: 'Noah Lee',
      username: '@noahlee',
      initials: 'NL',
    ),
    DemoUser(
      id: 'emma',
      name: 'Emma Davis',
      username: '@emmad',
      initials: 'ED',
    ),
    DemoUser(id: 'leo', name: 'Leo Martin', username: '@leom', initials: 'LM'),
    DemoUser(
      id: 'sofia',
      name: 'Sofia Kim',
      username: '@sofiak',
      initials: 'SK',
    ),
    DemoUser(
      id: 'ethan',
      name: 'Ethan Brown',
      username: '@ethanb',
      initials: 'EB',
    ),
    DemoUser(
      id: 'olivia',
      name: 'Olivia Smith',
      username: '@olivias',
      initials: 'OS',
    ),
    DemoUser(
      id: 'daniel',
      name: 'Daniel Wong',
      username: '@danielw',
      initials: 'DW',
    ),
  ];

  final Set<String> _followerIds = {'alex', 'maya', 'noah', 'emma', 'leo'};
  final Set<String> _followingIds = {'sofia', 'ethan', 'olivia', 'daniel'};

  List<DemoUser> get followers =>
      List.unmodifiable(users.where((user) => _followerIds.contains(user.id)));

  List<DemoUser> get following =>
      List.unmodifiable(users.where((user) => _followingIds.contains(user.id)));

  int get followerCount => _followerIds.length;
  int get followingCount => _followingIds.length;

  bool isFollowing(String userId) => _followingIds.contains(userId);

  void toggleFollowing(String userId) {
    if (!users.any((user) => user.id == userId)) {
      throw ArgumentError.value(userId, 'userId', 'Unknown demo user');
    }
    if (!_followingIds.remove(userId)) {
      _followingIds.add(userId);
    }
    notifyListeners();
  }
}
