import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../authentication/providers/auth_provider.dart';
import '../models/health_information.dart';
import '../services/profile_service.dart';

class MedicalCardScreen extends StatefulWidget {
  const MedicalCardScreen({super.key});

  @override
  State<MedicalCardScreen> createState() => _MedicalCardScreenState();
}

class _MedicalCardScreenState extends State<MedicalCardScreen> {
  final ProfileService _profileService = ProfileService();

  HealthInformation? _healthInformation;
  Map<String, dynamic>? _profileDetails;
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
    final profileDetails = await _profileService.getProfileDetails(
      userId: user.uid,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _healthInformation = health;
      _profileDetails = profileDetails;
      _isLoading = false;
    });
  }

  String _cardText() {
    final user = context.read<AuthProvider>().user;
    final health = _healthInformation;
    final phone = _profileDetails?['phoneNumber'] as String?;

    return '''
GoCare Medical Card
Name: ${user?.displayName ?? 'User'}
Email: ${user?.email ?? 'Not added'}
Mobile: ${_value(phone)}
Date of birth: ${_date(health?.dateOfBirth)}
Blood group: ${_value(health?.bloodGroup)}
Gender: ${_value(health?.gender)}
Height: ${health?.height == null ? 'Not added' : '${health!.height!.toStringAsFixed(0)} cm'}
Weight: ${health?.weight == null ? 'Not added' : '${health!.weight!.toStringAsFixed(1)} kg'}
Allergies: ${_value(health?.allergies)}
Medical conditions: ${_value(health?.medicalConditions)}
Current medications: ${_value(health?.currentMedications)}
Emergency notes: ${_value(health?.emergencyNotes)}
''';
  }

  Future<void> _shareCard() async {
    await SharePlus.instance.share(
      ShareParams(text: _cardText(), subject: 'GoCare Medical Card'),
    );
  }

  Future<void> _downloadCard() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gocare_medical_card.txt');

    await file.writeAsString(_cardText());

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medical card downloaded to ${file.path}')),
    );
  }

  static String _value(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'Not added' : text;
  }

  static String _date(DateTime? value) {
    if (value == null) {
      return 'Not added';
    }

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final health = _healthInformation;
    final phone = _profileDetails?['phoneNumber'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Medical Card')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1976D2), Color(0xFF00A896)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF1976D2,
                          ).withValues(alpha: 0.20),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.health_and_safety_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GoCare Medical Card',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Emergency summary',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            user?.displayName ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.email ?? 'Not added',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          if (_value(phone) != 'Not added') ...[
                            const SizedBox(height: 4),
                            Text(
                              phone!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _MetricTile(
                                label: 'DOB',
                                value: _date(health?.dateOfBirth),
                              ),
                              _MetricTile(
                                label: 'Blood',
                                value: _value(health?.bloodGroup),
                              ),
                              _MetricTile(
                                label: 'Gender',
                                value: _value(health?.gender),
                              ),
                              _MetricTile(
                                label: 'Height',
                                value: health?.height == null
                                    ? 'Not added'
                                    : '${health!.height!.toStringAsFixed(0)} cm',
                              ),
                              _MetricTile(
                                label: 'Weight',
                                value: health?.weight == null
                                    ? 'Not added'
                                    : '${health!.weight!.toStringAsFixed(1)} kg',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DetailPanel(
                    title: 'Medical Details',
                    children: [
                      _DetailRow(
                        icon: Icons.warning_amber_outlined,
                        label: 'Allergies',
                        value: _value(health?.allergies),
                      ),
                      _DetailRow(
                        icon: Icons.medical_information_outlined,
                        label: 'Conditions',
                        value: _value(health?.medicalConditions),
                      ),
                      _DetailRow(
                        icon: Icons.medication_outlined,
                        label: 'Medications',
                        value: _value(health?.currentMedications),
                      ),
                      _DetailRow(
                        icon: Icons.emergency_outlined,
                        label: 'Emergency notes',
                        value: _value(health?.emergencyNotes),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareCard,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloadCard,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF98A2B3),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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
