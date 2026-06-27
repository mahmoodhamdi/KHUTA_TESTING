import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class AssessmentProgressBar extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;

  const AssessmentProgressBar({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentQuestionIndex + 1) / totalQuestions;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: HomeScreenTheme.cardBackground(isDark),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'question'.tr()} ${currentQuestionIndex + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
              ),
              Text(
                '${currentQuestionIndex + 1} / $totalQuestions',
                style: TextStyle(
                  fontSize: 14,
                  color: HomeScreenTheme.secondaryText(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              HomeScreenTheme.accentBlue(isDark),
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
