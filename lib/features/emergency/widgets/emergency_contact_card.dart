import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onCall,
  });

  final EmergencyContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: contact.type == EmergencyContactType.doctor
                ? const Color(0xFFE8FFF9)
                : const Color(0xFFEAF4FF),
            child: Icon(
              contact.type == EmergencyContactType.doctor
                  ? Icons.local_hospital_outlined
                  : Icons.person_outline,
              color: contact.type == EmergencyContactType.doctor
                  ? const Color(0xFF00A896)
                  : const Color(0xFF1976D2),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  contact.phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF667085),
                  ),
                ),

                const SizedBox(height: 6),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _ContactTag(
                      label: contact.type.label,
                      color: contact.type == EmergencyContactType.doctor
                          ? const Color(0xFF00A896)
                          : const Color(0xFF1976D2),
                    ),
                    if (contact.relationship != null)
                      _ContactTag(
                        label: contact.relationship!,
                        color: const Color(0xFF667085),
                      ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Call',
            onPressed: onCall,
            icon: const Icon(Icons.call_outlined, color: Color(0xFF12B76A)),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }

              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _ContactTag extends StatelessWidget {
  const _ContactTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
