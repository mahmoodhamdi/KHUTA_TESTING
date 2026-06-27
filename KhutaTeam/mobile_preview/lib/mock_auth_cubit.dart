import 'dart:async';

import 'package:khuta/cubit/auth/auth_cubit.dart';
import 'package:khuta/cubit/auth/auth_state.dart';

/// Demo-only [AuthCubit] used exclusively by the mobile_preview package.
///
/// Simulates the complete authentication flow locally without any real
/// Firebase calls, so every screen (Login → OTP → RoleSelection → Main)
/// can be previewed in the browser without needing Firebase providers
/// to be enabled or SHA fingerprints configured.
class MockAuthCubit extends AuthCubit {
  // ─── App launch ─────────────────────────────────────────────────────────────

  /// Always starts as logged-out so the login screen is shown.
  @override
  Future<void> checkLoginStatus() async {
    emit(AuthLoading()); // ← transition away from AuthInitial so the stream fires
    await Future.delayed(const Duration(milliseconds: 1800));
    emit(AuthInitial()); // ← now a real state change; BlocListener navigates to LoginScreen
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────────

  /// Simulates a successful Google sign-in that lands on role-selection
  /// (first-time user path).
  @override
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    // Treat as new user → show role selection
    emit(const AuthRoleRequired());
  }

  // ─── Phone OTP ───────────────────────────────────────────────────────────────

  /// Simulates SMS OTP dispatch.
  @override
  Future<void> sendOtp(String phoneNumber) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(AuthOtpSent(
      verificationId: 'mock-verification-id-000000',
      phoneNumber: phoneNumber,
    ));
  }

  /// Accepts any 6-digit code in demo mode.
  @override
  Future<void> verifyOtp({
    required String otpCode,
    required String verificationId,
    required String phoneNumber,
  }) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 900));
    // Accept any code in demo mode; real validation happens on device.
    emit(const AuthRoleRequired());
  }

  // ─── Role selection ──────────────────────────────────────────────────────────

  /// Simulates Firestore role write and completes login.
  @override
  Future<void> saveRole(String role) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(const AuthSuccess(email: 'demo@khuta.app'));
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    emit(AuthInitial());
  }
}
