import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../widgets/profile_menu_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openInfoPage(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String body,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return _StaticInfoScreen(title: title, icon: icon, body: body);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: 'App Theme',
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              secondary: const Icon(
                Icons.dark_mode_outlined,
                color: Color(0xFF1976D2),
              ),
              title: const Text(
                'Dark mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Use a darker app appearance'),
              value: settings.isDarkMode,
              onChanged: settings.setDarkMode,
            ),
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Privacy & Security',
            child: Column(
              children: [
                ProfileMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How GoCare handles your data',
                  onTap: () {
                    _openInfoPage(
                      context,
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      body:
                          'GoCare stores profile and health information only to support your care and emergency workflows. Keep sensitive information accurate and remove anything you do not want saved.',
                    );
                  },
                ),
                const Divider(height: 1, indent: 74),
                ProfileMenuTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Use of GoCare services',
                  onTap: () {
                    _openInfoPage(
                      context,
                      title: 'Terms & Conditions',
                      icon: Icons.description_outlined,
                      body:
                          'GoCare helps organize health, nearby care, first aid, and emergency contact information. It does not replace professional medical advice or emergency services.',
                    );
                  },
                ),
                const Divider(height: 1, indent: 74),
                ProfileMenuTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Data & Permissions',
                  subtitle: 'Location, account, and stored health data',
                  onTap: () {
                    _openInfoPage(
                      context,
                      title: 'Data & Permissions',
                      icon: Icons.admin_panel_settings_outlined,
                      body:
                          'GoCare may ask for permissions such as location to find nearby healthcare services. You can manage app permissions from your device settings.',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'About',
            child: Column(
              children: [
                ProfileMenuTile(
                  icon: Icons.info_outline,
                  title: 'About GoCare',
                  subtitle: 'Healthcare and emergency assistance',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'GoCare',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          'Healthcare and emergency assistance application.',
                    );
                  },
                ),
                const Divider(height: 1, indent: 74),
                ProfileMenuTile(
                  icon: Icons.system_update_outlined,
                  title: 'App Version',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    _openInfoPage(
                      context,
                      title: 'App Version',
                      icon: Icons.system_update_outlined,
                      body: 'GoCare version 1.0.0, build 1.',
                    );
                  },
                ),
                const Divider(height: 1, indent: 74),
                ProfileMenuTile(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  subtitle: 'Get support for GoCare',
                  onTap: () {
                    _openInfoPage(
                      context,
                      title: 'Contact Us',
                      icon: Icons.contact_support_outlined,
                      body:
                          'For help with GoCare, contact the support team from your registered email and include details about the issue you are facing.',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172B4D),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _StaticInfoScreen extends StatelessWidget {
  const _StaticInfoScreen({
    required this.title,
    required this.icon,
    required this.body,
  });

  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF1976D2)),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
