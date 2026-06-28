import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/utils/auth_exception_handler.dart';
import 'auth_state.dart';

/// Cubit for managing Firebase authentication state.
///
/// Supports two sign-in methods:
/// 1. **Google Sign-In** – one-tap OAuth flow.
/// 2. **Phone + OTP** – Firebase SMS verification flow.
///
/// ## State Flow
///
/// ```
/// AuthInitial → AuthLoading → AuthOtpSent (phone path)
///                           → AuthSuccess  (Google existing user with role)
///                           → AuthRoleRequired (first-time user, no role set)
///                           → AuthFailure
/// ```
///
/// ## Role logic
///
/// On first login a user has no role in Firestore.
/// `checkLoginStatus()` detects this and emits [AuthRoleRequired].
/// After the user picks a role via [saveRole()], it is written to Firestore
/// and [AuthSuccess] is emitted.
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       super(AuthInitial());

  // ─────────────────────────────────────────────────────────────────────────
  // Session check
  // ─────────────────────────────────────────────────────────────────────────

  /// Checks if the user is currently logged in and has a role set.
  ///
  /// Emits:
  /// - [AuthSuccess] if user is logged in and has a role
  /// - [AuthRoleRequired] if user is logged in but has no role yet
  /// - [AuthInitial] if no user is logged in
  /// - [AuthFailure] if an error occurs
  Future<void> checkLoginStatus() async {
    emit(AuthLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(AuthInitial());
        return;
      }

      await user.reload();
      final refreshed = _auth.currentUser;
      if (refreshed == null) {
        emit(AuthInitial());
        return;
      }

      final hasRole = await _userHasRole(refreshed.uid);
      if (hasRole) {
        emit(AuthSuccess(email: refreshed.email ?? refreshed.phoneNumber ?? ''));
      } else {
        emit(const AuthRoleRequired());
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Google Sign-In
  // ─────────────────────────────────────────────────────────────────────────

  /// Signs in the user with their Google account.
  ///
  /// - New user → account created automatically → [AuthRoleRequired]
  /// - Existing user with role → [AuthSuccess]
  /// - Existing user without role → [AuthRoleRequired]
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      // On web, use signInWithPopup flow; on mobile use native flow.
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Web: trigger redirect/popup
        googleUser = await _googleSignIn.signIn();
      } else {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        // User cancelled the Google sign-in sheet.
        emit(AuthInitial());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        emit(const AuthFailure(message: 'Google sign-in failed'));
        return;
      }

      // Persist metadata to Firestore (upsert).
      await _upsertUserDocument(
        uid: user.uid,
        email: user.email,
        authProvider: 'google',
      );

      final hasRole = await _userHasRole(user.uid);
      if (hasRole) {
        emit(AuthSuccess(email: user.email ?? ''));
      } else {
        emit(const AuthRoleRequired());
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Phone OTP – Step 1: Send OTP
  // ─────────────────────────────────────────────────────────────────────────

  /// Sends an OTP to [phoneNumber] (E.164 format, e.g. `+966501234567`).
  ///
  /// On success emits [AuthOtpSent].
  /// On failure emits [AuthFailure].
  Future<void> sendOtp(String phoneNumber) async {
    emit(AuthLoading());
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval on Android – sign in immediately.
          if (isClosed) return;
          await _signInWithPhoneCredential(credential, phoneNumber);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (isClosed) return;
          emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (isClosed) return;
          emit(AuthOtpSent(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Phone OTP – Step 2: Verify OTP
  // ─────────────────────────────────────────────────────────────────────────

  /// Verifies the [otpCode] entered by the user.
  ///
  /// Uses the [verificationId] from the previous [AuthOtpSent] state,
  /// or falls back to the internally stored [_verificationId].
  ///
  /// On success: [AuthRoleRequired] (new user) or [AuthSuccess] (returning user).
  Future<void> verifyOtp({
    required String otpCode,
    required String verificationId,
    required String phoneNumber,
  }) async {
    emit(AuthLoading());
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      await _signInWithPhoneCredential(credential, phoneNumber);
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Role selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Persists the selected [role] (`'parent'` or `'teacher'`) in Firestore
  /// and emits [AuthSuccess].
  Future<void> saveRole(String role) async {
    emit(AuthLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const AuthFailure(message: 'No user session found'));
        return;
      }

      await _firestore.collection('users').doc(user.uid).set(
        {'role': role, 'last_login': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      emit(AuthSuccess(email: user.email ?? user.phoneNumber ?? ''));
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────────────────────────────────────

  /// Signs out the current user (works for both Google and Phone sessions).
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _googleSignIn.signOut().catchError((_) => null);
      await _auth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _signInWithPhoneCredential(
    PhoneAuthCredential credential,
    String phoneNumber,
  ) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      emit(const AuthFailure(message: 'Phone sign-in failed'));
      return;
    }

    await _upsertUserDocument(
      uid: user.uid,
      phoneNumber: phoneNumber,
      authProvider: 'phone',
    );

    final hasRole = await _userHasRole(user.uid);
    if (hasRole) {
      emit(AuthSuccess(email: user.email ?? user.phoneNumber ?? ''));
    } else {
      emit(const AuthRoleRequired());
    }
  }

  /// Returns true only if the user doc exists AND has a non-empty role.
  ///
  /// A genuinely missing document returns false (first-time user), but any
  /// real failure (permission/network) is rethrown so callers surface it as
  /// [AuthFailure] instead of silently downgrading the user to role-required.
  Future<bool> _userHasRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    final role = data?['role'];
    return role is String && role.isNotEmpty;
  }

  Future<void> _upsertUserDocument({
    required String uid,
    String? email,
    String? phoneNumber,
    required String authProvider,
  }) async {
    final data = <String, dynamic>{
      'auth_provider': authProvider,
      'last_login': FieldValue.serverTimestamp(),
    };
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy stubs – kept so existing screens that reference these don't break
  // ─────────────────────────────────────────────────────────────────────────

  @Deprecated('Password auth removed. Use signInWithGoogle() or sendOtp().')
  Future<void> login(String email, String password) async {
    emit(const AuthFailure(
      message: 'Password login is no longer supported. Use Google or Phone.',
    ));
  }

  @Deprecated('Password auth removed. Use signInWithGoogle() or sendOtp().')
  Future<void> register(String email, String password) async {
    emit(const AuthFailure(
      message: 'Password registration is no longer supported.',
    ));
  }

  @Deprecated('Password auth removed. Password reset is no longer supported.')
  Future<void> resetPassword(String email) async {
    emit(const AuthFailure(
      message: 'Password reset is no longer supported.',
    ));
  }

  /// Legacy stub – email verification no longer used.
  @Deprecated('Email auth removed. Phone/Google auth does not require email verification.')
  Future<void> sendEmailVerification() async {}

  /// Legacy stub – email verification no longer used.
  @Deprecated('Email auth removed. Phone/Google auth does not require email verification.')
  Future<void> checkEmailVerification() async {}
}
