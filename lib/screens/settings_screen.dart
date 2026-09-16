import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_store.dart';
import '../services/theme_store.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'privacy_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  final AuthService _authService = AuthService();

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
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
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

    // Actually end the Firebase session.
    await _authService.signOut();

    if (!mounted) {
      return;
    }

    // Send the user back to LoginScreen and clear every
    // screen underneath so they cannot navigate back into
    // the logged-in app.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.profile.value;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF5F5F7);

    final primaryText =
        isDark ? Colors.white : Colors.black87;

    final secondaryText =
        isDark ? Colors.grey : Colors.black54;

    final iconColor =
        isDark ? Colors.white70 : Colors.black54;

    final dividerColor =
        isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: primaryText,
        title: Text(
          'Settings',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          const _SectionTitle(
            title: 'Account',
          ),

          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Name, username and bio',
            primaryText: primaryText,
            secondaryText: secondaryText,
            iconColor: iconColor,
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
            primaryText: primaryText,
            secondaryText: secondaryText,
            iconColor: iconColor,
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

          Divider(
            color: dividerColor,
            height: 30,
          ),

          const _SectionTitle(
            title: 'Preferences',
          ),

          SwitchListTile(
            value: _notificationsEnabled,
            activeThumbColor: const Color(0xFF6C63FF),
            secondary: Icon(
              Icons.notifications_outlined,
              color: iconColor,
            ),
            title: Text(
              'Notifications',
              style: TextStyle(
                color: primaryText,
              ),
            ),
            subtitle: Text(
              'Receive activity notifications',
              style: TextStyle(
                color: secondaryText,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          // REAL DARK MODE SWITCH
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeStore.themeMode,
            builder: (
              context,
              themeMode,
              child,
            ) {
              final darkEnabled =
                  themeMode == ThemeMode.dark;

              return SwitchListTile(
                value: darkEnabled,
                activeThumbColor:
                    const Color(0xFF6C63FF),
                secondary: Icon(
                  darkEnabled
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: iconColor,
                ),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: primaryText,
                  ),
                ),
                subtitle: Text(
                  darkEnabled
                      ? 'Use Glassnik dark appearance'
                      : 'Use Glassnik light appearance',
                  style: TextStyle(
                    color: secondaryText,
                  ),
                ),
                onChanged: (value) {
                  ThemeStore.setDarkMode(value);
                },
              );
            },
          ),

          Divider(
            color: dividerColor,
            height: 30,
          ),

          const _SectionTitle(
            title: 'About',
          ),

          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Glassnik',
            subtitle: 'Version 1.0 demo',
            primaryText: primaryText,
            secondaryText: secondaryText,
            iconColor: iconColor,
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
            primaryText: primaryText,
            secondaryText: secondaryText,
            iconColor: iconColor,
            onTap: () {
              _showComingSoon('Help & Support');
            },
          ),

          Divider(
            color: dividerColor,
            height: 30,
          ),

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

          Center(
            child: Text(
              'Glassnik • Demo Version',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryText,
    required this.secondaryText,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryText;
  final Color secondaryText;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: secondaryText,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: secondaryText,
      ),
      onTap: onTap,
    );
  }
}
