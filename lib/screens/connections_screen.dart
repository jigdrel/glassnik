import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/follow_service.dart';
import '../services/user_service.dart';
import 'user_profile_screen.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key, required this.title, this.uid});

  final String title;

  /// Whose followers/following list this shows. Defaults to the
  /// signed-in user — the only case used today (tapping the stats
  /// row on your own profile) — but any uid can be passed in later
  /// if you ever want to show someone else's followers/following.
  final String? uid;

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionUser {
  const _ConnectionUser({
    required this.uid,
    required this.displayName,
    required this.username,
  });

  final String uid;
  final String displayName;
  final String username;
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FollowService _followService = FollowService();
  final UserService _userService = UserService();

  String _searchText = '';

  bool get _showingFollowers => widget.title == 'Followers';

  String get _targetUid => widget.uid ?? AuthService().currentUser?.uid ?? '';

  List<_ConnectionUser> _filter(List<_ConnectionUser> users) {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.displayName.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _targetUid;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: uid.isEmpty
          ? const Center(
              child: Text(
                'Sign in to see this.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : StreamBuilder(
              stream: _showingFollowers
                  ? _followService.watchFollowers(uid)
                  : _followService.watchFollowing(uid),
              builder: (context, connectionSnapshot) {
                final docs = connectionSnapshot.data?.docs ?? [];
                final uids = docs.map((d) => d.id).toList();

                return FutureBuilder<List<_ConnectionUser>>(
                  // Re-fetches profile info whenever the follow list
                  // changes. Fine at this app's scale — a follower
                  // list search doesn't need to be instant-realtime
                  // on every field of every profile, just on who's
                  // in the list.
                  future: _loadProfiles(uids),
                  builder: (context, profilesSnapshot) {
                    final allUsers = profilesSnapshot.data ?? [];
                    final users = _filter(allUsers);
                    final isLoading =
                        connectionSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        profilesSnapshot.connectionState ==
                            ConnectionState.waiting;

                    return Column(
                      children: [
                        // SEARCH BAR
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),

                            onChanged: (value) {
                              setState(() {
                                _searchText = value;
                              });
                            },

                            decoration: InputDecoration(
                              hintText: widget.title == 'Followers'
                                  ? 'Search followers'
                                  : 'Search following',

                              hintStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),

                              prefixIcon: Icon(
                                Icons.search,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),

                              suffixIcon: _searchText.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchController.clear();

                                        setState(() {
                                          _searchText = '';
                                        });
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : null,

                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,

                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6C63FF),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // USER COUNT
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                          child: Row(
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const Spacer(),

                              Text(
                                '${users.length}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // LIST / EMPTY / LOADING
                        Expanded(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6C63FF),
                                  ),
                                )
                              : users.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_search_outlined,
                                        size: 50,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No users found',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: users.length,
                                  separatorBuilder: (_, _) => Divider(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    height: 1,
                                    indent: 72,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _UserTile(
                                      key: ValueKey(users[index].uid),
                                      user: users[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Future<List<_ConnectionUser>> _loadProfiles(List<String> uids) async {
    final profiles = await Future.wait(
      uids.map((uid) => _userService.getUserProfile(uid)),
    );

    final result = <_ConnectionUser>[];

    for (var i = 0; i < uids.length; i++) {
      final data = profiles[i];
      result.add(
        _ConnectionUser(
          uid: uids[i],
          displayName: (data?['displayName'] as String?) ?? 'Glassnik User',
          username: (data?['username'] as String?) ?? '@unknown',
        ),
      );
    }

    return result;
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({super.key, required this.user});

  final _ConnectionUser user;

  String get _initials {
    final trimmed = user.displayName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService().currentUser?.uid;
    final followService = FollowService();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(uid: user.uid),
          ),
        );
      },

      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF6C63FF),
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      title: Text(
        user.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        user.username,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),

      // No follow button for your own row, since you can't follow
      // yourself — everyone else gets a live Follow/Following button
      // reflecting whether the signed-in user follows THEM.
      trailing: (myUid == null || myUid == user.uid)
          ? null
          : SizedBox(
              height: 34,
              child: StreamBuilder<bool>(
                stream: followService.watchIsFollowing(
                  myUid: myUid,
                  theirUid: user.uid,
                ),
                builder: (context, snapshot) {
                  final following = snapshot.data ?? false;

                  return OutlinedButton(
                    onPressed: () async {
                      try {
                        if (following) {
                          await followService.unfollow(
                            myUid: myUid,
                            theirUid: user.uid,
                          );
                        } else {
                          await followService.follow(
                            myUid: myUid,
                            theirUid: user.uid,
                          );
                        }

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text(
                              following
                                  ? 'Unfollowed ${user.username}'
                                  : 'Now following ${user.username}',
                            ),
                          ),
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not update: $error')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: following
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : const Color(0xFF6C63FF),
                      foregroundColor: following
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white,
                      side: BorderSide(
                        color: following
                            ? Theme.of(context).colorScheme.outlineVariant
                            : const Color(0xFF6C63FF),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Text(
                      following ? 'Following' : 'Follow',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}