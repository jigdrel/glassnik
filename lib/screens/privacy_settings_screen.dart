import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _privateAccount = false;
  bool _activityStatus = true;
  bool _allowComments = true;
  bool _allowDownloads = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          const _SectionTitle(title: 'Account privacy'),

          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: const Text('Private account'),
            subtitle: const Text('Only approved followers can view your posts'),
            value: _privateAccount,
            onChanged: (value) {
              setState(() {
                _privateAccount = value;
              });
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.visibility_outlined),
            title: const Text('Activity status'),
            subtitle: const Text('Allow others to see when you are active'),
            value: _activityStatus,
            onChanged: (value) {
              setState(() {
                _activityStatus = value;
              });
            },
          ),

          const Divider(),

          const _SectionTitle(title: 'Interactions'),

          SwitchListTile(
            secondary: const Icon(Icons.comment_outlined),
            title: const Text('Allow comments'),
            subtitle: const Text('Allow people to comment on your posts'),
            value: _allowComments,
            onChanged: (value) {
              setState(() {
                _allowComments = value;
              });
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.download_outlined),
            title: const Text('Allow downloads'),
            subtitle: const Text('Allow people to download your shared videos'),
            value: _allowDownloads,
            onChanged: (value) {
              setState(() {
                _allowDownloads = value;
              });
            },
          ),

          const Divider(),

          const _SectionTitle(title: 'Safety'),

          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Blocked users'),
            subtitle: const Text('Manage accounts you have blocked'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessage('Blocked users will be connected later');
            },
          ),

          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Reporting'),
            subtitle: const Text('Learn about reporting inappropriate content'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessage('Reporting options will be added later');
            },
          ),

          const SizedBox(height: 24),
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
