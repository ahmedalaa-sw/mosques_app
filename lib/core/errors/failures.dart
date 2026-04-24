abstract class Failure {
  final String message;
  final int statusCode;

  Failure(this.message, this.statusCode);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server Error', super.statusCode = 500]);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = 'Cache Error', super.statusCode = 500]);
}

class LocationFailure extends Failure {
  LocationFailure([
    super.message = 'Location service error',
    super.statusCode = 503,
  ]);
}

class PermissionFailure extends Failure {
  PermissionFailure([
    super.message = 'Permission denied',
    super.statusCode = 403,
  ]);
}
// Add more failures as needed
