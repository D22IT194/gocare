import 'package:cloud_firestore/cloud_firestore.dart';

class HealthInformation {
  const HealthInformation({
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.height,
    this.weight,
    this.allergies,
    this.medicalConditions,
    this.currentMedications,
    this.emergencyNotes,
  });

  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;

  final double? height;
  final double? weight;

  final String? allergies;
  final String? medicalConditions;
  final String? currentMedications;
  final String? emergencyNotes;

  static String? _parseString(dynamic value) {
  final text = value?.toString().trim() ?? '';

  return text.isEmpty ? null : text;
}

  factory HealthInformation.fromMap(Map<String, dynamic> map) {
    return HealthInformation(
      dateOfBirth: _parseDate(map['dateOfBirth']),

      // gender: map['gender'] as String?,

      // bloodGroup: map['bloodGroup'] as String?,
      height: (map['height'] as num?)?.toDouble(),

      weight: (map['weight'] as num?)?.toDouble(),

      // allergies: map['allergies'] as String?,

      // medicalConditions: map['medicalConditions'] as String?,

      // currentMedications: map['currentMedications'] as String?,

      // emergencyNotes: map['emergencyNotes'] as String?,
      gender: _parseString(map['gender']),
      bloodGroup: _parseString(map['bloodGroup']),
      allergies: _parseString(map['allergies']),
      medicalConditions: _parseString(map['medicalConditions']),
      currentMedications: _parseString(map['currentMedications']),
      emergencyNotes: _parseString(map['emergencyNotes']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateOfBirth': dateOfBirth,

      'gender': gender,

      'bloodGroup': bloodGroup,

      'height': height,

      'weight': weight,

      'allergies': allergies,

      'medicalConditions': medicalConditions,

      'currentMedications': currentMedications,

      'emergencyNotes': emergencyNotes,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
