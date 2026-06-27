import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class QuestionImage extends StatelessWidget {
  final String imageUrl;

  const QuestionImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: HomeScreenTheme.accentBlue(isDark).withValues(alpha: 0.1),
              child: Icon(
                Icons.image,
                size: 50,
                color: HomeScreenTheme.accentBlue(isDark),
              ),
            );
          },
        ),
      ),
    );
  }
}
