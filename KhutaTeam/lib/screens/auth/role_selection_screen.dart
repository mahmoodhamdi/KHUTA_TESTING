import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../main_screen.dart';

/// Shown exactly once — after first login — to ask the user whether they
/// are a **Parent** or a **Teacher**.
///
/// The selected role is stored in Firestore via [AuthCubit.saveRole].
/// On subsequent logins [checkLoginStatus] detects the role is already set
/// and skips this screen entirely.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'parent' or 'teacher'

  void _handleConfirm() {
    if (_selectedRole == null) return;
    context.read<AuthCubit>().saveRole(_selectedRole!);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (_) => false,
          );
        } else if (state is AuthFailure) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ── Title ──────────────────────────────────────────────────
                Text(
                  'auth_role_title'.tr(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.15, curve: Curves.easeOut),

                const SizedBox(height: 10),

                Text(
                  'auth_role_subtitle'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 56),

                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        role: 'parent',
                        label: 'auth_role_parent'.tr(),
                        description: 'auth_role_parent_desc'.tr(),
                        icon: Icons.family_restroom_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE3F0FF), Color(0xFFD0E8FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        darkGradient: const LinearGradient(
                          colors: [Color(0xFF1A2940), Color(0xFF0F1E30)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        iconColor: AppColors.softBlue,
                        isSelected: _selectedRole == 'parent',
                        onTap: () => setState(() => _selectedRole = 'parent'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleCard(
                        role: 'teacher',
                        label: 'auth_role_teacher'.tr(),
                        description: 'auth_role_teacher_desc'.tr(),
                        icon: Icons.school_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F5E9), Color(0xFFD4EDDA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        darkGradient: const LinearGradient(
                          colors: [Color(0xFF142A1A), Color(0xFF0B1E10)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        iconColor: AppColors.calmGreen,
                        isSelected: _selectedRole == 'teacher',
                        onTap: () => setState(() => _selectedRole = 'teacher'),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.1),

                const Spacer(),

                // ── Confirm button ──────────────────────────────────────────
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return AnimatedOpacity(
                      opacity: _selectedRole != null ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed:
                            isLoading || _selectedRole == null ? null : _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.softBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'auth_role_confirm'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Role selection card ──────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final String role;
  final String label;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final Gradient darkGradient;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.label,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.darkGradient,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          gradient: isDark ? darkGradient : gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? iconColor : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: iconColor.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected indicator
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),

            const SizedBox(height: 16),

            // Label
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
