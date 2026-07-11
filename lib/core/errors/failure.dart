import 'app_exception.dart';

/// User-facing failure shown by providers/screens. Never carries a raw
/// exception or stack trace — just a message safe to render in the UI.
abstract class Failure {
  final String message;

  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Check your connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'The server returned an error.']);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Could not read the response.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

class FileFailure extends Failure {
  const FileFailure([super.message = 'Could not read this file.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

/// Maps any exception thrown by a data source into a UI-safe [Failure].
Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) return NetworkFailure(error.message);
  if (error is ServerException) return ServerFailure(error.message);
  if (error is ParseException) return ParseFailure(error.message);
  if (error is NotFoundException) return NotFoundFailure(error.message);
  if (error is CacheException) return CacheFailure(error.message);
  if (error is FileException) return FileFailure(error.message);
  return const UnknownFailure();
}
