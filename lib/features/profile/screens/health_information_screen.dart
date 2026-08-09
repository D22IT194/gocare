import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../authentication/providers/auth_provider.dart';
import '../models/health_information.dart';
import '../services/profile_service.dart';

class HealthInformationScreen extends StatefulWidget {
  const HealthInformationScreen({super.key});

  @override
  State<HealthInformationScreen> createState() =>
      _HealthInformationScreenState();
}

class _HealthInformationScreenState extends State<HealthInformationScreen> {
  final ProfileService _profileService = ProfileService();

  final _formKey = GlobalKey<FormState>();

  final _heightController = TextEditingController();

  final _weightController = TextEditingController();

  final _allergiesController = TextEditingController();

  final _medicalConditionsController = TextEditingController();

  final _medicationsController = TextEditingController();

  final _emergencyNotesController = TextEditingController();

  DateTime? _dateOfBirth;

  String? _gender;

  String? _bloodGroup;

  bool _isLoading = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadHealthInformation();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _emergencyNotesController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadHealthInformation() async {
    try {
      final authProvider = context.read<AuthProvider>();

      final user = authProvider.user;

      if (user == null) {
        return;
      }

      final healthInformation = await _profileService.getHealthInformation(
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      if (healthInformation != null) {
        _dateOfBirth = healthInformation.dateOfBirth;

        _gender = healthInformation.gender;

        _bloodGroup = healthInformation.bloodGroup;

        _heightController.text = healthInformation.height?.toString() ?? '';

        _weightController.text = healthInformation.weight?.toString() ?? '';

        _allergiesController.text = healthInformation.allergies ?? '';

        _medicalConditionsController.text =
            healthInformation.medicalConditions ?? '';

        _medicationsController.text =
            healthInformation.currentMedications ?? '';

        _emergencyNotesController.text = healthInformation.emergencyNotes ?? '';
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load health information: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final initialDate =
        _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _dateOfBirth = selected;
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login again.')));

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final healthInformation = HealthInformation(
        dateOfBirth: _dateOfBirth,

        gender: _gender,

        bloodGroup: _bloodGroup,

        height: double.tryParse(_heightController.text.trim()),

        weight: double.tryParse(_weightController.text.trim()),

        allergies: _cleanText(_allergiesController.text),

        medicalConditions: _cleanText(_medicalConditionsController.text),

        currentMedications: _cleanText(_medicationsController.text),

        emergencyNotes: _cleanText(_emergencyNotesController.text),
      );

      await _profileService.saveHealthInformation(
        userId: user.uid,
        healthInformation: healthInformation,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health information saved successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save information: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _cleanText(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Information')),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,

                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      _buildIntro(),

                      const SizedBox(height: 24),

                      _buildPersonalSection(),

                      const SizedBox(height: 24),

                      _buildMedicalSection(),

                      const SizedBox(height: 24),

                      _buildEmergencySection(),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,

                        height: 54,

                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,

                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),

        borderRadius: BorderRadius.circular(16),
      ),

      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: Color(0xFF1976D2),
            size: 28,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Keep your health information updated. '
              'This information can help you receive '
              'better assistance during an emergency.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONAL
  // ============================================================

  Widget _buildPersonalSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildDateField(),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _gender,
          decoration: _inputDecoration(
            label: 'Gender',
            icon: Icons.people_outline,
          ),

          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
            DropdownMenuItem(
              value: 'Prefer not to say',
              child: Text('Prefer not to say'),
            ),
          ],

          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _bloodGroup,
          decoration: _inputDecoration(
            label: 'Blood Group',
            icon: Icons.bloodtype_outlined,
          ),

          items: const [
            DropdownMenuItem(value: 'A+', child: Text('A+')),
            DropdownMenuItem(value: 'A-', child: Text('A-')),
            DropdownMenuItem(value: 'B+', child: Text('B+')),
            DropdownMenuItem(value: 'B-', child: Text('B-')),
            DropdownMenuItem(value: 'AB+', child: Text('AB+')),
            DropdownMenuItem(value: 'AB-', child: Text('AB-')),
            DropdownMenuItem(value: 'O+', child: Text('O+')),
            DropdownMenuItem(value: 'O-', child: Text('O-')),
          ],

          onChanged: (value) {
            setState(() {
              _bloodGroup = value;
            });
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(
            label: 'Height (cm)',
            icon: Icons.height,
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(
            label: 'Weight (kg)',
            icon: Icons.monitor_weight_outlined,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MEDICAL
  // ============================================================

  Widget _buildMedicalSection() {
    return _buildSection(
      title: 'Medical Information',
      icon: Icons.medical_information_outlined,
      children: [
        _buildMultilineField(
          controller: _allergiesController,
          label: 'Allergies',
          hint: 'Example: Penicillin, peanuts',
        ),

        const SizedBox(height: 16),

        _buildMultilineField(
          controller: _medicalConditionsController,
          label: 'Medical Conditions',
          hint: 'Example: Asthma, diabetes',
        ),

        const SizedBox(height: 16),

        _buildMultilineField(
          controller: _medicationsController,
          label: 'Current Medications',
          hint: 'List medicines you currently take',
        ),
      ],
    );
  }

  // ============================================================
  // EMERGENCY
  // ============================================================

  Widget _buildEmergencySection() {
    return _buildSection(
      title: 'Emergency Notes',
      icon: Icons.emergency_outlined,
      children: [
        _buildMultilineField(
          controller: _emergencyNotesController,
          label: 'Emergency Notes',
          hint: 'Anything emergency responders should know',
          maxLines: 5,
        ),
      ],
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    final dateText = _dateOfBirth == null
        ? ''
        : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/'
              '${_dateOfBirth!.month.toString().padLeft(2, '0')}/'
              '${_dateOfBirth!.year}';

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: dateText),
      onTap: _selectDateOfBirth,
      decoration: _inputDecoration(
        label: 'Date of Birth',
        icon: Icons.calendar_today_outlined,
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1976D2)),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // MULTILINE FIELD
  // ============================================================

  Widget _buildMultilineField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 3,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: _inputDecoration(label: label, hint: hint),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
      ),
    );
  }
}
