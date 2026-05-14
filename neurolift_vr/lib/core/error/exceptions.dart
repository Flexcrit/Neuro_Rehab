/// Base exception classes for the data layer.

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'An unexpected server error occurred.',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'An error occurred while accessing the local cache.',
  });

  @override
  String toString() => 'CacheException(message: $message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'No internet connection available.',
  });

  @override
  String toString() => 'NetworkException(message: $message)';
}
