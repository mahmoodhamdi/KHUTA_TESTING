import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/home_screen_theme.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../widgets/auth_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().resetPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          setState(() {
            _isEmailSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('password_reset_email_sent'.tr()),
              backgroundColor: HomeScreenTheme.accentGreen(isDark),
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: HomeScreenTheme.accentRed(isDark),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: HomeScreenTheme.backgroundColor(isDark),
        appBar: AppBar(
          title: Text(
            'reset_password'.tr(),
            style: TextStyle(color: HomeScreenTheme.primaryText(isDark)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: HomeScreenTheme.primaryText(isDark)),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _isEmailSent
                  ? _buildSuccessView(isDark)
                  : _buildResetForm(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: HomeScreenTheme.accentBlue(isDark),
                ),
                const SizedBox(height: 24),
                Text(
                  'reset_password'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: HomeScreenTheme.primaryText(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'reset_password_description'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HomeScreenTheme.secondaryText(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AuthTextField(
                  controller: _emailController,
                  labelKey: AppStrings.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleResetPassword(),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'email_required'.tr();
                    }
                    if (!value!.contains('@')) {
                      return 'email_invalid'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return AuthButton(
                      labelKey: 'send_reset_email',
                      onPressed: _handleResetPassword,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'back_to_login'.tr(),
                    style: TextStyle(color: HomeScreenTheme.accentBlue(isDark)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HomeScreenTheme.accentGreen(isDark).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.mark_email_read,
              size: 64,
              color: HomeScreenTheme.accentGreen(isDark),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'email_sent'.tr(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: HomeScreenTheme.primaryText(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'check_email_for_reset_link'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HomeScreenTheme.secondaryText(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _isEmailSent = false;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: HomeScreenTheme.accentBlue(isDark),
              side: BorderSide(color: HomeScreenTheme.accentBlue(isDark)),
            ),
            child: Text('resend_email'.tr()),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'back_to_login'.tr(),
              style: TextStyle(color: HomeScreenTheme.accentBlue(isDark)),
            ),
          ),
        ],
      ),
    );
  }
}
