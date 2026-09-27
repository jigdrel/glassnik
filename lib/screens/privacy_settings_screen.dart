import 'package:flutter/material.dart';
import '../services/preferences_store.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        PreferencesStore.privateAccount,
        PreferencesStore.allowComments,
        PreferencesStore.allowSharing,
        PreferencesStore.activityStatus,
      ]),
      builder: (context, child) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Privacy',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: ListView(
          padding: EdgeInsets.only(bottom: 30),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
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
              value: PreferencesStore.privateAccount.value,
              activeThumbColor: Color(0xFF6C63FF),
              secondary: Icon(
                Icons.lock_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Private Account',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Prefer video visibility for approved followers.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  PreferencesStore.privateAccount.value = value;
                });

                _showMessage('Preference saved for this session.');
              },
            ),

            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              height: 28,
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 8),
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
              value: PreferencesStore.allowComments.value,
              activeThumbColor: Color(0xFF6C63FF),
              secondary: Icon(
                Icons.comment_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Allow Comments',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Save your preference for comments.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  PreferencesStore.allowComments.value = value;
                });

                _showMessage('Preference saved for this session.');
              },
            ),

            SwitchListTile(
              value: PreferencesStore.allowSharing.value,
              activeThumbColor: Color(0xFF6C63FF),
              secondary: Icon(
                Icons.share_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Allow Sharing',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Save your preference for sharing.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  PreferencesStore.allowSharing.value = value;
                });

                _showMessage('Preference saved for this session.');
              },
            ),

            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              height: 28,
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 8),
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
              value: PreferencesStore.activityStatus.value,
              activeThumbColor: Color(0xFF6C63FF),
              secondary: Icon(
                Icons.visibility_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Activity Status',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Save your preference for activity visibility.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  PreferencesStore.activityStatus.value = value;
                });

                _showMessage('Preference saved for this session.');
              },
            ),

            SizedBox(height: 30),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
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
                        'These preferences last for this app session only. They do not restrict video access, comments, sharing or activity visibility.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}
