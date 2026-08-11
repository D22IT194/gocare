import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/emergency_contact.dart';
import '../providers/emergency_provider.dart';
import '../services/emergency_call_service.dart';
import '../widgets/emergency_contact_card.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  static const EmergencyCallService _callService = EmergencyCallService();

  EmergencyContactType _selectedType = EmergencyContactType.personal;

  // ============================================================
  // ADD / EDIT
  // ============================================================

  Future<void> _showContactDialog({EmergencyContact? contact}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return EmergencyContactDialog(
          contact: contact,
          initialType: contact?.type ?? _selectedType,
        );
      },
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Color(0xFFD92D20)),
              SizedBox(width: 10),
              Text('Delete contact?'),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: 'Remove ',
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                TextSpan(
                  text: contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD92D20),
                  ),
                ),
                const TextSpan(text: ' from your emergency contacts?'),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<EmergencyProvider>().deleteContact(contact.id);
    }
  }

  // ============================================================
  // CALL
  // ============================================================

  Future<void> _showCallConfirmation(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.phone_outlined, color: Color(0xFF12B76A)),
              SizedBox(width: 10),
              Text('Call contact?'),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: 'Do you want to call ',
              style: TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                TextSpan(
                  text: contact.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' at '),
                TextSpan(
                  text: contact.phone,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12B76A),
                  ),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12B76A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success = await _callService.call(contact.phone);
    if (!mounted || success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to start the phone call.')),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();

    final contacts = provider.contactsByType(_selectedType);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Emergency Contacts')),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 12),
        child: FloatingActionButton(
          onPressed: () => _showContactDialog(),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.person_add_alt_1_rounded, size: 25),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: _buildTypeSelector(),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                ? _EmptyContacts(
                    type: _selectedType,
                    onAdd: () => _showContactDialog(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    itemCount: contacts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];

                      return EmergencyContactCard(
                        contact: contact,
                        onEdit: () => _showContactDialog(contact: contact),
                        onDelete: () => _deleteContact(contact),
                        onCall: () => _showCallConfirmation(contact),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDoctor = _selectedType == EmergencyContactType.doctor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF00A896)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDoctor
                  ? Icons.local_hospital_outlined
                  : Icons.contact_phone_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDoctor ? 'Your Healthcare Team' : 'Your Trusted Contacts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDoctor
                      ? 'Keep important doctors and clinics ready.'
                      : 'Reach trusted people quickly during an emergency.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<EmergencyContactType>(
      segments: const [
        ButtonSegment(
          value: EmergencyContactType.personal,
          icon: Icon(Icons.person_outline),
          label: Text('Personal'),
        ),
        ButtonSegment(
          value: EmergencyContactType.doctor,
          icon: Icon(Icons.local_hospital_outlined),
          label: Text('Doctor'),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (selected) {
        setState(() {
          _selectedType = selected.first;
        });
      },
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts({required this.type, required this.onAdd});

  final EmergencyContactType type;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDoctor = type == EmergencyContactType.doctor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                isDoctor
                    ? Icons.local_hospital_outlined
                    : Icons.contact_phone_outlined,
                size: 42,
                color: const Color(0xFF1976D2),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              type.emptyTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              type.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF667085),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text('Add ${type.label.toLowerCase()} contact'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONTACT DIALOG
// ============================================================

class EmergencyContactDialog extends StatefulWidget {
  const EmergencyContactDialog({
    super.key,
    this.contact,
    this.initialType = EmergencyContactType.personal,
  });

  final EmergencyContact? contact;
  final EmergencyContactType initialType;

  @override
  State<EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<EmergencyContactDialog> {
  late final TextEditingController _nameController;

  late final TextEditingController _phoneController;

  late final TextEditingController _emailController;

  late final TextEditingController _relationshipController;

  late final TextEditingController _specialityController;

  late final TextEditingController _addressController;

  late EmergencyContactType _type;

  late bool _isPrimary;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final contact = widget.contact;

    _type = contact?.type ?? widget.initialType;

    _nameController = TextEditingController(text: contact?.name ?? '');

    _phoneController = TextEditingController(text: contact?.phone ?? '');

    _emailController = TextEditingController(text: contact?.email ?? '');

    _relationshipController = TextEditingController(
      text: contact?.relationship ?? '',
    );

    _specialityController = TextEditingController(
      text: contact?.speciality ?? '',
    );

    _addressController = TextEditingController(text: contact?.address ?? '');

    _isPrimary = contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    _specialityController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveContact() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final provider = context.read<EmergencyProvider>();

      final name = _nameController.text.trim();

      final phone = _phoneController.text.trim();

      final email = _emailController.text.trim();

      final relationship = _relationshipController.text.trim();

      final speciality = _specialityController.text.trim();

      final address = _addressController.text.trim();

      if (widget.contact == null) {
        final success = await provider.addContact(
          name: name,
          phone: phone,
          email: email,
          type: _type,
          relationship: _type == EmergencyContactType.personal
              ? relationship
              : null,
          speciality: _type == EmergencyContactType.doctor ? speciality : null,
          address: address,
          isPrimary: _isPrimary,
        );

        if (!success) {
          throw Exception(provider.errorMessage ?? 'Unable to save contact.');
        }
      } else {
        await provider.updateContact(
          id: widget.contact!.id,
          name: name,
          phone: phone,
          email: email,
          type: _type,
          relationship: _type == EmergencyContactType.personal
              ? relationship
              : null,
          speciality: _type == EmergencyContactType.doctor ? speciality : null,
          address: address,
          isPrimary: _isPrimary,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save contact: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Enter a valid name';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!regex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    final isDoctor = _type == EmergencyContactType.doctor;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ============================================================
                // HEADER
                // ============================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDoctor
                            ? const Color(0xFFE8FFF9)
                            : const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isDoctor
                            ? Icons.local_hospital_outlined
                            : Icons.person_add_alt_1_rounded,
                        color: isDoctor
                            ? const Color(0xFF00A896)
                            : const Color(0xFF1976D2),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing
                                ? 'Edit Contact'
                                : 'Add Emergency Contact',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172B4D),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            isDoctor
                                ? 'Keep your healthcare contact ready.'
                                : 'Add someone you trust during emergencies.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Close button
                    Material(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _saving ? null : () => Navigator.pop(context),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.close_rounded,
                            size: 21,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Divider
                Container(height: 1, color: const Color(0xFFEAECF0)),

                const SizedBox(height: 22),

                _SectionTitle(
                  title: 'Contact Type',
                  icon: Icons.category_outlined,
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<EmergencyContactType>(
                    segments: const [
                      ButtonSegment(
                        value: EmergencyContactType.personal,
                        icon: Icon(Icons.person_outline),
                        label: Text('Personal'),
                      ),
                      ButtonSegment(
                        value: EmergencyContactType.doctor,
                        icon: Icon(Icons.local_hospital_outlined),
                        label: Text('Doctor'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: _saving
                        ? null
                        : (selected) {
                            setState(() {
                              _type = selected.first;
                            });
                          },
                  ),
                ),

                const SizedBox(height: 22),

                _SectionTitle(
                  title: 'Basic Information',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 12),

                _AppField(
                  controller: _nameController,
                  label: isDoctor ? 'Doctor / Clinic Name' : 'Full Name',
                  hint: isDoctor
                      ? 'Enter doctor or clinic name'
                      : 'Enter full name',
                  icon: isDoctor
                      ? Icons.local_hospital_outlined
                      : Icons.person_outline,
                  validator: _validateName,
                  enabled: !_saving,
                ),

                const SizedBox(height: 14),

                _AppField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+91 XXXXX XXXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  enabled: !_saving,
                ),

                const SizedBox(height: 14),

                _AppField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'example@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  enabled: !_saving,
                ),

                const SizedBox(height: 14),

                if (!isDoctor)
                  _AppField(
                    controller: _relationshipController,
                    label: 'Relationship',
                    hint: 'Father, Mother, Brother, Friend...',
                    icon: Icons.favorite_border,
                    enabled: !_saving,
                  ),

                if (!isDoctor) const SizedBox(height: 14),

                if (isDoctor)
                  _AppField(
                    controller: _specialityController,
                    label: 'Medical Speciality',
                    hint: 'Cardiologist, Dentist, General Physician...',
                    icon: Icons.medical_services_outlined,
                    enabled: !_saving,
                  ),

                if (isDoctor) const SizedBox(height: 14),

                _AppField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter address',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  enabled: !_saving,
                ),

                const SizedBox(height: 14),

                _PrimarySelector(
                  value: _isPrimary,
                  type: _type,
                  enabled: !_saving,
                  onChanged: (value) {
                    setState(() {
                      _isPrimary = value;
                    });
                  },
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveContact,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : isEditing
                          ? 'Save Changes'
                          : 'Add Contact',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1976D2)),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF344054),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FIELD
// ============================================================

class _AppField extends StatelessWidget {
  const _AppField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.textInputAction,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

// ============================================================
// PRIMARY SELECTOR
// ============================================================

class _PrimarySelector extends StatelessWidget {
  const _PrimarySelector({
    required this.value,
    required this.type,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final EmergencyContactType type;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? const Color(0xFFEAF4FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? const Color(0xFFB2DDFF) : const Color(0xFFEAECF0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFF1976D2).withValues(alpha: 0.10)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              value ? Icons.star : Icons.star_border,
              color: value ? const Color(0xFF1976D2) : const Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Primary contact',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF344054),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Use this as the main ${type.label.toLowerCase()} contact.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}
