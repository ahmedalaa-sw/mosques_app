import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosques_app/core/constants/app_constants.dart';
import 'package:mosques_app/core/network/endpoint_constants.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class MosqueSearchRepo {
  late final Dio _dio;

  MosqueSearchRepo() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EndpointConstants.placesBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  Future<List<MosqueModel>> fetchNearbyMosques({
    required double lat,
    required double lng,
    int radius = AppConstants.defaultSearchRadiusMeters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      EndpointConstants.nearbySearch,
      queryParameters: {
        'location': '$lat,$lng',
        'radius': radius,
        'type': 'mosque',
        'key': EndpointConstants.placesApiKey,
      },
    );

    final results = response.data?['results'] as List<dynamic>? ?? [];

    return results.map((json) {
      final place = json as Map<String, dynamic>;
      final placeLoc = place['geometry']['location'] as Map<String, dynamic>;
      final distMeters = Geolocator.distanceBetween(
        lat,
        lng,
        (placeLoc['lat'] as num).toDouble(),
        (placeLoc['lng'] as num).toDouble(),
      );
      return MosqueModel.fromJson(place, distanceMeters: distMeters);
    }).toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }
}
