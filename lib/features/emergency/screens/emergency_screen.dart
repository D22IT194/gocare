import 'package:flutter/material.dart';

import '../services/emergency_call_service.dart';
import '../widgets/emergency_action_card.dart';
import 'emergency_contacts_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static const EmergencyCallService _callService = EmergencyCallService();

  Future<void> _confirmAndCall(
    BuildContext context, {
    required String service,
    required String phoneNumber,
    required String description,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Call $service?'),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await _callService.call(phoneNumber);

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start the phone call.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(title: const Text('Emergency'), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD92D20),
                    size: 32,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Need emergency help?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A271A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Choose the emergency service you need.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF912018),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Emergency services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 14),

            EmergencyActionCard(
              title: 'Ambulance',
              subtitle: 'Medical emergency assistance',
              icon: Icons.local_hospital_outlined,
              color: const Color(0xFFD92D20),
              onTap: () {
                _confirmAndCall(
                  context,
                  service: 'Ambulance',
                  phoneNumber: '108',
                  description:
                      'This will open your phone dialer for ambulance services.',
                );
              },
            ),

            const SizedBox(height: 12),

            EmergencyActionCard(
              title: 'Police',
              subtitle: 'Police and safety assistance',
              icon: Icons.local_police_outlined,
              color: const Color(0xFF1976D2),
              onTap: () {
                _confirmAndCall(
                  context,
                  service: 'Police',
                  phoneNumber: '112',
                  description:
                      'This will open your phone dialer for emergency police assistance.',
                );
              },
            ),

            const SizedBox(height: 12),

            EmergencyActionCard(
              title: 'Fire',
              subtitle: 'Fire and rescue assistance',
              icon: Icons.local_fire_department_outlined,
              color: const Color(0xFFF04438),
              onTap: () {
                _confirmAndCall(
                  context,
                  service: 'Fire services',
                  phoneNumber: '101',
                  description:
                      'This will open your phone dialer for fire and rescue services.',
                );
              },
            ),

            const SizedBox(height: 12),

            EmergencyActionCard(
              title: 'Emergency',
              subtitle: 'General emergency assistance',
              icon: Icons.emergency_outlined,
              color: const Color(0xFF12B76A),
              onTap: () {
                _confirmAndCall(
                  context,
                  service: 'Emergency services',
                  phoneNumber: '112',
                  description:
                      'This will open your phone dialer for emergency services.',
                );
              },
            ),

            const SizedBox(height: 28),

            const Text(
              'Emergency contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 12),

            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyContactsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEAECF0)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFEAF4FF),
                        child: Icon(
                          Icons.contact_phone_outlined,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage contacts',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF172B4D),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'People you trust during an emergency.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
