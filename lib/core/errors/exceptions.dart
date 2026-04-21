import 'package:dio/dio.dart';

abstract class Failure implements Exception {
  final String errmessage;
  Failure(
    this.errmessage,
  );
}

class ServerFailure extends Failure {
  ServerFailure(super.errmessage);

  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('connection Time Out With Api Server');

      case DioExceptionType.sendTimeout:
        return ServerFailure('Time Out with Api Server');

      case DioExceptionType.receiveTimeout:
        return ServerFailure('Time Out with Api Server');

      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioError.response?.statusCode,
          dioError.response?.data,
        );

      case DioExceptionType.cancel:
        return ServerFailure('Request to Api Server was Cancelled');

      case DioExceptionType.unknown:
        return ServerFailure('No Internet Connection');

      default:
        return ServerFailure('Opps There was an Error Please try again later');
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 422)
      return ServerFailure(response['message'] ?? ['Bad Request']);
    else if (statusCode == 404) {
      return ServerFailure("Not Found");
    } else if (statusCode == 500) {
      return ServerFailure("Internal Server Error");
    } else {
      return ServerFailure("Opps There was an Error Please try again later");
    }
  }
}
