import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: HomeScreenTheme.backgroundColor(isDark).withValues(alpha: 0.95),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: HomeScreenTheme.cardBackground(
                  isDark,
                ).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔵 Pulsing Brain Icon
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.95, end: 1.1),
                    duration: const Duration(milliseconds: 1300),
                    curve: Curves.easeInOutCubic,
                    builder: (context, scale, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    HomeScreenTheme.accentBlue(
                                      isDark,
                                    ).withValues(alpha: 0.25),
                                    Colors.transparent,
                                  ],
                                  radius: 0.8,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: HomeScreenTheme.accentBlue(
                                    isDark,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.psychology_alt_rounded,
                              size: 64,
                              color: HomeScreenTheme.accentBlue(isDark),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // 🔠 Main Loading Text
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 500),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: HomeScreenTheme.primaryText(isDark),
                      letterSpacing: 0.4,
                    ),
                    child: Text('analyzing_responses'.tr()),
                  ),

                  const SizedBox(height: 10),

                  // 📖 Subtitle
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: 1.0,
                    child: Text(
                      'generating_recommendations'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: HomeScreenTheme.secondaryText(isDark),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🟦 Stylish Progress Bar
                  SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: null,
                        minHeight: 6,
                        backgroundColor: HomeScreenTheme.accentBlue(
                          isDark,
                        ).withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          HomeScreenTheme.accentBlue(isDark),
                        ),
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
