import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState
    extends State<PrivacySettingsScreen> {
  bool _privateAccount = false;
  bool _allowComments = true;
  bool _allowSharing = true;
  bool _activityStatus = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Privacy',
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
          const Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              8,
            ),
            child: Text(
              'ACCOUNT PRIVACY',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),

          SwitchListTile(
            value: _privateAccount,
            activeThumbColor: const Color(0xFF6C63FF),
            secondary: const Icon(
              Icons.lock_outline,
              color: Colors.white70,
            ),
            title: const Text(
              'Private Account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Only approved followers can see your videos.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _privateAccount = value;
              });

              _showMessage(
                value
                    ? 'Private account enabled'
                    : 'Private account disabled',
              );
            },
          ),

          const Divider(
            color: Colors.white12,
            height: 28,
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              8,
              18,
              8,
            ),
            child: Text(
              'INTERACTIONS',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),

          SwitchListTile(
            value: _allowComments,
            activeThumbColor: const Color(0xFF6C63FF),
            secondary: const Icon(
              Icons.comment_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'Allow Comments',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'Allow other users to comment on your videos.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _allowComments = value;
              });

              _showMessage(
                value
                    ? 'Comments enabled'
                    : 'Comments disabled',
              );
            },
          ),

          SwitchListTile(
            value: _allowSharing,
            activeThumbColor: const Color(0xFF6C63FF),
            secondary: const Icon(
              Icons.share_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'Allow Sharing',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'Allow users to share your videos.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _allowSharing = value;
              });

              _showMessage(
                value
                    ? 'Video sharing enabled'
                    : 'Video sharing disabled',
              );
            },
          ),

          const Divider(
            color: Colors.white12,
            height: 28,
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              8,
              18,
              8,
            ),
            child: Text(
              'ACTIVITY',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),

          SwitchListTile(
            value: _activityStatus,
            activeThumbColor: const Color(0xFF6C63FF),
            secondary: const Icon(
              Icons.visibility_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'Activity Status',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'Allow other users to see when you are active.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _activityStatus = value;
              });

              _showMessage(
                value
                    ? 'Activity status visible'
                    : 'Activity status hidden',
              );
            },
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color(0xFF6C63FF),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Privacy settings are currently stored locally for the demo. Backend persistence will be added later.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
