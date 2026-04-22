class EndpointConstants {
  static const String baseUrl = '';
  static const String firstEndpoint = '';
  static const String secondEndpoint = '';

  static const String placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';
  static const String nearbySearch = '/nearbysearch/json';
  static const String placesApiKey = 'AIzaSyCn2_UWt0RFlO2r83-KXR2kVuIsiukMRJ4';

  static String placePhotoUrl(String photoReference, {int maxWidth = 400}) =>
      '$placesBaseUrl/photo'
      '?maxwidth=$maxWidth'
      '&photoreference=$photoReference'
      '&key=$placesApiKey';
}
