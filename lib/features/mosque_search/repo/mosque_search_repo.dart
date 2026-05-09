import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosques_app/core/constants/app_constants.dart';
import 'package:mosques_app/core/network/endpoint_constants.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class MosqueSearchRepo {
  late final Dio _dio;

  static const int _maxRetries = 3;
  static const _connectTimeout = Duration(seconds: 20);
  static const _receiveTimeout = Duration(seconds: 45);

  MosqueSearchRepo() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EndpointConstants.placesBaseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
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
    String language = 'en',
  }) async {
    DioException? lastError;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          EndpointConstants.nearbySearch,
          queryParameters: {
            'location': '$lat,$lng',
            'radius': radius,
            'type': 'mosque',
            'key': EndpointConstants.placesApiKey,
            'language': language,
          },
        );

        final results = response.data?['results'] as List<dynamic>? ?? [];

        return results.map((json) {
          final place = json as Map<String, dynamic>;
          final placeLoc =
              place['geometry']['location'] as Map<String, dynamic>;
          final distMeters = Geolocator.distanceBetween(
            lat,
            lng,
            (placeLoc['lat'] as num).toDouble(),
            (placeLoc['lng'] as num).toDouble(),
          );
          return MosqueModel.fromJson(place, distanceMeters: distMeters);
        }).toList()
          ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      } on DioException catch (e) {
        if (_isRetryable(e) && attempt < _maxRetries) {
          final delay = Duration(seconds: attempt * 2);
          debugPrint(
            '[MosqueSearchRepo] Attempt $attempt failed (${e.type.name}) — '
            'retrying in ${delay.inSeconds}s…',
          );
          await Future.delayed(delay);
          lastError = e;
          continue;
        }
        rethrow;
      }
    }

    throw lastError!;
  }

  static bool _isRetryable(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError;
}
