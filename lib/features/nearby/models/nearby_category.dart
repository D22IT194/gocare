import 'package:flutter/material.dart';

/// ============================================================================
/// NEARBY PLACE CATEGORY
/// ============================================================================
///
/// All categories available in the Nearby feature.
///
/// IMPORTANT:
/// Google Places does NOT support every medical specialization as a direct
/// searchable place type.
///
/// Therefore specialized categories such as:
///
/// - Eye Care
/// - Mental Health
/// - Cardiology
/// - Pediatric Care
/// - Orthopedic
///
/// use the supported Google Places type `doctor` and a more specific
/// `searchQuery`.
///
/// Do NOT use unsupported Google Places types such as:
///
/// - ophthalmologist
/// - cardiologist
/// - pediatrician
/// - orthopedic_surgeon
/// ============================================================================

enum NearbyPlaceCategory {
  // --------------------------------------------------------------------------
  // HEALTHCARE
  // --------------------------------------------------------------------------

  hospital,
  clinic,
  doctor,
  pharmacy,
  medicalLab,
  dentalClinic,

  eyeCare,
  mentalHealth,
  cardiology,
  pediatricCare,
  orthopedic,

  maternity,

  diagnosticCenter,
  physiotherapy,

  // --------------------------------------------------------------------------
  // EMERGENCY & SAFETY
  // --------------------------------------------------------------------------

  emergency,
  police,
  fireStation,
  ambulance,

  // --------------------------------------------------------------------------
  // SUPPORT
  // --------------------------------------------------------------------------

  bloodBank,
  rehabilitation,
  homeHealthcare,
  nursingService,
  medicalEquipment,
}

/// ============================================================================
/// CATEGORY EXTENSION
/// ============================================================================

extension NearbyPlaceCategoryExtension on NearbyPlaceCategory {
  // ==========================================================================
  // DISPLAY NAME
  // ==========================================================================

  String get displayName {
    switch (this) {
      // ----------------------------------------------------------------------
      // HEALTHCARE
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.hospital:
        return 'Hospitals';

      case NearbyPlaceCategory.clinic:
        return 'Clinics';

      case NearbyPlaceCategory.doctor:
        return 'Doctors';

      case NearbyPlaceCategory.pharmacy:
        return 'Pharmacies';

      case NearbyPlaceCategory.medicalLab:
        return 'Medical Labs';

      case NearbyPlaceCategory.dentalClinic:
        return 'Dental Clinics';

      case NearbyPlaceCategory.eyeCare:
        return 'Eye Care';

      case NearbyPlaceCategory.mentalHealth:
        return 'Mental Health';

      case NearbyPlaceCategory.cardiology:
        return 'Cardiology';

      case NearbyPlaceCategory.pediatricCare:
        return 'Pediatric Care';

      case NearbyPlaceCategory.orthopedic:
        return 'Orthopedic';

      case NearbyPlaceCategory.maternity:
        return "Women's Health";

      case NearbyPlaceCategory.diagnosticCenter:
        return 'Diagnostic Centers';

      case NearbyPlaceCategory.physiotherapy:
        return 'Physiotherapy';

      // ----------------------------------------------------------------------
      // EMERGENCY & SAFETY
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.emergency:
        return 'Emergency Centers';

      case NearbyPlaceCategory.police:
        return 'Police Stations';

      case NearbyPlaceCategory.fireStation:
        return 'Fire Stations';

      case NearbyPlaceCategory.ambulance:
        return 'Ambulance Services';

      // ----------------------------------------------------------------------
      // SUPPORT
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.bloodBank:
        return 'Blood Banks';

      case NearbyPlaceCategory.rehabilitation:
        return 'Rehabilitation';

      case NearbyPlaceCategory.homeHealthcare:
        return 'Home Healthcare';

      case NearbyPlaceCategory.nursingService:
        return 'Nursing Services';

      case NearbyPlaceCategory.medicalEquipment:
        return 'Medical Equipment';
    }
  }

  // ==========================================================================
  // SEARCH QUERY
  // ==========================================================================
  //
  // Used by Google Places Text Search to improve category-specific results.
  //
  // ==========================================================================

