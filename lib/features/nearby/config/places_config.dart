class PlacesConfig {
  const PlacesConfig._();

  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  static const String nearbySearchUrl =
      'https://places.googleapis.com/v1/places:searchNearby';

  static const String textSearchUrl =
      'https://places.googleapis.com/v1/places:searchText';
}