import 'package:flutter/material.dart';

import '../../features/emergency/screens/emergency_screen.dart';
import '../../features/first_aid/screens/first_aid_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/nearby/screens/nearby_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
  });

  @override
  State<AppShell> createState() =>
      _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigateToTab: _onTabSelected,
      ),
      const FirstAidScreen(),
      const EmergencyScreen(),
      const NearbyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.medical_services_outlined,
            ),
            selectedIcon: Icon(
              Icons.medical_services,
            ),
            label: 'First Aid',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.emergency_outlined,
            ),
            selectedIcon: Icon(
              Icons.emergency,
            ),
            label: 'Emergency',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.location_on_outlined,
            ),
            selectedIcon: Icon(
              Icons.location_on,
            ),
            label: 'Nearby',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}