  String get searchQuery {
    switch (this) {
      // ----------------------------------------------------------------------
      // BASIC HEALTHCARE
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.hospital:
        return 'hospitals';

      case NearbyPlaceCategory.clinic:
        return 'clinics';

      case NearbyPlaceCategory.doctor:
        return 'doctors';

      case NearbyPlaceCategory.pharmacy:
        return 'pharmacies';

      case NearbyPlaceCategory.medicalLab:
        return 'medical labs';

      case NearbyPlaceCategory.dentalClinic:
        return 'dental clinics';

      // ----------------------------------------------------------------------
      // SPECIALIZED HEALTHCARE
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.eyeCare:
        return 'eye care ophthalmology doctors';

      case NearbyPlaceCategory.mentalHealth:
        return 'mental health doctors psychologists';

      case NearbyPlaceCategory.cardiology:
        return 'cardiologists heart specialists';

      case NearbyPlaceCategory.pediatricCare:
        return 'pediatricians child doctors';

      case NearbyPlaceCategory.orthopedic:
        return 'orthopedic doctors';

      // ----------------------------------------------------------------------
      // WOMEN'S HEALTH
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.maternity:
        return 'maternity womens health gynecologists';

      // ----------------------------------------------------------------------
      // DIAGNOSTIC / THERAPY
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.diagnosticCenter:
        return 'diagnostic centers';

      case NearbyPlaceCategory.physiotherapy:
        return 'physiotherapy centers';

      // ----------------------------------------------------------------------
      // EMERGENCY & SAFETY
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.emergency:
        return 'emergency centers hospitals';

      case NearbyPlaceCategory.police:
        return 'police stations';

      case NearbyPlaceCategory.fireStation:
        return 'fire stations';

      case NearbyPlaceCategory.ambulance:
        return 'ambulance services';

      // ----------------------------------------------------------------------
      // SUPPORT
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.bloodBank:
        return 'blood banks';

      case NearbyPlaceCategory.rehabilitation:
        return 'rehabilitation centers';

      case NearbyPlaceCategory.homeHealthcare:
        return 'home healthcare services';

      case NearbyPlaceCategory.nursingService:
        return 'nursing services';

      case NearbyPlaceCategory.medicalEquipment:
        return 'medical equipment stores';
    }
  }

  // ==========================================================================
  // GOOGLE PLACES TYPE
  // ==========================================================================
  //
  // These values are used by Nearby Search.
  //
  // Specialized medical categories intentionally use supported generic
  // Google Places types.
  //
  // ==========================================================================

  List<String> get includedTypes {
    switch (this) {
      // ----------------------------------------------------------------------
      // BASIC HEALTHCARE
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.hospital:
        return ['hospital'];

      case NearbyPlaceCategory.clinic:
        return ['medical_clinic'];

      case NearbyPlaceCategory.doctor:
        return ['doctor'];

      case NearbyPlaceCategory.pharmacy:
        return ['pharmacy'];

      case NearbyPlaceCategory.medicalLab:
        return ['medical_lab'];

      case NearbyPlaceCategory.dentalClinic:
        return ['dental_clinic'];

      // ----------------------------------------------------------------------
      // SPECIALIZED DOCTORS
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.eyeCare:
      case NearbyPlaceCategory.mentalHealth:
      case NearbyPlaceCategory.cardiology:
      case NearbyPlaceCategory.pediatricCare:
      case NearbyPlaceCategory.orthopedic:
        return ['doctor'];

      // ----------------------------------------------------------------------
      // WOMEN'S HEALTH
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.maternity:
        return ['hospital'];

      // ----------------------------------------------------------------------
      // DIAGNOSTIC / THERAPY
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.diagnosticCenter:
        return ['medical_lab'];

      case NearbyPlaceCategory.physiotherapy:
        return ['physiotherapist'];

      // ----------------------------------------------------------------------
      // EMERGENCY & SAFETY
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.emergency:
        return ['hospital'];

      case NearbyPlaceCategory.police:
        return ['police'];

      case NearbyPlaceCategory.fireStation:
        return ['fire_station'];

      case NearbyPlaceCategory.ambulance:
        return ['hospital'];

      // ----------------------------------------------------------------------
      // SUPPORT
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.bloodBank:
        return ['hospital'];

      case NearbyPlaceCategory.rehabilitation:
        return ['physiotherapist'];

      case NearbyPlaceCategory.homeHealthcare:
        return ['doctor'];

      case NearbyPlaceCategory.nursingService:
        return ['hospital'];

      case NearbyPlaceCategory.medicalEquipment:
        return ['medical_center'];
    }
  }

  // ==========================================================================
  // ICON
  // ==========================================================================

  IconData get icon {
    switch (this) {
      // ----------------------------------------------------------------------
      // HEALTHCARE
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.hospital:
        return Icons.local_hospital_outlined;

      case NearbyPlaceCategory.clinic:
        return Icons.medical_services_outlined;

      case NearbyPlaceCategory.doctor:
        return Icons.person_outline;

      case NearbyPlaceCategory.pharmacy:
        return Icons.local_pharmacy_outlined;

      case NearbyPlaceCategory.medicalLab:
        return Icons.science_outlined;

      case NearbyPlaceCategory.dentalClinic:
        return Icons.health_and_safety_outlined;

      case NearbyPlaceCategory.eyeCare:
        return Icons.visibility_outlined;

      case NearbyPlaceCategory.mentalHealth:
        return Icons.psychology_outlined;

      case NearbyPlaceCategory.cardiology:
        return Icons.favorite_border;

      case NearbyPlaceCategory.pediatricCare:
        return Icons.child_care_outlined;

      case NearbyPlaceCategory.orthopedic:
        return Icons.accessibility_new_outlined;

      case NearbyPlaceCategory.maternity:
        return Icons.pregnant_woman;

      case NearbyPlaceCategory.diagnosticCenter:
        return Icons.biotech_outlined;

      case NearbyPlaceCategory.physiotherapy:
        return Icons.accessibility_outlined;

      // ----------------------------------------------------------------------
      // EMERGENCY & SAFETY
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.emergency:
        return Icons.emergency_outlined;

      case NearbyPlaceCategory.police:
        return Icons.local_police_outlined;

      case NearbyPlaceCategory.fireStation:
        return Icons.local_fire_department_outlined;

      case NearbyPlaceCategory.ambulance:
        return Icons.airport_shuttle_outlined;

      // ----------------------------------------------------------------------
      // SUPPORT
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.bloodBank:
        return Icons.bloodtype_outlined;

      case NearbyPlaceCategory.rehabilitation:
        return Icons.self_improvement_outlined;

      case NearbyPlaceCategory.homeHealthcare:
        return Icons.house_outlined;

      case NearbyPlaceCategory.nursingService:
        return Icons.health_and_safety_outlined;

      case NearbyPlaceCategory.medicalEquipment:
        return Icons.medical_information_outlined;
    }
  }

