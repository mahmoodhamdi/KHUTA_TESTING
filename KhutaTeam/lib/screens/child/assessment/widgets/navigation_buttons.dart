import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isFirstQuestion;
  final bool isLastQuestion;
  final bool canProceed;
  final bool isRTL;

  const NavigationButtons({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.isFirstQuestion,
    required this.isLastQuestion,
    required this.canProceed,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: HomeScreenTheme.cardBackground(isDark),
      child: Row(
        spacing: 16,
        children: [
          if (!isFirstQuestion) const SizedBox(width: 0),

          Expanded(
            child: ElevatedButton(
              onPressed: canProceed ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreenTheme.accentBlue(isDark),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: isDark
                    ? Colors.grey[700]
                    : Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isLastQuestion ? 'show_results'.tr() : 'next'.tr()),

                  Icon(isLastQuestion ? Icons.check : null, size: 20),
                ],
              ),
            ),
          ),

          if (!isFirstQuestion)
            Expanded(
              child: ElevatedButton(
                onPressed: onPrevious,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  foregroundColor: HomeScreenTheme.primaryText(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('previous'.tr())],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
