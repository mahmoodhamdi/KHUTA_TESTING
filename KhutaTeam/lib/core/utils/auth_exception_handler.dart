import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthExceptionHandler {
  static String handleException(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        // ── Email / password (legacy, kept for safety) ──────────────────────
        case 'user-not-found':
          return 'auth_user_not_found'.tr();
        case 'wrong-password':
          return 'auth_wrong_password'.tr();
        case 'email-already-in-use':
          return 'auth_email_already_in_use'.tr();
        case 'weak-password':
          return 'auth_weak_password'.tr();
        case 'invalid-email':
          return 'auth_invalid_email'.tr();
        case 'operation-not-allowed':
          return 'auth_operation_not_allowed'.tr();

        // ── Phone / OTP ───────────────────────────────────────────────────
        case 'invalid-phone-number':
          return 'auth_invalid_phone_number'.tr();
        case 'invalid-verification-code':
          return 'auth_invalid_otp'.tr();
        case 'session-expired':
          return 'auth_otp_expired'.tr();
        case 'quota-exceeded':
          return 'auth_quota_exceeded'.tr();
        case 'missing-phone-number':
          return 'auth_missing_phone_number'.tr();
        case 'too-many-requests':
          return 'auth_too_many_requests'.tr();

        // ── Google ────────────────────────────────────────────────────────
        case 'account-exists-with-different-credential':
          return 'auth_account_exists_different_credential'.tr();
        case 'popup-closed-by-user':
        case 'canceled-by-user':
          return 'auth_sign_in_cancelled'.tr();

        // ── Network ───────────────────────────────────────────────────────
        case 'network-request-failed':
          return 'auth_network_error'.tr();

        default:
          if (kDebugMode) {
            debugPrint(
                'Unhandled FirebaseAuthException: ${error.code} — ${error.message}');
          }
          return 'auth_unknown_error'.tr();
      }
    }

    if (kDebugMode) debugPrint('Unhandled auth error: $error');
    return 'auth_unknown_error'.tr();
  }
}

