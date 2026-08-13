import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/places_config.dart';
import '../models/nearby_category.dart';
import '../models/nearby_place.dart';

/// ============================================================================
/// NEARBY PLACE SERVICE
/// ============================================================================
///
/// Handles:
///
/// 1. Nearby category search
/// 2. Text search for places
/// 3. Location autocomplete
/// 4. Place details / coordinates
///
/// IMPORTANT:
/// - This service uses Google Places API (New).
/// - Category filtering only uses Google-supported request types.
/// - Specialized categories such as Cardiology, Eye Care, Pediatrics etc.
///   use `doctor` as their Google type and rely on the text query for
///   specialization.
/// ============================================================================

class NearbyPlacesService {
  const NearbyPlacesService();

  // ==========================================================================
  // GOOGLE PLACES ENDPOINTS
  // ==========================================================================

  static const String _nearbyUrl =
      'https://places.googleapis.com/v1/places:searchNearby';

  static const String _textSearchUrl =
      'https://places.googleapis.com/v1/places:searchText';

  static const String _autocompleteUrl =
      'https://places.googleapis.com/v1/places:autocomplete';

  static const String _detailsUrl = 'https://places.googleapis.com/v1/places';

  // ==========================================================================
  // API KEY
  // ==========================================================================

  String get _apiKey => PlacesConfig.apiKey.trim();

  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': _apiKey,
  };

  // ==========================================================================
  // 1. NEARBY CATEGORY SEARCH
  // ==========================================================================

  Future<List<NearbyPlace>> searchNearby({
    required double latitude,
    required double longitude,
    required NearbyPlaceCategory category,
    double radiusInMeters = 5000,
  }) async {
    _validateApiKey();

    final uri = Uri.parse(_nearbyUrl);

    final headers = {
      ..._baseHeaders,
      'X-Goog-FieldMask':
          'places.id,'
          'places.displayName,'
          'places.formattedAddress,'
          'places.location,'
          'places.types,'
          'places.primaryType,'
          'places.businessStatus,'
          'places.googleMapsUri,'
          'places.nationalPhoneNumber,'
          'places.currentOpeningHours,'
          'places.regularOpeningHours,'
          'places.utcOffsetMinutes',
    };

    final body = <String, dynamic>{
      'includedTypes': _safeIncludedTypes(category),

      'maxResultCount': 20,

      'rankPreference': 'DISTANCE',

      'locationRestriction': {
        'circle': {
          'center': {'latitude': latitude, 'longitude': longitude},
          'radius': radiusInMeters,
        },
      },

      'regionCode': 'IN',
    };

    debugPrint('================================');
    debugPrint('GOOGLE PLACES NEARBY SEARCH');
    debugPrint('CATEGORY: ${category.displayName}');
    debugPrint('TYPE: ${_safeIncludedTypes(category)}');
    debugPrint('LATITUDE: $latitude');
    debugPrint('LONGITUDE: $longitude');
    debugPrint('RADIUS: $radiusInMeters');
    debugPrint('================================');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint('NEARBY SEARCH STATUS: ${response.statusCode}');

    debugPrint('NEARBY SEARCH BODY: ${response.body}');

    _throwIfFailed(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final places = decoded['places'] as List<dynamic>? ?? [];

    return places
        .whereType<Map<String, dynamic>>()
        .map(
          (item) =>
              _parsePlace(item, latitude, longitude, category.displayName),
        )
        .toList();
  }

  // ==========================================================================
  // 2. TEXT SEARCH
  // ==========================================================================
  //
  // Example:
  //
  // Selected category = Hospitals
  // Search = "Apollo"
  //
  // Google query:
  // "Apollo"
  //
  // includedType:
  // "hospital"
  //
  // Result:
  // Apollo Hospitals
  // Apollo Clinic
  // etc.
  //
  // ==========================================================================
  Future<List<NearbyPlace>> searchText({
    required String query,
    required double latitude,
    required double longitude,
    NearbyPlaceCategory? category,
  }) async {
    _validateApiKey();

    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse(_textSearchUrl);

    final headers = {
      ..._baseHeaders,
      'X-Goog-FieldMask':
          'places.id,'
          'places.displayName,'
          'places.formattedAddress,'
          'places.location,'
          'places.types,'
          'places.primaryType,'
          'places.businessStatus,'
          'places.googleMapsUri,'
          'places.nationalPhoneNumber,'
          'places.currentOpeningHours,'
          'places.regularOpeningHours,'
          'places.utcOffsetMinutes',
    };

    final body = <String, dynamic>{
      'textQuery': cleanQuery,

      'maxResultCount': 20,

      'rankPreference': 'DISTANCE',

      'locationBias': {
        'circle': {
          'center': {'latitude': latitude, 'longitude': longitude},
          'radius': 10000,
        },
      },

      'regionCode': 'IN',
    };

    // ------------------------------------------------------------------------
    // CATEGORY FILTER
    // ------------------------------------------------------------------------
    //
    // Text Search supports ONLY ONE includedType.
    //
    // Therefore:
    //
    // Hospital       -> hospital
    // Clinic         -> medical_clinic
    // Doctor         -> doctor
    // Pharmacy       -> pharmacy
    // Dental         -> dental_clinic
    //
    // Specialized categories:
    //
    // Eye Care       -> doctor
    // Cardiology     -> doctor
    // Pediatrics     -> doctor
    // Orthopedic     -> doctor
    //
    // The specialization is included in the query itself by the provider/UI.
    // ------------------------------------------------------------------------

    if (category != null) {
      final type = _safeTextSearchType(category);

      if (type != null) {
        body['includedType'] = type;

        // Strict filtering is intentionally NOT enabled.
        //
        // This allows searches such as:
        //
        // "Apollo cardiology"
        // "children doctor"
        // "eye specialist"
        //
        // to return useful Google results even if Google's classification
        // isn't exactly the selected category.
        body['strictTypeFiltering'] = false;
      }
    }

    debugPrint('================================');
    debugPrint('GOOGLE PLACES TEXT SEARCH');
    debugPrint('QUERY: $cleanQuery');
    debugPrint('CATEGORY: ${category?.displayName ?? 'All'}');
    debugPrint(
      'GOOGLE TYPE: ${category == null ? 'none' : _safeTextSearchType(category)}',
    );
    debugPrint('LATITUDE: $latitude');
    debugPrint('LONGITUDE: $longitude');
    debugPrint('================================');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint('TEXT SEARCH STATUS: ${response.statusCode}');

    debugPrint('TEXT SEARCH BODY: ${response.body}');

    _throwIfFailed(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final places = decoded['places'] as List<dynamic>? ?? [];

    return places
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => _parsePlace(
            item,
            latitude,
            longitude,
            category?.displayName ?? _categoryFromPlace(item),
          ),
        )
        .toList();
  }

  // ==========================================================================
  // 3. SEARCH CATEGORY + PLACE NAME
  // ==========================================================================
  //
  // This is useful for your main search bar.
  //
  // Example:
  //
  // Selected category:
  // Dental Clinics
  //
  // User enters:
  // "Smile"
  //
  // We build:
  //
  // "Smile Dental Clinics"
  //
  // This gives Google more context while still allowing the user to search
  // for a specific hospital/clinic/location.
  // ==========================================================================

  Future<List<NearbyPlace>> searchCategoryAndText({
    required String query,
    required double latitude,
    required double longitude,
    NearbyPlaceCategory? category,
  }) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }

    String finalQuery = cleanQuery;

    if (category != null) {
      final categoryQuery = category.searchQuery.trim();

      if (categoryQuery.isNotEmpty &&
          !_queryAlreadyContainsCategory(cleanQuery, category)) {
        finalQuery = '$cleanQuery $categoryQuery';
      }
    }

    return searchText(
      query: finalQuery,
      latitude: latitude,
      longitude: longitude,
      category: category,
    );
  }

  // ==========================================================================
  // 4. LOCATION AUTOCOMPLETE
  // ==========================================================================

  Future<List<LocationSuggestion>> autocompleteLocation(
    String input, {
    double? latitude,
    double? longitude,
  }) async {
    _validateApiKey();

    final cleanInput = input.trim();

    if (cleanInput.length < 2) {
      return [];
    }

    final uri = Uri.parse(_autocompleteUrl);

    final headers = {
      ..._baseHeaders,
      'X-Goog-FieldMask':
          'suggestions.placePrediction.placeId,'
          'suggestions.placePrediction.text,'
          'suggestions.placePrediction.structuredFormat',
    };

    final body = <String, dynamic>{
      'input': cleanInput,

      'includedRegionCodes': ['in'],

      'sessionToken': _sessionToken(),
    };

    if (latitude != null && longitude != null) {
      body['locationBias'] = {
        'circle': {
          'center': {'latitude': latitude, 'longitude': longitude},
          'radius': 50000,
        },
      };
    }

    debugPrint('================================');
    debugPrint('GOOGLE PLACES AUTOCOMPLETE');
    debugPrint('INPUT: $cleanInput');
    debugPrint('================================');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint('AUTOCOMPLETE STATUS: ${response.statusCode}');

    _throwIfFailed(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final suggestions = decoded['suggestions'] as List<dynamic>? ?? [];

    return suggestions
        .map<LocationSuggestion?>((item) {
          final prediction = item['placePrediction'] as Map<String, dynamic>?;

          if (prediction == null) {
            return null;
          }

          final placeId = prediction['placeId'] as String?;

          if (placeId == null || placeId.isEmpty) {
            return null;
          }

          final text = prediction['text'] as Map<String, dynamic>?;

          final structured =
              prediction['structuredFormat'] as Map<String, dynamic>?;

          final main = structured?['mainText'] as Map<String, dynamic>?;

          final secondary =
              structured?['secondaryText'] as Map<String, dynamic>?;

          return LocationSuggestion(
            placeId: placeId,
            description: text?['text'] as String? ?? '',
            mainText: main?['text'] as String?,
            secondaryText: secondary?['text'] as String?,
          );
        })
        .whereType<LocationSuggestion>()
        .toList();
  }

  // ==========================================================================
  // 5. PLACE DETAILS
  // ==========================================================================

  Future<PlaceLocation> getPlaceLocation(String placeId) async {
    _validateApiKey();

    final cleanPlaceId = placeId.trim();

    if (cleanPlaceId.isEmpty) {
      throw Exception('Invalid place ID.');
    }

    final uri = Uri.parse('$_detailsUrl/$cleanPlaceId');

    final headers = {
      ..._baseHeaders,
      'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
    };

    debugPrint('================================');
    debugPrint('GOOGLE PLACE DETAILS');
    debugPrint('PLACE ID: $cleanPlaceId');
    debugPrint('================================');

    final response = await http.get(uri, headers: headers);

    debugPrint('DETAILS STATUS: ${response.statusCode}');

    _throwIfFailed(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final location = decoded['location'] as Map<String, dynamic>?;

    if (location == null) {
      throw Exception('Selected location has no coordinates.');
    }

    final latitude = (location['latitude'] as num?)?.toDouble();

    final longitude = (location['longitude'] as num?)?.toDouble();

    if (latitude == null || longitude == null) {
      throw Exception('Selected location has invalid coordinates.');
    }

    return PlaceLocation(
      placeId: decoded['id'] as String? ?? cleanPlaceId,
      name: decoded['displayName']?['text'] as String? ?? 'Selected location',
      address: decoded['formattedAddress'] as String? ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ==========================================================================
  // 6. PARSE PLACE
  // ==========================================================================

NearbyPlace _parsePlace(
  Map<String, dynamic> json,
  double currentLatitude,
  double currentLongitude,
  String category,
) {
  final displayName =
      json['displayName']
          as Map<String, dynamic>?;

  final location =
      json['location']
          as Map<String, dynamic>?;

  final latitude =
      (location?['latitude'] as num?)
          ?.toDouble() ??
      0;

  final longitude =
      (location?['longitude'] as num?)
          ?.toDouble() ??
      0;

  final distance =
      _calculateDistance(
    currentLatitude,
    currentLongitude,
    latitude,
    longitude,
  );



  String? _formatOpeningTime(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  if (value is! String) {
    return null;
  }

  if (value.isEmpty) {
    return null;
  }

  try {
    final dateTime =
        DateTime.parse(value).toLocal();

    final hour = dateTime.hour;

    final minute = dateTime.minute;

    final period =
        hour >= 12 ? 'PM' : 'AM';

    final displayHour =
        hour % 12 == 0
            ? 12
            : hour % 12;

    final displayMinute =
        minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  } catch (_) {
    return null;
  }
}

  // ============================================================
  // OPENING HOURS
  // ============================================================

  final currentOpeningHours =
      json['currentOpeningHours']
          as Map<String, dynamic>?;

  final regularOpeningHours =
      json['regularOpeningHours']
          as Map<String, dynamic>?;

  // Prefer currentOpeningHours.
  final openingHours =
      currentOpeningHours ??
      regularOpeningHours;

  // ============================================================
  // CURRENT OPEN STATUS
  // ============================================================

  final bool? isOpen =
      currentOpeningHours?['openNow']
          as bool?;

  // ============================================================
  // NEXT OPEN / CLOSE TIME
  // ============================================================

  String? openTime;

  String? closeTime;

  if (isOpen == true) {
    closeTime = _formatOpeningTime(
      openingHours?['nextCloseTime'],
    );
  } else if (isOpen == false) {
    openTime = _formatOpeningTime(
      openingHours?['nextOpenTime'],
    );
  }

  // ============================================================
  // RETURN PLACE
  // ============================================================

  return NearbyPlace(
    id:
        json['id'] as String? ??
        '',

    name:
        displayName?['text']
            as String? ??
        'Unknown place',

    category: category,

    address:
        json['formattedAddress']
            as String? ??
        'Address unavailable',

    latitude: latitude,

    longitude: longitude,

    distanceInMeters: distance,

    phoneNumber:
        json['nationalPhoneNumber']
            as String?,

    // IMPORTANT:
    // Use currentOpeningHours.openNow.
    //
    // Do NOT use businessStatus here.
    isOpen: isOpen,

    openTime: openTime,

    closeTime: closeTime,

    googleMapsUri:
        json['googleMapsUri']
            as String?,
  );
}

  // ==========================================================================
  // 7. CATEGORY FROM GOOGLE RESULT
  // ==========================================================================

  String _categoryFromPlace(Map<String, dynamic> json) {
    final primary = json['primaryType'] as String?;

    if (primary == null || primary.isEmpty) {
      return 'Nearby place';
    }

    return primary
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}'
              '${word.substring(1)}';
        })
        .join(' ');
  }

  // ==========================================================================
  // 8. SAFE NEARBY SEARCH TYPES
  // ==========================================================================
  //
  // We intentionally map categories to Google-supported types.
  //
  // Specialized categories do NOT use unsupported types such as:
  //
  // ophthalmologist
  // cardiologist
  // pediatrician
  // orthopedic_surgeon
  //
  // Those are searched using `doctor` + text query.
  // ==========================================================================

  List<String> _safeIncludedTypes(NearbyPlaceCategory category) {
    switch (category) {
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

      case NearbyPlaceCategory.eyeCare:
        return ['doctor'];

      case NearbyPlaceCategory.mentalHealth:
        return ['doctor'];

      case NearbyPlaceCategory.cardiology:
        return ['doctor'];

      case NearbyPlaceCategory.pediatricCare:
        return ['doctor'];

      case NearbyPlaceCategory.orthopedic:
        return ['doctor'];

      case NearbyPlaceCategory.maternity:
        return ['hospital'];

      case NearbyPlaceCategory.diagnosticCenter:
        return ['medical_lab'];

      case NearbyPlaceCategory.physiotherapy:
        return ['physiotherapist'];

      case NearbyPlaceCategory.emergency:
        return ['hospital'];

      case NearbyPlaceCategory.police:
        return ['police'];

      case NearbyPlaceCategory.fireStation:
        return ['fire_station'];

      case NearbyPlaceCategory.ambulance:
        return ['hospital'];

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
  // 9. SAFE TEXT SEARCH TYPE
  // ==========================================================================

  String? _safeTextSearchType(NearbyPlaceCategory category) {
    switch (category) {
      case NearbyPlaceCategory.hospital:
        return 'hospital';

      case NearbyPlaceCategory.clinic:
        return 'medical_clinic';

      case NearbyPlaceCategory.doctor:
        return 'doctor';

      case NearbyPlaceCategory.pharmacy:
        return 'pharmacy';

      case NearbyPlaceCategory.medicalLab:
        return 'medical_lab';

      case NearbyPlaceCategory.dentalClinic:
        return 'dental_clinic';

      case NearbyPlaceCategory.eyeCare:
        return 'doctor';

      case NearbyPlaceCategory.mentalHealth:
        return 'doctor';

      case NearbyPlaceCategory.cardiology:
        return 'doctor';

      case NearbyPlaceCategory.pediatricCare:
        return 'doctor';

      case NearbyPlaceCategory.orthopedic:
        return 'doctor';

      case NearbyPlaceCategory.maternity:
        return 'hospital';

      case NearbyPlaceCategory.diagnosticCenter:
        return 'medical_lab';

      case NearbyPlaceCategory.physiotherapy:
        return 'physiotherapist';

      case NearbyPlaceCategory.emergency:
        return null;

      case NearbyPlaceCategory.police:
        return 'police';

      case NearbyPlaceCategory.fireStation:
        return 'fire_station';

      case NearbyPlaceCategory.ambulance:
        return 'hospital';

      case NearbyPlaceCategory.bloodBank:
        return 'hospital';

      case NearbyPlaceCategory.rehabilitation:
        return 'physiotherapist';

      case NearbyPlaceCategory.homeHealthcare:
        return 'doctor';

      case NearbyPlaceCategory.nursingService:
        return 'hospital';

      case NearbyPlaceCategory.medicalEquipment:
        return 'medical_center';
    }
  }

  // ==========================================================================
  // 10. CHECK DUPLICATE CATEGORY WORD
  // ==========================================================================

  bool _queryAlreadyContainsCategory(
    String query,
    NearbyPlaceCategory category,
  ) {
    final normalizedQuery = query.toLowerCase().trim();

    final words = <String>[
      category.displayName.toLowerCase(),
      category.searchQuery.toLowerCase(),
    ];

    for (final word in words) {
      if (word.isEmpty) {
        continue;
      }

      if (normalizedQuery.contains(word)) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================================
  // 11. DISTANCE
  // ==========================================================================

  double _calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadius = 6371000.0;

    final lat1 = startLatitude * math.pi / 180;

    final lat2 = endLatitude * math.pi / 180;

    final deltaLat = (endLatitude - startLatitude) * math.pi / 180;

    final deltaLon = (endLongitude - startLongitude) * math.pi / 180;

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // ==========================================================================
  // 12. SESSION TOKEN
  // ==========================================================================

  String _sessionToken() {
    final random = math.Random.secure();

    return List.generate(
      16,
      (_) => random.nextInt(36).toRadixString(36),
    ).join();
  }

  // ==========================================================================
  // 13. API KEY VALIDATION
  // ==========================================================================

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception('Google Places API key is not configured.');
    }
  }

  // ==========================================================================
  // 14. HTTP ERROR HANDLING
  // ==========================================================================

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message =
        'Places request failed '
        '(${response.statusCode}).';

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final error = decoded['error'] as Map<String, dynamic>?;

      final apiMessage = error?['message'] as String?;

      final apiStatus = error?['status'] as String?;

      if (apiMessage != null && apiMessage.isNotEmpty) {
        message = apiMessage;

        if (apiStatus != null && apiStatus.isNotEmpty) {
          message = '$apiStatus: $apiMessage';
        }
      }
    } catch (_) {
      // Ignore invalid JSON.
    }

    throw Exception(message);
  }
}

// ============================================================================
// PLACE LOCATION
// ============================================================================

class PlaceLocation {
  const PlaceLocation({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
}
