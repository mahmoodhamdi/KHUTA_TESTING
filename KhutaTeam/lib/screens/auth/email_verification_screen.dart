import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/home_screen_theme.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../widgets/auth_widgets.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isResendEnabled = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read<AuthCubit>().checkEmailVerification();
    });
  }

  void _handleResendEmail() {
    if (_isResendEnabled) {
      context.read<AuthCubit>().sendEmailVerification();
      _startResendCountdown();
    }
  }

  void _startResendCountdown() {
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
      }

      if (_resendCountdown <= 0) {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  void _handleLogout() {
    _timer?.cancel();
    context.read<AuthCubit>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailVerified) {
          _timer?.cancel();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        } else if (state is AuthEmailVerificationSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('verification_email_sent'.tr()),
              backgroundColor: HomeScreenTheme.accentGreen(isDark),
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: HomeScreenTheme.accentRed(isDark),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: HomeScreenTheme.backgroundColor(isDark),
        appBar: AppBar(
          title: Text(
            'verify_email'.tr(),
            style: TextStyle(color: HomeScreenTheme.primaryText(isDark)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: _handleLogout,
              child: Text(
                'logout'.tr(),
                style: TextStyle(color: HomeScreenTheme.accentBlue(isDark)),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_unread,
                    size: 80,
                    color: HomeScreenTheme.accentBlue(isDark),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'verify_your_email'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: HomeScreenTheme.primaryText(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'verification_email_description'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HomeScreenTheme.secondaryText(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HomeScreenTheme.cardBackground(isDark),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                    ),
                    child: Text(
                      widget.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return AuthButton(
                        labelKey: 'check_verification_status',
                        onPressed: () =>
                            context.read<AuthCubit>().checkEmailVerification(),
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _isResendEnabled ? _handleResendEmail : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isResendEnabled
                          ? HomeScreenTheme.accentBlue(isDark)
                          : HomeScreenTheme.secondaryText(isDark),
                      side: BorderSide(
                        color: _isResendEnabled
                            ? HomeScreenTheme.accentBlue(isDark)
                            : HomeScreenTheme.secondaryText(isDark),
                      ),
                    ),
                    child: Text(
                      _isResendEnabled
                          ? 'resend_verification_email'.tr()
                          : 'resend_in_seconds'.tr(
                              args: [_resendCountdown.toString()],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HomeScreenTheme.accentBlue(
                        isDark,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: HomeScreenTheme.accentBlue(
                          isDark,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: HomeScreenTheme.accentBlue(isDark),
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'verification_tips'.tr(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: HomeScreenTheme.secondaryText(isDark),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _handleLogout,
                    child: Text(
                      'use_different_email'.tr(),
                      style: TextStyle(
                        color: HomeScreenTheme.accentBlue(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
