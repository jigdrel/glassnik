import 'dart:async';

import 'package:flutter/material.dart';

import '../services/user_service.dart';
import 'user_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();

  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _userService.searchUsersByUsername(query);

      if (!mounted) return;

      setState(() {
        _results = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _results = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $error')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isShowingSearch = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: const TextStyle(color: Colors.white38),

                prefixIcon: const Icon(Icons.search, color: Colors.grey),

                suffixIcon: isShowingSearch
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close, color: Colors.grey),
                      )
                    : null,

                filled: true,
                fillColor: const Color(0xFF1C1C1C),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (isShowingSearch) ...[
              Expanded(child: _buildSearchResults()),
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                'Discover',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('#Trending')),
                  Chip(label: Text('#Music')),
                  Chip(label: Text('#Gaming')),
                  Chip(label: Text('#Travel')),
                  Chip(label: Text('#Funny')),
                  Chip(label: Text('#Food')),
                ],
              ),
              const Spacer(),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.explore_outlined, size: 65, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Search for a username above,\nor check back for more discovery features.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (_hasSearched && _results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 12),
            Text('No users found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          const Divider(color: Colors.white10, height: 1, indent: 72),
      itemBuilder: (context, index) {
        final user = _results[index];
        final uid = user['uid'] as String?;
        final displayName = (user['displayName'] as String?) ?? 'Glassnik User';
        final username = (user['username'] as String?) ?? '@unknown';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          leading: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF6C63FF),
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(username, style: const TextStyle(color: Colors.grey)),
          onTap: uid == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(uid: uid),
                    ),
                  );
                },
        );
      },
    );
  }
}