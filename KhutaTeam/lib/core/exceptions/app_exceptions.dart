/// Base exception for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException(this.message, {this.code, this.originalException});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalException});
}

/// Authentication-related exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalException});
}

/// Data/Firebase exceptions
class DataException extends AppException {
  DataException(super.message, {super.code, super.originalException});
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(super.message, {super.code, this.fieldErrors});
}

/// AI Service exceptions
class AIServiceException extends AppException {
  AIServiceException(super.message, {super.code, super.originalException});
}
