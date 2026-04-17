import 'package:dio/dio.dart';
import 'package:mosques_app/core/network/endpoint_constants.dart';

class DioHelper {
  static late Dio dio;
  static init() {
    dio = Dio(
      BaseOptions(
          baseUrl: EndpointConstants.baseUrl,
          receiveDataWhenStatusError: true,
          connectTimeout: const Duration(seconds: 50),
          receiveTimeout: const Duration(seconds: 50),
          headers: {
            "Content-Type": "application/json",
          }),
    );
  }

  static Future<Response> getData({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await dio.get(endpoint, queryParameters: queryParameters);
    return res;
  }
}