  // ==========================================================================
  // CATEGORY GROUP
  // ==========================================================================

  String get group {
    switch (this) {
      // ----------------------------------------------------------------------
      // HEALTHCARE
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.hospital:
      case NearbyPlaceCategory.clinic:
      case NearbyPlaceCategory.doctor:
      case NearbyPlaceCategory.pharmacy:
      case NearbyPlaceCategory.medicalLab:
      case NearbyPlaceCategory.dentalClinic:
      case NearbyPlaceCategory.eyeCare:
      case NearbyPlaceCategory.mentalHealth:
      case NearbyPlaceCategory.cardiology:
      case NearbyPlaceCategory.pediatricCare:
      case NearbyPlaceCategory.orthopedic:
      case NearbyPlaceCategory.maternity:
      case NearbyPlaceCategory.diagnosticCenter:
      case NearbyPlaceCategory.physiotherapy:
        return 'Healthcare';

      // ----------------------------------------------------------------------
      // EMERGENCY & SAFETY
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.emergency:
      case NearbyPlaceCategory.police:
      case NearbyPlaceCategory.fireStation:
      case NearbyPlaceCategory.ambulance:
        return 'Emergency & Safety';

      // ----------------------------------------------------------------------
      // SUPPORT
      // ----------------------------------------------------------------------

      case NearbyPlaceCategory.bloodBank:
      case NearbyPlaceCategory.rehabilitation:
      case NearbyPlaceCategory.homeHealthcare:
      case NearbyPlaceCategory.nursingService:
      case NearbyPlaceCategory.medicalEquipment:
        return 'Support';
    }
  }

  // ==========================================================================
  // CATEGORY ID
  // ==========================================================================
  //
  // Useful when saving/searching category information or comparing categories.
  //
  // ==========================================================================

  String get id {
    return name;
  }

  // ==========================================================================
  // SHORT DESCRIPTION
  // ==========================================================================

  String get description {
    switch (this) {
      case NearbyPlaceCategory.hospital:
        return 'Hospitals and major healthcare facilities';

      case NearbyPlaceCategory.clinic:
        return 'Clinics and outpatient healthcare';

      case NearbyPlaceCategory.doctor:
        return 'Doctors and medical specialists';

      case NearbyPlaceCategory.pharmacy:
        return 'Nearby pharmacies and medicine stores';

      case NearbyPlaceCategory.medicalLab:
        return 'Medical laboratories and testing';

      case NearbyPlaceCategory.dentalClinic:
        return 'Dentists and dental clinics';

      case NearbyPlaceCategory.eyeCare:
        return 'Eye care and ophthalmology services';

      case NearbyPlaceCategory.mentalHealth:
        return 'Mental health and psychological care';

      case NearbyPlaceCategory.cardiology:
        return 'Heart specialists and cardiology services';

      case NearbyPlaceCategory.pediatricCare:
        return 'Children and pediatric healthcare';

      case NearbyPlaceCategory.orthopedic:
        return 'Bone, joint and orthopedic care';

      case NearbyPlaceCategory.maternity:
        return 'Maternity and women’s healthcare';

      case NearbyPlaceCategory.diagnosticCenter:
        return 'Diagnostic testing and imaging centers';

      case NearbyPlaceCategory.physiotherapy:
        return 'Physiotherapy and physical rehabilitation';

      case NearbyPlaceCategory.emergency:
        return 'Emergency healthcare services';

      case NearbyPlaceCategory.police:
        return 'Nearby police stations';

      case NearbyPlaceCategory.fireStation:
        return 'Nearby fire and rescue stations';

      case NearbyPlaceCategory.ambulance:
        return 'Ambulance and emergency transport';

      case NearbyPlaceCategory.bloodBank:
        return 'Blood banks and blood donation services';

      case NearbyPlaceCategory.rehabilitation:
        return 'Rehabilitation and recovery services';

      case NearbyPlaceCategory.homeHealthcare:
        return 'Healthcare services provided at home';

      case NearbyPlaceCategory.nursingService:
        return 'Nursing and patient care services';

      case NearbyPlaceCategory.medicalEquipment:
        return 'Medical equipment and healthcare supplies';
    }
  }
}