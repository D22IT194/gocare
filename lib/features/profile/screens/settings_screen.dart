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
        builder: (_) => _StaticInfoScreen(
          title: title,
          icon: icon,
          body: body,
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  22,
                  22,
                  16,
                  20,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.support_agent_outlined,
                        color: Color(0xFF1976D2),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Us',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'We are here to help',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Text(
                      'Need help with GoCare?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'For support, account issues, or feedback, '
                      'please contact the GoCare support team.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _SupportInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: 'support@gocare.app',
                    ),

                    const SizedBox(height: 10),

                    _SupportInfoTile(
                      icon: Icons.access_time_outlined,
                      title: 'Support Hours',
                      value: 'Monday – Friday',
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Support email option will be available soon.',
                              ),
                              behavior:
                                  SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.mail_outline,
                        ),
                        label: const Text(
                          'Contact Support',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(50),
                          backgroundColor:
                              const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  size: 38,
                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'GoCare',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Healthcare & Emergency Assistance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: const Text(
                  'Version 1.0.0 • Build 1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475467),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'GoCare helps you organize your health '
                'information, emergency contacts, first-aid '
                'resources and nearby healthcare services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF667085),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settings =
        context.read<SettingsProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 22),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'App Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose how GoCare should look.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF667085),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _ThemeOption(
                icon: Icons.light_mode_outlined,
                title: 'Light',
                subtitle: 'Use light appearance',
                selected: !settings.isDarkMode,
                onTap: () {
                  settings.setDarkMode(false);
                  Navigator.pop(sheetContext);
                },
              ),

              const SizedBox(height: 10),

              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                title: 'Dark',
                subtitle: 'Use dark appearance',
                selected: settings.isDarkMode,
                onTap: () {
                  settings.setDarkMode(true);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            30,
          ),
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Customize your GoCare experience.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // APPEARANCE
            // ==================================================

            _Section(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: settings.isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    title: 'App Theme',
                    subtitle: settings.isDarkMode
                        ? 'Dark mode enabled'
                        : 'Light mode enabled',
                    onTap: () {
                      _showThemeDialog(context);
                    },
                  ),

                  const Divider(
                    height: 1,
                    indent: 74,
                  ),

                  SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    secondary: const Icon(
                      Icons.dark_mode_outlined,
                      color: Color(0xFF1976D2),
                    ),
                    title: const Text(
                      'Dark mode',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Quickly switch dark appearance',
                    ),
                    value: settings.isDarkMode,
                    onChanged:
                        settings.setDarkMode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PRIVACY
            // ==================================================

            _Section(
              title: 'Privacy & Security',
              icon: Icons.shield_outlined,
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle:
                        'How GoCare handles your data',
                    onTap: () {
                      _openInfoPage(
                        context,
                        title: 'Privacy Policy',
                        icon:
                            Icons.privacy_tip_outlined,
                        body:
                            'GoCare stores profile, health, '
                            'and emergency information to '
                            'support healthcare and emergency '
                            'workflows.\n\n'
                            'Your information should be kept '
                            'accurate and up to date. Avoid '
                            'adding information that you do '
                            'not want stored in your account.\n\n'
                            'You can manage device permissions '
                            'through your Android or iOS '
                            'system settings.',
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                    indent: 74,
                  ),

                  ProfileMenuTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle:
                        'Rules for using GoCare',
                    onTap: () {
                      _openInfoPage(
                        context,
                        title:
                            'Terms & Conditions',
                        icon:
                            Icons.description_outlined,
                        body:
                            'GoCare is designed to help '
                            'organize health information, '
                            'emergency contacts, first-aid '
                            'resources, and nearby healthcare '
                            'services.\n\n'
                            'GoCare does not replace doctors, '
                            'hospitals, professional medical '
                            'advice, or emergency services.\n\n'
                            'Always contact appropriate '
                            'emergency services when immediate '
                            'medical assistance is required.',
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                    indent: 74,
                  ),

                  ProfileMenuTile(
                    icon:
                        Icons.admin_panel_settings_outlined,
                    title: 'Data & Permissions',
                    subtitle:
                        'Manage access to device data',
                    onTap: () {
                      _openInfoPage(
                        context,
                        title:
                            'Data & Permissions',
                        icon: Icons
                            .admin_panel_settings_outlined,
                        body:
                            'GoCare may request permissions '
                            'such as location, camera, photos, '
                            'notifications, and other device '
                            'features depending on the features '
                            'you use.\n\n'
                            'You can review or change these '
                            'permissions from your device '
                            'settings.',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ABOUT
            // ==================================================

            _Section(
              title: 'About',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.info_outline,
                    title: 'About GoCare',
                    subtitle:
                        'Healthcare & emergency assistance',
                    onTap: () {
                      _showAppVersionDialog(context);
                    },
                  ),

                  const Divider(
                    height: 1,
                    indent: 74,
                  ),

                  ProfileMenuTile(
                    icon:
                        Icons.system_update_outlined,
                    title: 'App Version',
                    subtitle:
                        'Version 1.0.0 • Build 1',
                    onTap: () {
                      _showAppVersionDialog(context);
                    },
                  ),

                  const Divider(
                    height: 1,
                    indent: 74,
                  ),

                  ProfileMenuTile(
                    icon:
                        Icons.contact_support_outlined,
                    title: 'Contact Us',
                    subtitle:
                        'Get support for GoCare',
                    onTap: () {
                      _showContactDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // FOOTER
            // ==================================================

            Center(
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFEAF4FF),
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons
                          .health_and_safety_outlined,
                      color:
                          Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'GoCare',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Healthcare when you need it.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF98A2B3),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SECTION
// ============================================================

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF1976D2),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

// ============================================================
// THEME OPTION
// ============================================================

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFFEAF4FF)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : const Color(0xFFF2F4F7),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),

              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF1976D2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SUPPORT INFO TILE
// ============================================================

class _SupportInfoTile extends StatelessWidget {
  const _SupportInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.email_outlined,
            color: Color(0xFF1976D2),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF98A2B3),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(0xFF344054),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATIC INFO SCREEN
// ============================================================

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
      appBar: AppBar(
        title: Text(title),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius:
                    BorderRadius.circular(17),
              ),
              child: Icon(
                icon,
                size: 30,
                color: const Color(0xFF1976D2),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'GoCare • Version 1.0.0',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF98A2B3),
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4E7EC),
                ),
              ),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: Color(0xFF475467),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}