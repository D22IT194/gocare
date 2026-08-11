import 'package:flutter/material.dart';

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.type = EmergencyContactType.personal,
    this.relationship,
    this.email,
    this.speciality,
    this.address,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String phone;
  final EmergencyContactType type;

  final String? relationship;
  final String? email;
  final String? speciality;
  final String? address;

  final bool isPrimary;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.trim(),
      'phone': phone.trim(),
      'type': type.name,
      'relationship': _nullableValue(relationship),
      'email': _nullableValue(email),
      'speciality': _nullableValue(speciality),
      'address': _nullableValue(address),
      'isPrimary': isPrimary,
    };
  }

  factory EmergencyContact.fromMap(
    Map<String, dynamic> map,
  ) {
    return EmergencyContact(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      type: EmergencyContactType.values.firstWhere(
        (type) => type.name == map['type']?.toString(),
        orElse: () => EmergencyContactType.personal,
      ),
      relationship: _nullableString(
        map['relationship'],
      ),
      email: _nullableString(
        map['email'],
      ),
      speciality: _nullableString(
        map['speciality'],
      ),
      address: _nullableString(
        map['address'],
      ),
      isPrimary: map['isPrimary'] == true,
    );
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? null : text;
  }

  static String? _nullableValue(String? value) {
    final text = value?.trim() ?? '';

    return text.isEmpty ? null : text;
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    EmergencyContactType? type,
    String? relationship,
    String? email,
    String? speciality,
    String? address,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      speciality: speciality ?? this.speciality,
      address: address ?? this.address,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

enum EmergencyContactType {
  personal,
  doctor,
}

extension EmergencyContactTypeLabel
    on EmergencyContactType {
  String get label {
    switch (this) {
      case EmergencyContactType.personal:
        return 'Personal';

      case EmergencyContactType.doctor:
        return 'Doctor';
    }
  }

  String get description {
    switch (this) {
      case EmergencyContactType.personal:
        return 'Family member, friend or trusted person';

      case EmergencyContactType.doctor:
        return 'Doctor, hospital or medical professional';
    }
  }

  String get emptyTitle {
    switch (this) {
      case EmergencyContactType.personal:
        return 'No personal contacts';

      case EmergencyContactType.doctor:
        return 'No doctor contacts';
    }
  }

  IconData get icon {
    switch (this) {
      case EmergencyContactType.personal:
        return Icons.person_outline;

      case EmergencyContactType.doctor:
        return Icons.local_hospital_outlined;
    }
  }
}