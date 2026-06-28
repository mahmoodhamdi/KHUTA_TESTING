import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../main_screen.dart';
import 'otp_screen.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  /// Track whether the phone input panel is expanded.
  bool _showPhoneField = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _handleSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      final raw = _phoneController.text.trim();
      // Ensure E.164 format – prepend + if missing.
      final phone = raw.startsWith('+') ? raw : '+$raw';
      context.read<AuthCubit>().sendOtp(phone);
    }
  }

  void _handleGoogleSignIn() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (state is AuthRoleRequired) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          );
        } else if (state is AuthOtpSent) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phoneNumber: state.phoneNumber,
                verificationId: state.verificationId,
              ),
            ),
          );
        } else if (state is AuthFailure) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // ── Logo / Illustration ────────────────────────────────
                  _buildLogo(isDark)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, curve: Curves.easeOut),

                  const SizedBox(height: 36),

                  // ── Headline ──────────────────────────────────────────
                  Text(
                        'auth_welcome_title'.tr(),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.softBlue,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 500.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 8),

                  Text(
                    'auth_welcome_subtitle'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 250.ms, duration: 500.ms),

                  const SizedBox(height: 48),

                  // ── Google button ─────────────────────────────────────
                  _GoogleSignInButton(onPressed: _handleGoogleSignIn)
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 500.ms)
                      .slideX(begin: -0.05),

                  const SizedBox(height: 16),

                  // ── Divider ───────────────────────────────────────────
                  _OrDivider().animate().fadeIn(
                    delay: 450.ms,
                    duration: 400.ms,
                  ),

                  const SizedBox(height: 16),

                  // ── Phone button / field ───────────────────────────────
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 350),
                    crossFadeState: _showPhoneField
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild:
                        _PhoneOptionButton(
                              onPressed: () {
                                setState(() => _showPhoneField = true);
                                Future.delayed(
                                  const Duration(milliseconds: 400),
                                  () => _phoneFocusNode.requestFocus(),
                                );
                              },
                            )
                            .animate()
                            .fadeIn(delay: 550.ms, duration: 500.ms)
                            .slideX(begin: 0.05),
                    secondChild: _PhoneInputPanel(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      onSend: _handleSendOtp,
                      onCancel: () {
                        setState(() {
                          _showPhoneField = false;
                          _phoneController.clear();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Loading overlay ───────────────────────────────────
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is! AuthLoading) return const SizedBox.shrink();
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Privacy note ───────────────────────────────────────
                  Text(
                    'auth_privacy_note'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Logo widget ──────────────────────────────────────────────────────────

  Widget _buildLogo(bool isDark) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.softBlue.withValues(alpha: 0.15),
              AppColors.calmGreen.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.softBlue.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.psychology_outlined,
              size: 56,
              color: AppColors.softBlue,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Google Sign-In Button ────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google 'G' logo drawn with coloured circles.
              _GoogleLogo(),
              const SizedBox(width: 12),
              Text(
                'auth_continue_with_google'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Simple G logo via a custom paint approach using text.
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the 4 quadrant colours of the Google G logo.
    final colors = [
      const Color(0xFF4285F4), // Blue (top-right)
      const Color(0xFF34A853), // Green (bottom-right)
      const Color(0xFFFBBC05), // Yellow (bottom-left)
      const Color(0xFFEA4335), // Red (top-left)
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i];
      final startAngle = (i * 90 - 45) * (3.14159265 / 180);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        90 * (3.14159265 / 180),
        true,
        paint,
      );
    }

    // White inner circle to create the ring effect.
    canvas.drawCircle(center, radius * 0.6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Phone option button (unexpanded state) ───────────────────────────────────

class _PhoneOptionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PhoneOptionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state is AuthLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.softBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_outlined, size: 20),
              const SizedBox(width: 12),
              Text(
                'auth_continue_with_phone'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Phone input panel (expanded state) ──────────────────────────────────────

class _PhoneInputPanel extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _PhoneInputPanel({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.softBlue.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'auth_enter_phone_number'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
            ],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'auth_phone_hint'.tr(),
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppColors.softBlue,
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF5F9FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.softBlue,
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'auth_phone_required'.tr();
              }
              final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (digits.length < 7 || digits.length > 15) {
                return 'auth_invalid_phone_number'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('cancel'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send OTP button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onSend,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: AppColors.softBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('auth_send_otp'.tr()),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── "or" divider ─────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black12;

    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'auth_or'.tr(),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white38
                  : Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}
