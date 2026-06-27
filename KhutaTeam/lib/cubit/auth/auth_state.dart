import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Emitted when authentication succeeds (Google or Phone OTP verified).
class AuthSuccess extends AuthState {
  final String email;

  const AuthSuccess({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Emitted after OTP is successfully sent to the phone number.
class AuthOtpSent extends AuthState {
  final String phoneNumber;
  final String verificationId;

  const AuthOtpSent({required this.phoneNumber, required this.verificationId});

  @override
  List<Object?> get props => [phoneNumber, verificationId];
}

/// Emitted when OTP is verified but the user has no role yet (first time).
class AuthRoleRequired extends AuthState {
  const AuthRoleRequired();
}

// ─── Legacy states kept for compatibility with any remaining references ───────

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthEmailVerificationRequired extends AuthState {
  final String email;

  const AuthEmailVerificationRequired({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthEmailVerificationSent extends AuthState {
  final String email;

  const AuthEmailVerificationSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthEmailVerified extends AuthState {
  final String email;

  const AuthEmailVerified({required this.email});

  @override
  List<Object?> get props => [email];
}
