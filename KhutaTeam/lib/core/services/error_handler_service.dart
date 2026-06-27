import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../exceptions/app_exceptions.dart';

class ErrorHandlerService {
  /// Converts any exception to an AppException with user-friendly message
  static AppException handleException(dynamic error) {
    if (kDebugMode) debugPrint('Error occurred: $error');

    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _handleAuthException(error);
    }

    // Firestore errors
    if (error is FirebaseException) {
      return _handleFirestoreException(error);
    }

    // Network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException') ||
        error.toString().contains('XMLHttpRequest') ||
        error.toString().contains('Failed host lookup')) {
      return NetworkException(
        'network_error'.tr(),
        code: 'NETWORK_ERROR',
        originalException: error,
      );
    }

    // Already an AppException
    if (error is AppException) {
      return error;
    }

    // Unknown error
    return DataException(
      'unexpected_error'.tr(),
      code: 'UNKNOWN',
      originalException: error,
    );
  }

  static AuthException _handleAuthException(FirebaseAuthException error) {
    String message;
    switch (error.code) {
      case 'user-not-found':
        message = 'user_not_found'.tr();
        break;
      case 'wrong-password':
        message = 'wrong_password'.tr();
        break;
      case 'email-already-in-use':
        message = 'email_already_in_use'.tr();
        break;
      case 'weak-password':
        message = 'weak_password'.tr();
        break;
      case 'invalid-email':
        message = 'invalid_email'.tr();
        break;
      case 'too-many-requests':
        message = 'too_many_requests'.tr();
        break;
      case 'network-request-failed':
        message = 'network_error'.tr();
        break;
      default:
        message = 'error_auth_generic'.tr();
    }
    return AuthException(message, code: error.code, originalException: error);
  }

  static DataException _handleFirestoreException(FirebaseException error) {
    String message;
    switch (error.code) {
      case 'permission-denied':
        message = 'error_permission_denied'.tr();
        break;
      case 'unavailable':
        message = 'error_service_unavailable'.tr();
        break;
      case 'not-found':
        message = 'error_data_not_found'.tr();
        break;
      default:
        message = 'error_data_generic'.tr();
    }
    return DataException(message, code: error.code, originalException: error);
  }

  /// Get a user-friendly error message from any error
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return handleException(error).message;
  }
}
