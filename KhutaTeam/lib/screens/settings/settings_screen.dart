import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/core/utils/haptic_utils.dart';
import 'package:khuta/cubit/auth/auth_cubit.dart';
import 'package:khuta/cubit/theme/theme_cubit.dart';
import 'package:khuta/screens/admin/admin_dashboard_screen.dart';
import 'package:khuta/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _changeLanguage(BuildContext context, String code) async {
    HapticUtils.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    if (code == 'ar') {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('logout_confirmation_title'.tr()),
        content: Text('logout_confirmation_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('settings'.tr()),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: HomeScreenTheme.cardBackground(isDark),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [HomeScreenTheme.cardShadow(isDark)],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: HomeScreenTheme.accentBlue(
                          isDark,
                        ).withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: HomeScreenTheme.accentBlue(isDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: HomeScreenTheme.accentGreen(isDark),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: HomeScreenTheme.cardBackground(isDark),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.email ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HomeScreenTheme.primaryText(isDark),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Theme Settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HomeScreenTheme.accentBlue(
                          isDark,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        size: 20,
                        color: HomeScreenTheme.accentBlue(isDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'appearance'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return SwitchListTile(
                      title: Text(
                        'dark_mode'.tr(),
                        style: TextStyle(
                          color: HomeScreenTheme.primaryText(isDark),
                        ),
                      ),
                      subtitle: Text(
                        'dark_mode_description'.tr(),
                        style: TextStyle(
                          color: HomeScreenTheme.secondaryText(isDark),
                        ),
                      ),
                      value: state is ThemeDark,
                      onChanged: (_) {
                        HapticUtils.selectionClick();
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      activeTrackColor: HomeScreenTheme.accentBlue(isDark).withValues(alpha: 0.5),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return HomeScreenTheme.accentBlue(isDark);
                        }
                        return null;
                      }),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Language Settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HomeScreenTheme.accentPink(
                          isDark,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.translate_outlined,
                        size: 20,
                        color: HomeScreenTheme.accentPink(isDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'language'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  context: context,
                  code: 'en',
                  name: 'English',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  context: context,
                  code: 'ar',
                  name: 'العربية',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Admin Panel Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            child: ListTile(
              onTap: () {
                HapticUtils.buttonPress();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 20,
                  color: Color(0xFF1A56DB),
                ),
              ),
              title: Text(
                'admin_dashboard'.tr(),
                style: const TextStyle(
                  color: Color(0xFF1A56DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF1A56DB),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            child: ListTile(
              onTap: () {
                HapticUtils.buttonPress();
                _handleLogout(context);
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Colors.red,
                ),
              ),
              title: Text(
                'logout'.tr(),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String code,
    required String name,
    required bool isDark,
  }) {
    final isSelected = context.locale.languageCode == code;
    return InkWell(
      onTap: () => _changeLanguage(context, code),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? HomeScreenTheme.accentPink(isDark).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? HomeScreenTheme.accentPink(isDark)
                : HomeScreenTheme.secondaryText(isDark).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: isSelected
                  ? HomeScreenTheme.accentPink(isDark)
                  : Colors.transparent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? HomeScreenTheme.accentPink(isDark)
                    : HomeScreenTheme.primaryText(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
