/// Exceptions thrown by data sources. Repositories catch these and never let
/// them leak to providers as raw [Exception]/[Error] types.
class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error. Check your connection.', super.cause]);
}

class ServerException extends AppException {
  const ServerException([super.message = 'The server returned an error.', super.cause]);
}

class ParseException extends AppException {
  const ParseException([super.message = 'Could not read the response.', super.cause]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found.', super.cause]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Could not read local data.', super.cause]);
}

class FileException extends AppException {
  const FileException([super.message = 'Could not read this file.', super.cause]);
}
