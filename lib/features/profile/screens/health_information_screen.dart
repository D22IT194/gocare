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

class _HealthInformationScreenState
    extends State<HealthInformationScreen> {
  final ProfileService _profileService = ProfileService();

  final _formKey = GlobalKey<FormState>();

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalConditionsController =
      TextEditingController();
  final _medicationsController =
      TextEditingController();
  final _emergencyNotesController =
      TextEditingController();

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
      final user =
          context.read<AuthProvider>().user;

      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        return;
      }

      final healthInformation =
          await _profileService.getHealthInformation(
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      if (healthInformation != null) {
        _dateOfBirth =
            healthInformation.dateOfBirth;

        _gender =
            healthInformation.gender;

        _bloodGroup =
            healthInformation.bloodGroup;

        _heightController.text =
            healthInformation.height
                    ?.toString() ??
                '';

        _weightController.text =
            healthInformation.weight
                    ?.toString() ??
                '';

        _allergiesController.text =
            healthInformation.allergies ??
                '';

        _medicalConditionsController.text =
            healthInformation
                    .medicalConditions ??
                '';

        _medicationsController.text =
            healthInformation
                    .currentMedications ??
                '';

        _emergencyNotesController.text =
            healthInformation.emergencyNotes ??
                '';
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load health information: $e',
          ),
        ),
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
  // DATE OF BIRTH
  // ============================================================

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final initialDate =
        _dateOfBirth ??
        DateTime(
          now.year - 18,
          now.month,
          now.day,
        );

    final selected =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'SELECT DATE OF BIRTH',
      cancelText: 'CANCEL',
      confirmText: 'SELECT',
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _dateOfBirth = selected;
    });

    _formKey.currentState?.validate();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();

    int age =
        now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month ==
                dateOfBirth.month &&
            now.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user =
        context.read<AuthProvider>().user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your session has expired. Please login again.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final healthInformation =
          HealthInformation(
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        bloodGroup: _bloodGroup,
        height: double.tryParse(
          _heightController.text.trim(),
        ),
        weight: double.tryParse(
          _weightController.text.trim(),
        ),
        allergies:
            _cleanText(
          _allergiesController.text,
        ),
        medicalConditions:
            _cleanText(
          _medicalConditionsController.text,
        ),
        currentMedications:
            _cleanText(
          _medicationsController.text,
        ),
        emergencyNotes:
            _cleanText(
          _emergencyNotesController.text,
        ),
      );

      await _profileService
          .saveHealthInformation(
        userId: user.uid,
        healthInformation:
            healthInformation,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Health information saved successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save health information: $e',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
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
      appBar: AppBar(
        title: const Text(
          'Health Information',
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildIntro(),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildPersonalSection(),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildMedicalSection(),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildEmergencySection(),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildSaveButton(),

                      const SizedBox(
                        height: 20,
                      ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD6E9FF),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Color(0xFF1976D2),
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your health profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Keep this information updated. '
                  'It can help provide better assistance '
                  'during an emergency.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color:
                        Color(0xFF475467),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONAL INFORMATION
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
            DropdownMenuItem(
              value: 'Male',
              child: Text('Male'),
            ),
            DropdownMenuItem(
              value: 'Female',
              child: Text('Female'),
            ),
            DropdownMenuItem(
              value: 'Other',
              child: Text('Other'),
            ),
            DropdownMenuItem(
              value: 'Prefer not to say',
              child:
                  Text('Prefer not to say'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
          validator: (value) {
            if (value == null ||
                value.isEmpty) {
              return 'Please select gender';
            }

            return null;
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
            DropdownMenuItem(
              value: 'A+',
              child: Text('A+'),
            ),
            DropdownMenuItem(
              value: 'A-',
              child: Text('A-'),
            ),
            DropdownMenuItem(
              value: 'B+',
              child: Text('B+'),
            ),
            DropdownMenuItem(
              value: 'B-',
              child: Text('B-'),
            ),
            DropdownMenuItem(
              value: 'AB+',
              child: Text('AB+'),
            ),
            DropdownMenuItem(
              value: 'AB-',
              child: Text('AB-'),
            ),
            DropdownMenuItem(
              value: 'O+',
              child: Text('O+'),
            ),
            DropdownMenuItem(
              value: 'O-',
              child: Text('O-'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _bloodGroup = value;
            });
          },
          validator: (value) {
            if (value == null ||
                value.isEmpty) {
              return 'Please select blood group';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller:
                    _heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  label: 'Height',
                  hint: 'e.g. 170',
                  icon: Icons.height,
                  suffixText: 'cm',
                ),
                validator:
                    _validateHeight,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: TextFormField(
                controller:
                    _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  label: 'Weight',
                  hint: 'e.g. 65',
                  icon:
                      Icons.monitor_weight_outlined,
                  suffixText: 'kg',
                ),
                validator:
                    _validateWeight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // MEDICAL INFORMATION
  // ============================================================

  Widget _buildMedicalSection() {
    return _buildSection(
      title: 'Medical Information',
      icon:
          Icons.medical_information_outlined,
      children: [
        _buildMultilineField(
          controller:
              _allergiesController,
          label: 'Allergies',
          hint:
              'Example: Penicillin, peanuts',
        ),

        const SizedBox(height: 16),

        _buildMultilineField(
          controller:
              _medicalConditionsController,
          label: 'Medical Conditions',
          hint:
              'Example: Asthma, diabetes',
        ),

        const SizedBox(height: 16),

        _buildMultilineField(
          controller:
              _medicationsController,
          label: 'Current Medications',
          hint:
              'List medicines you currently take',
        ),
      ],
    );
  }

  // ============================================================
  // EMERGENCY
  // ============================================================

  Widget _buildEmergencySection() {
    return _buildSection(
      title: 'Emergency Information',
      icon: Icons.emergency_outlined,
      children: [
        Container(
          padding:
              const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(
              0xFFFFF7ED,
            ),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Color(
                  0xFFEA580C,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add information that emergency '
                  'responders should know.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        Color(0xFF7C2D12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _buildMultilineField(
          controller:
              _emergencyNotesController,
          label: 'Emergency Notes',
          hint:
              'Example: Important medical information, '
              'special instructions, etc.',
          maxLines: 5,
        ),
      ],
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    final dateText =
        _dateOfBirth == null
            ? ''
            : _formatDate(
                _dateOfBirth!,
              );

    final age =
        _dateOfBirth == null
            ? null
            : _calculateAge(
                _dateOfBirth!,
              );

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: dateText,
      ),
      onTap: _selectDateOfBirth,
      decoration: _inputDecoration(
        label: 'Date of Birth',
        icon:
            Icons.calendar_today_outlined,
        hint: 'Select your date of birth',
        suffixText:
            age == null
                ? null
                : '$age years',
      ),
      validator: (_) {
        if (_dateOfBirth == null) {
          return 'Date of birth is required';
        }

        return null;
      },
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed:
            _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_outlined,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Save Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE4E7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.025),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFEAF4FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(
                    0xFF1976D2,
                  ),
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF172B4D),
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
    required TextEditingController
        controller,
    required String label,
    required String hint,
    int maxLines = 3,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization:
          TextCapitalization.sentences,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
      ),
    );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _validateHeight(
    String? value,
  ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Height is required';
    }

    final height =
        double.tryParse(text);

    if (height == null) {
      return 'Enter a valid height';
    }

    if (height < 50 ||
        height > 250) {
      return 'Enter height between 50-250 cm';
    }

    return null;
  }

  String? _validateWeight(
    String? value,
  ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Weight is required';
    }

    final weight =
        double.tryParse(text);

    if (weight == null) {
      return 'Enter a valid weight';
    }

    if (weight < 10 ||
        weight > 300) {
      return 'Enter weight between 10-300 kg';
    }

    return null;
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    String? hint,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          icon == null
              ? null
              : Icon(icon),
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color:
              Color(0xFFD0D5DD),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color:
              Color(0xFF1976D2),
          width: 1.5,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color:
              Color(0xFFD92D20),
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color:
              Color(0xFFD92D20),
          width: 1.5,
        ),
      ),
      filled: true,
      fillColor:
          const Color(0xFFFCFCFD),
    );
  }
}