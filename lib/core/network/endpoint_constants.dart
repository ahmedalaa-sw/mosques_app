import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndpointConstants {
  static const String baseUrl = '';
  static const String firstEndpoint = '';
  static const String secondEndpoint = '';

  static const String placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';
  static const String nearbySearch = '/nearbysearch/json';
  
  // Load API key from .env file
  static String get placesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  static String placePhotoUrl(String photoReference, {int maxWidth = 400}) =>
      '$placesBaseUrl/photo'
      '?maxwidth=$maxWidth'
      '&photoreference=$photoReference'
      '&key=$placesApiKey';
}
