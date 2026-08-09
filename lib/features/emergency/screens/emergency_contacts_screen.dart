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

  Future<void> _showContactDialog({EmergencyContact? contact}) async {
    await showDialog(
      context: context,
      builder: (_) {
        return EmergencyContactDialog(
          contact: contact,
          initialType: contact?.type ?? _selectedType,
        );
      },
    );
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete contact?'),
          content: Text('Remove ${contact.name} from emergency contacts?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFD92D20)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      context.read<EmergencyProvider>().deleteContact(contact.id);
    }
  }

  Future<void> _showCallConfirmation(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Call contact?'),
          content: Text(
            'Do you want to call ${contact.name} at ${contact.phone}?',
          ),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final contacts = provider.contactsByType(_selectedType);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Emergency Contacts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showContactDialog,
        icon: const Icon(Icons.add),
        label: Text('Add ${_selectedType.label.toLowerCase()}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
              selected: {_selectedType},
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedType = selected.first;
                });
              },
            ),
          ),
          Expanded(
            child: contacts.isEmpty
                ? _EmptyContacts(type: _selectedType, onAdd: _showContactDialog)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                    itemCount: contacts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];

                      return EmergencyContactCard(
                        contact: contact,
                        onEdit: () {
                          _showContactDialog(contact: contact);
                        },
                        onDelete: () {
                          _deleteContact(contact);
                        },
                        onCall: () {
                          _showCallConfirmation(contact);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

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
            Icon(
              isDoctor
                  ? Icons.local_hospital_outlined
                  : Icons.contact_phone_outlined,
              size: 70,
              color: const Color(0xFF98A2B3),
            ),
            const SizedBox(height: 18),
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
              isDoctor
                  ? 'Add doctors or clinics you may need to reach quickly.'
                  : 'Add trusted people who can be contacted quickly during an emergency.',
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
  late final TextEditingController _relationshipController;
  late EmergencyContactType _type;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _type = widget.contact?.type ?? widget.initialType;
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _relationshipController = TextEditingController(
      text: widget.contact?.relationship ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<EmergencyProvider>();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final relationship = _relationshipController.text.trim();

    if (widget.contact == null) {
      await provider.addContact(
        name: name,
        phone: phone,
        type: _type,
        relationship: relationship,
      );
    } else {
      await provider.updateContact(
        id: widget.contact!.id,
        name: name,
        phone: phone,
        type: _type,
        relationship: relationship,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit contact' : 'Add contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<EmergencyContactType>(
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
                onSelectionChanged: (selected) {
                  setState(() {
                    _type = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _type == EmergencyContactType.doctor
                      ? 'Doctor or clinic name'
                      : 'Name',
                  hintText: 'Enter name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: 'Enter phone number',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _relationshipController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _type == EmergencyContactType.doctor
                      ? 'Speciality'
                      : 'Relationship',
                  hintText: _type == EmergencyContactType.doctor
                      ? 'Example: Cardiologist'
                      : 'Example: Father, Mother',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveContact,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
