import 'package:flutter/material.dart';

import '../services/profile_store.dart';
import 'edit_profile_screen.dart';
import 'privacy_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon.'),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Logged out successfully (demo).',
        ),
      ),
    );

    // For the current demo this returns to the app root.
    // Later we can connect this directly to LoginScreen/Firebase Auth.
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.profile.value;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          // ==================================================
          // ACCOUNT
          // ==================================================

          const _SectionTitle(
            title: 'Account',
          ),

          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Name, username and bio',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    initialUsername: profile.username,
                    initialBio: profile.bio,
                  ),
                ),
              );
            },
          ),

          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            subtitle: 'Manage your privacy settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PrivacySettingsScreen(),
                ),
              );
            },
          ),

          const Divider(
            color: Colors.white12,
            height: 30,
          ),

          // ==================================================
          // PREFERENCES
          // ==================================================

          const _SectionTitle(
            title: 'Preferences',
          ),

          SwitchListTile(
            value: _notificationsEnabled,
            activeThumbColor: const Color(0xFF6C63FF),
            secondary: const Icon(
              Icons.notifications_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'Receive activity notifications',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          SwitchListTile(
            value: _darkModeEnabled,
            activeThumbColor: const Color(0xFF6C63FF),
            secondary: const Icon(
              Icons.dark_mode_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'Dark Mode',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'Use Glassnik dark appearance',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });

              _showComingSoon(
                'Full theme switching',
              );
            },
          ),

          const Divider(
            color: Colors.white12,
            height: 30,
          ),

          // ==================================================
          // SUPPORT / ABOUT
          // ==================================================

          const _SectionTitle(
            title: 'About',
          ),

          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Glassnik',
            subtitle: 'Version 1.0 demo',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Glassnik',
                applicationVersion: '1.0.0 Demo',
                applicationIcon: const Icon(
                  Icons.play_circle_fill,
                  size: 42,
                  color: Color(0xFF6C63FF),
                ),
                children: const [
                  Text(
                    'Glassnik is a short-form social video application for discovering, uploading and sharing videos.',
                  ),
                ],
              );
            },
          ),

          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help using Glassnik',
            onTap: () {
              _showComingSoon(
                'Help & Support',
              );
            },
          ),

          const Divider(
            color: Colors.white12,
            height: 30,
          ),

          // ==================================================
          // LOG OUT
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: _showLogoutDialog,
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              'Glassnik • Demo Version',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SECTION TITLE
// ======================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        8,
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ======================================================
// SETTINGS TILE
// ======================================================

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white70,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
      ),
      onTap: onTap,
    );
  }
}
