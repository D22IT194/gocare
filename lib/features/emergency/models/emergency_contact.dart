class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.type = EmergencyContactType.personal,
    this.relationship,
  });

  final String id;
  final String name;
  final String phone;
  final EmergencyContactType type;
  final String? relationship;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type.name,
      'relationship': relationship,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      type: EmergencyContactType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => EmergencyContactType.personal,
      ),
      relationship: map['relationship'] as String?,
    );
  }
}

enum EmergencyContactType { personal, doctor }

extension EmergencyContactTypeLabel on EmergencyContactType {
  String get label {
    switch (this) {
      case EmergencyContactType.personal:
        return 'Personal';
      case EmergencyContactType.doctor:
        return 'Doctor';
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
}
