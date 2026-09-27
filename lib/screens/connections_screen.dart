import 'package:flutter/material.dart';

import '../services/connections_store.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key, required this.title});

  final String title;

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  bool get _showingFollowers {
    return widget.title == 'Followers';
  }

  final ConnectionsStore _connections = ConnectionsStore.instance;

  List<DemoUser> get _allUsers =>
      _showingFollowers ? _connections.followers : _connections.following;

  List<DemoUser> get _filteredUsers {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return _allUsers;
    }

    return _allUsers.where((user) {
      return user.name.toLowerCase().contains(query) ||
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
    return ListenableBuilder(
      listenable: _connections,
      builder: (context, child) {
        final users = _filteredUsers;
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

          body: Column(
            children: [
              // SEARCH BAR
              Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),

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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),

                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

                    contentPadding: EdgeInsets.symmetric(vertical: 12),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Color(0xFF6C63FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // USER COUNT
              Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Spacer(),

                    Text(
                      '${users.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // LIST / EMPTY SEARCH RESULT
              Expanded(
                child: users.isEmpty
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
                            SizedBox(height: 12),
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

                        // Using wildcard parameters avoids
                        // the analyzer warning about "__".
                        separatorBuilder: (_, _) => Divider(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          height: 1,
                          indent: 72,
                        ),

                        itemBuilder: (context, index) {
                          return _UserTile(
                            key: ValueKey(users[index].id),
                            user: users[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({super.key, required this.user});

  final DemoUser user;

  @override
  Widget build(BuildContext context) {
    final connections = ConnectionsStore.instance;
    final following = connections.isFollowing(user.id);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF6C63FF),

        child: Text(
          user.initials,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      title: Text(
        user.name,
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

      trailing: SizedBox(
        height: 34,

        child: OutlinedButton(
          onPressed: () {
            connections.toggleFollowing(user.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1),
                content: Text(
                  connections.isFollowing(user.id)
                      ? 'Now following ${user.username}'
                      : 'Unfollowed ${user.username}',
                ),
              ),
            );
          },

          style: OutlinedButton.styleFrom(
            backgroundColor: following
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Color(0xFF6C63FF),

            foregroundColor: following
                ? Theme.of(context).colorScheme.onSurface
                : Colors.white,

            side: BorderSide(
              color: following
                  ? Theme.of(context).colorScheme.outlineVariant
                  : Color(0xFF6C63FF),
            ),

            padding: EdgeInsets.symmetric(horizontal: 12),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),

          child: Text(
            following ? 'Following' : 'Follow',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
