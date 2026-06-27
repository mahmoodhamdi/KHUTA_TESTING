import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class QuestionText extends StatelessWidget {
  final String text;
  final bool isRTL;

  const QuestionText({super.key, required this.text, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Text(
       text.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: HomeScreenTheme.primaryText(isDark),
          height: 1.5,
        ),
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}
