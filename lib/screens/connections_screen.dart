import 'package:flutter/material.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<ConnectionsScreen> createState() =>
      _ConnectionsScreenState();
}

class _ConnectionsScreenState
    extends State<ConnectionsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  bool get _showingFollowers {
    return widget.title == 'Followers';
  }

  List<DemoUser> get _allUsers {
    if (_showingFollowers) {
      return const [
        DemoUser(
          name: 'Alex Chen',
          username: '@alexchen',
          initials: 'AC',
        ),
        DemoUser(
          name: 'Maya Wilson',
          username: '@mayaw',
          initials: 'MW',
        ),
        DemoUser(
          name: 'Noah Lee',
          username: '@noahlee',
          initials: 'NL',
        ),
        DemoUser(
          name: 'Emma Davis',
          username: '@emmad',
          initials: 'ED',
        ),
        DemoUser(
          name: 'Leo Martin',
          username: '@leom',
          initials: 'LM',
        ),
      ];
    }

    return const [
      DemoUser(
        name: 'Sofia Kim',
        username: '@sofiak',
        initials: 'SK',
      ),
      DemoUser(
        name: 'Ethan Brown',
        username: '@ethanb',
        initials: 'EB',
      ),
      DemoUser(
        name: 'Olivia Smith',
        username: '@olivias',
        initials: 'OS',
      ),
      DemoUser(
        name: 'Daniel Wong',
        username: '@danielw',
        initials: 'DW',
      ),
    ];
  }

  List<DemoUser> get _filteredUsers {
    final query =
        _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return _allUsers;
    }

    return _allUsers.where((user) {
      return user.name
              .toLowerCase()
              .contains(query) ||
          user.username
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              14,
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.white,
              ),

              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },

              decoration: InputDecoration(
                hintText: widget.title == 'Followers'
                    ? 'Search followers'
                    : 'Search following',

                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),

                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchText = '';
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                        ),
                      )
                    : null,

                filled: true,
                fillColor:
                    const Color(0xFF1C1C1C),

                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(
                    color: Colors.white10,
                  ),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(
                    color:
                        Color(0xFF6C63FF),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // USER COUNT
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              0,
              18,
              8,
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  '${users.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // LIST / EMPTY SEARCH RESULT
          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .person_search_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No users found',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: users.length,

                    // Using wildcard parameters avoids
                    // the analyzer warning about "__".
                    separatorBuilder:
                        (_, _) =>
                            const Divider(
                      color: Colors.white10,
                      height: 1,
                      indent: 72,
                    ),

                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return _UserTile(
                        user: users[index],
                        showingFollowers:
                            _showingFollowers,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// DEMO USER
// ==========================================================

class DemoUser {
  const DemoUser({
    required this.name,
    required this.username,
    required this.initials,
  });

  final String name;
  final String username;
  final String initials;
}

// ==========================================================
// USER TILE
// ==========================================================

class _UserTile extends StatefulWidget {
  const _UserTile({
    required this.user,
    required this.showingFollowers,
  });

  final DemoUser user;
  final bool showingFollowers;

  @override
  State<_UserTile> createState() =>
      _UserTileState();
}

class _UserTileState
    extends State<_UserTile> {
  bool _following = false;

  @override
  void initState() {
    super.initState();

    // Following page starts with users followed.
    // Followers page starts with Follow button.
    _following =
        !widget.showingFollowers;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),

      leading: CircleAvatar(
        radius: 24,
        backgroundColor:
            const Color(0xFF6C63FF),

        child: Text(
          widget.user.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      title: Text(
        widget.user.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        widget.user.username,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),

      trailing: SizedBox(
        height: 34,

        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _following = !_following;
            });

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                duration:
                    const Duration(
                  seconds: 1,
                ),
                content: Text(
                  _following
                      ? 'Now following ${widget.user.username}'
                      : 'Unfollowed ${widget.user.username}',
                ),
              ),
            );
          },

          style:
              OutlinedButton.styleFrom(
            backgroundColor: _following
                ? const Color(0xFF1C1C1C)
                : const Color(0xFF6C63FF),

            foregroundColor:
                Colors.white,

            side: BorderSide(
              color: _following
                  ? Colors.white24
                  : const Color(
                      0xFF6C63FF,
                    ),
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
            ),
          ),

          child: Text(
            _following
                ? 'Following'
                : 'Follow',
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}