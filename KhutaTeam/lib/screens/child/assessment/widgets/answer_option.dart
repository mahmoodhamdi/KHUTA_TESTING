import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class AnswerOption extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? HomeScreenTheme.accentBlue(isDark).withValues(alpha: 0.1)
                  : HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? HomeScreenTheme.accentBlue(isDark)
                    : (isDark
                          ? Colors.grey.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2)),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? HomeScreenTheme.accentBlue(isDark)
                          : HomeScreenTheme.secondaryText(isDark),
                      width: 2,
                    ),
                    color: isSelected
                        ? HomeScreenTheme.accentBlue(isDark)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? HomeScreenTheme.accentBlue(isDark)
                          : HomeScreenTheme.primaryText(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
