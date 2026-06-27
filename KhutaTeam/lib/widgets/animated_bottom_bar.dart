import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class AnimatedBottomBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const AnimatedBottomBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AnimatedBottomNavigationBar.builder(
        itemCount: 3,
        tabBuilder: (int index, bool isActive) {
          final icons = [
            Icons.home_rounded,

            Icons.settings_rounded,
            Icons.info_rounded,
          ];
          final labels = [
            'nav_home'.tr(),

            'nav_settings'.tr(),

            'nav_about'.tr(),
          ];
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icons[index],
                size: 24,
                color: isActive
                    ? HomeScreenTheme.accentBlue(isDark)
                    : HomeScreenTheme.secondaryText(isDark),
              ),
              const SizedBox(height: 4),
              Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? HomeScreenTheme.accentBlue(isDark)
                      : HomeScreenTheme.secondaryText(isDark),
                ),
              ),
            ],
          );
        },
        activeIndex: activeIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,

        onTap: onTap,
        backgroundColor: HomeScreenTheme.cardBackground(isDark),

        splashSpeedInMilliseconds: 300,
        splashColor: HomeScreenTheme.accentBlue(isDark).withValues(alpha: 0.1),
      ),
    );
  }
}
