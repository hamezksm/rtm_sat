class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}
