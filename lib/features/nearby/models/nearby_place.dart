enum TravelMode { walking, driving, transit }

class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceInMeters,
    this.phoneNumber,
    this.isOpen = true,
    this.googleMapsUri,
    this.isFavorite = false,
    this.openTime,
    this.closeTime,
    this.travelTimeInMinutes,
    this.travelMode = TravelMode.driving,
  });

  // ============================================================
  // BASIC PLACE INFORMATION
  // ============================================================

  final String id;
  final String name;
  final String category;
  final String address;

  // ============================================================
  // LOCATION
  // ============================================================

  final double latitude;
  final double longitude;

  final double distanceInMeters;

  // ============================================================
  // CONTACT
  // ============================================================

  final String? phoneNumber;

  // ============================================================
  // OPEN / CLOSE
  // ============================================================

  final bool? isOpen;

  final String? openTime;
  final String? closeTime;

  // ============================================================
  // GOOGLE MAPS
  // ============================================================

  final String? googleMapsUri;

  // ============================================================
  // FAVORITE
  // ============================================================

  final bool isFavorite;

  // ============================================================
  // TRAVEL INFORMATION
  // ============================================================

  final int? travelTimeInMinutes;

  final TravelMode travelMode;

  // ============================================================
  // DISTANCE TEXT
  // ============================================================

  String get distanceText {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m away';
    }

    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';
  }

  // ============================================================
  // TRAVEL TIME TEXT
  // ============================================================

  String? get travelTimeText {
    if (travelTimeInMinutes == null) {
      return null;
    }

    if (travelTimeInMinutes! < 1) {
      return '< 1 min';
    }

    return '$travelTimeInMinutes min';
  }

  // ============================================================
  // OPENING HOURS TEXT
  // ============================================================
  String get hoursText {
    // Opening hours are not available from Google.
    if (isOpen == null) {
      return 'Hours unavailable';
    }

    // Currently open.
    if (isOpen == true) {
      if (closeTime != null && closeTime!.isNotEmpty) {
        return 'Closes $closeTime';
      }

      return 'Open now';
    }

    // Currently closed.
    if (openTime != null && openTime!.isNotEmpty) {
      return 'Opens $openTime';
    }

    return 'Closed';
  }
  // ============================================================
  // COPY WITH
  // ============================================================

  NearbyPlace copyWith({
    bool? isFavorite,
    bool? isOpen,
    String? openTime,
    String? closeTime,
    int? travelTimeInMinutes,
    TravelMode? travelMode,
  }) {
    return NearbyPlace(
      id: id,
      name: name,
      category: category,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceInMeters: distanceInMeters,
      phoneNumber: phoneNumber,
      isOpen: isOpen ?? this.isOpen,
      googleMapsUri: googleMapsUri,
      isFavorite: isFavorite ?? this.isFavorite,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      travelTimeInMinutes: travelTimeInMinutes ?? this.travelTimeInMinutes,
      travelMode: travelMode ?? this.travelMode,
    );
  }

  // ============================================================
  // FIRESTORE / JSON MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,

      'latitude': latitude,
      'longitude': longitude,

      'distanceInMeters': distanceInMeters,

      'phoneNumber': phoneNumber,

      'isOpen': isOpen,

      'googleMapsUri': googleMapsUri,

      'isFavorite': isFavorite,

      'openTime': openTime,

      'closeTime': closeTime,

      'travelTimeInMinutes': travelTimeInMinutes,

      'travelMode': travelMode.name,
    };
  }

  // ============================================================
  // FROM FIRESTORE / JSON MAP
  // ============================================================

  factory NearbyPlace.fromMap(Map<String, dynamic> map) {
    return NearbyPlace(
      id: map['id'] as String? ?? '',

      name: map['name'] as String? ?? 'Unknown place',

      category: map['category'] as String? ?? 'Place',

      address: map['address'] as String? ?? 'Address unavailable',

      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,

      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,

      distanceInMeters: (map['distanceInMeters'] as num?)?.toDouble() ?? 0,

      phoneNumber: map['phoneNumber'] as String?,

      isOpen: map['isOpen'] as bool? ?? true,

      googleMapsUri: map['googleMapsUri'] as String?,

      isFavorite: map['isFavorite'] as bool? ?? false,

      openTime: map['openTime'] as String?,

      closeTime: map['closeTime'] as String?,

      travelTimeInMinutes: (map['travelTimeInMinutes'] as num?)?.toInt(),

      travelMode: TravelMode.values.firstWhere(
        (value) => value.name == map['travelMode'],
        orElse: () => TravelMode.driving,
      ),
    );
  }
}

// ============================================================================
// LOCATION SUGGESTION
// ============================================================================

class LocationSuggestion {
  const LocationSuggestion({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  final String placeId;

  final String description;

  final String? mainText;

  final String? secondaryText;
}
