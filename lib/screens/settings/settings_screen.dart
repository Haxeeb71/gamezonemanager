import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Business Information'),
            subtitle: const Text('Update your business details'),
            onTap: () {
              // TODO: Implement business info settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Payment Settings'),
            subtitle: const Text('Configure payment methods and rates'),
            onTap: () {
              // TODO: Implement payment settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.notification_important),
            title: const Text('Notifications'),
            subtitle: const Text('Configure alert preferences'),
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Manage your data'),
            onTap: () {
              // TODO: Implement backup & restore
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            subtitle: const Text('Get assistance'),
            onTap: () {
              // TODO: Implement help & support
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('App information and version'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'GameZone Manager',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.games, size: 48),
                children: const [
                  Text('A complete gaming café management solution.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
