import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../config/places_config.dart';
import '../models/nearby_place.dart';
import 'package:flutter/foundation.dart';

enum NearbyPlaceCategory {
  hospital,
  pharmacy,
  clinic,
  emergency,
  police,
  fireStation,
}

extension NearbyPlaceCategoryExtension on NearbyPlaceCategory {
  String get displayName {
    switch (this) {
      case NearbyPlaceCategory.hospital:
        return 'Hospitals';

      case NearbyPlaceCategory.pharmacy:
        return 'Pharmacies';

      case NearbyPlaceCategory.clinic:
        return 'Clinics';

      case NearbyPlaceCategory.emergency:
        return 'Emergency Centers';

      case NearbyPlaceCategory.police:
        return 'Police Stations';

      case NearbyPlaceCategory.fireStation:
        return 'Fire Stations';
    }
  }

  List<String> get includedTypes {
    switch (this) {
      case NearbyPlaceCategory.hospital:
        return ['hospital'];

      case NearbyPlaceCategory.pharmacy:
        return ['pharmacy'];

      case NearbyPlaceCategory.clinic:
        return ['medical_clinic'];

      case NearbyPlaceCategory.emergency:
        return ['hospital'];

      case NearbyPlaceCategory.police:
        return ['police'];

      case NearbyPlaceCategory.fireStation:
        return ['fire_station'];
    }
  }
}

class NearbyPlacesService {
  const NearbyPlacesService();

  Future<List<NearbyPlace>> searchNearby({
    required double latitude,
    required double longitude,
    required NearbyPlaceCategory category,
    double radiusInMeters = 5000,
  }) async {
    final apiKey = PlacesConfig.apiKey.trim();

    if (apiKey.isEmpty) {
      throw Exception('Google Places API key is not configured.');
    }

    final uri = Uri.parse(PlacesConfig.nearbySearchUrl);

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'places.id,'
          'places.displayName,'
          'places.formattedAddress,'
          'places.location,'
          'places.types,'
          'places.primaryType,'
          'places.businessStatus,'
          'places.googleMapsUri,'
          'places.nationalPhoneNumber',
    };

    final body = {
      'includedTypes': category.includedTypes,
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

    debugPrint('==============================');
    debugPrint('GOOGLE PLACES REQUEST');
    debugPrint('URL: $uri');
    debugPrint('CATEGORY: ${category.displayName}');
    debugPrint('LATITUDE: $latitude');
    debugPrint('LONGITUDE: $longitude');
    debugPrint('RADIUS: $radiusInMeters');
    debugPrint('==============================');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('==============================');
      debugPrint('GOOGLE PLACES RESPONSE');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==============================');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          _extractErrorMessage(response.body, response.statusCode),
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final places = decoded['places'] as List<dynamic>? ?? [];

      debugPrint('PLACES FOUND: ${places.length}');

      return places
          .map(
            (place) => _parsePlace(
              place as Map<String, dynamic>,
              category,
              latitude,
              longitude,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('GOOGLE PLACES ERROR: $e');

      rethrow;
    }
  }

  NearbyPlace _parsePlace(
    Map<String, dynamic> json,
    NearbyPlaceCategory category,
    double currentLatitude,
    double currentLongitude,
  ) {
    final displayName = json['displayName'] as Map<String, dynamic>?;

    final location = json['location'] as Map<String, dynamic>?;

    final placeLatitude = (location?['latitude'] as num?)?.toDouble() ?? 0;

    final placeLongitude = (location?['longitude'] as num?)?.toDouble() ?? 0;

    final distance = _calculateDistance(
      currentLatitude,
      currentLongitude,
      placeLatitude,
      placeLongitude,
    );

    return NearbyPlace(
      id: json['id'] as String? ?? '',

      name: displayName?['text'] as String? ?? 'Unknown place',

      category: category.displayName,

      address: json['formattedAddress'] as String? ?? 'Address unavailable',

      latitude: placeLatitude,

      longitude: placeLongitude,

      distanceInMeters: distance,

      phoneNumber: json['nationalPhoneNumber'] as String?,

      isOpen: json['businessStatus'] != 'CLOSED_PERMANENTLY',

      googleMapsUri: json['googleMapsUri'] as String?,
    );
  }

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

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;

      final error = json['error'] as Map<String, dynamic>?;

      final message = error?['message'] as String?;

      final status = error?['status'] as String?;

      if (message != null && message.isNotEmpty) {
        if (status != null && status.isNotEmpty) {
          return '$status: $message';
        }

        return message;
      }
    } catch (_) {
      // Ignore JSON parsing errors.
    }

    return 'Places request failed '
        'with status $statusCode.';
  }
}
