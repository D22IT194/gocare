import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/health_information.dart';
import '../services/profile_service.dart';

class MedicalInformationScreen extends StatefulWidget {
  const MedicalInformationScreen({super.key});

  @override
  State<MedicalInformationScreen> createState() =>
      _MedicalInformationScreenState();
}

class _MedicalInformationScreenState extends State<MedicalInformationScreen> {
  final ProfileService _profileService = ProfileService();

  HealthInformation? _healthInformation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final health = await _profileService.getHealthInformation(userId: user.uid);

    if (!mounted) {
      return;
    }

    setState(() {
      _healthInformation = health;
      _isLoading = false;
    });
  }

  Future<void> _edit() async {
    await Navigator.pushNamed(context, AppRoutes.healthInformation);

    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = _healthInformation;

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Information')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _InfoCard(
                  title: 'Vitals',
                  rows: [
                    _InfoRowData(
                      'Blood group',
                      health?.bloodGroup ?? 'Not added',
                    ),
                    _InfoRowData(
                      'Height',
                      health?.height == null
                          ? 'Not added'
                          : '${health!.height!.toStringAsFixed(0)} cm',
                    ),
                    _InfoRowData(
                      'Weight',
                      health?.weight == null
                          ? 'Not added'
                          : '${health!.weight!.toStringAsFixed(1)} kg',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Medical Details',
                  rows: [
                    _InfoRowData('Allergies', health?.allergies ?? 'Not added'),
                    _InfoRowData(
                      'Conditions',
                      health?.medicalConditions ?? 'Not added',
                    ),
                    _InfoRowData(
                      'Medications',
                      health?.currentMedications ?? 'Not added',
                    ),
                    _InfoRowData(
                      'Emergency notes',
                      health?.emergencyNotes ?? 'Not added',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit medical information'),
                ),
              ],
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 12),
          for (final row in rows) ...[
            Text(
              row.label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
            ),
            const SizedBox(height: 3),
            Text(
              row.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
            if (row != rows.last) const Divider(height: 22),
          ],
        ],
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData(this.label, this.value);

  final String label;
  final String value;
}
