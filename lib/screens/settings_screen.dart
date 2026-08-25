import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldLogout != true) {
      return;
    }

    _showMessage('Logout will be connected to authentication later');
  }

  void _openAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Glassnik',
      applicationVersion: 'Prototype 1.0',
      applicationLegalese: 'POV video sharing application',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          const _SectionTitle(title: 'Account'),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account details'),
            subtitle: const Text('Manage your profile information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessage('Account details will be added later');
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            subtitle: const Text('Manage your privacy preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessage('Privacy settings will be added later');
            },
          ),

          const Divider(),

          const _SectionTitle(title: 'Preferences'),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Receive updates and activity notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Use dark appearance'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });

              _showMessage('Theme switching will be connected later');
            },
          ),

          const Divider(),

          const _SectionTitle(title: 'Support'),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            subtitle: const Text('Get help using Glassnik'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessage('Help section will be added later');
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Glassnik'),
            subtitle: const Text('App information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openAbout,
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: Icon(Icons.logout, color: theme.colorScheme.error),
              label: Text(
                'Log out',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
