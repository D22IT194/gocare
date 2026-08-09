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

  final String id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceInMeters;
  final String? phoneNumber;
  final bool isOpen;
  final String? googleMapsUri;

  /// Whether the user has saved/bookmarked this place.
  final bool isFavorite;

  /// Human readable open/close time, e.g. "09:00 AM" / "09:00 PM".
  /// Leave null if hours are unknown.
  final String? openTime;
  final String? closeTime;

  /// Estimated time to reach the place, in minutes (from a routing API).
  final int? travelTimeInMinutes;
  final TravelMode travelMode;

  String get distanceText {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m away';
    }
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';
  }

  String? get travelTimeText {
    if (travelTimeInMinutes == null) return null;
    if (travelTimeInMinutes! < 1) return '< 1 min';
    return '$travelTimeInMinutes min';
  }

  /// Short status line: "Closes 09:00 PM" / "Opens 09:00 AM" / fallback.
  String get hoursText {
    if (openTime == null || closeTime == null) {
      return isOpen ? 'Open now' : 'Closed';
    }
    return isOpen ? 'Closes $closeTime' : 'Opens $openTime';
  }

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
      googleMapsUri: googleMapsUri,
      isOpen: isOpen ?? this.isOpen,
      isFavorite: isFavorite ?? this.isFavorite,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      travelTimeInMinutes: travelTimeInMinutes ?? this.travelTimeInMinutes,
      travelMode: travelMode ?? this.travelMode,
    );
  }
}