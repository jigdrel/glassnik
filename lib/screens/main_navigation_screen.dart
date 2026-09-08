import 'package:flutter/material.dart';

import 'create_post_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen
    extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen>
      createState() =>
          _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ExploreScreen(),

    // Upload uses its own route,
    // so this page is never displayed.
    SizedBox.shrink(),

    ProfileScreen(),
  ];

  Future<void> _onNavigationTap(
    int index,
  ) async {
    // ==========================================
    // UPLOAD
    // ==========================================

    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const CreatePostScreen(),
        ),
      );

      return;
    }

    // ==========================================
    // HOME / EXPLORE / PROFILE
    // ==========================================

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // IndexedStack keeps each tab alive.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // ==========================================
      // BOTTOM NAVIGATION
      // ==========================================

      bottomNavigationBar:
          Container(
        decoration:
            const BoxDecoration(
          border: Border(
            top: BorderSide(
              color:
                  Color(
                0xFF2A2A2A,
              ),
              width: 1,
            ),
          ),
        ),

        child: NavigationBar(
          height: 70,

          selectedIndex:
              _selectedIndex,

          onDestinationSelected:
              _onNavigationTap,

          backgroundColor:
              const Color(
            0xFF111111,
          ),

          indicatorColor:
              const Color(
            0xFF6C63FF,
          ),

          labelBehavior:
              NavigationDestinationLabelBehavior
                  .alwaysShow,

          destinations:
              const [
            // HOME
            NavigationDestination(
              icon: Icon(
                Icons
                    .home_outlined,
              ),

              selectedIcon:
                  Icon(
                Icons.home,
                color:
                    Colors.white,
              ),

              label: 'Home',
            ),

            // EXPLORE
            NavigationDestination(
              icon: Icon(
                Icons
                    .explore_outlined,
              ),

              selectedIcon:
                  Icon(
                Icons.explore,
                color:
                    Colors.white,
              ),

              label:
                  'Explore',
            ),

            // UPLOAD
            NavigationDestination(
              icon: Icon(
                Icons
                    .add_box_outlined,
              ),

              selectedIcon:
                  Icon(
                Icons.add_box,
                color:
                    Colors.white,
              ),

              label:
                  'Upload',
            ),

            // PROFILE
            NavigationDestination(
              icon: Icon(
                Icons
                    .person_outline,
              ),

              selectedIcon:
                  Icon(
                Icons.person,
                color:
                    Colors.white,
              ),

              label:
                  'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
