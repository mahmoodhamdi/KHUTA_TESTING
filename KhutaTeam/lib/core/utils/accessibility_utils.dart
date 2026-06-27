import 'package:easy_localization/easy_localization.dart';

/// Utility class for accessibility features
class AccessibilityUtils {

  /// Get severity text for a score (for screen readers)
  static String getScoreSeverityText(double score) {
    if (score < 40) {
      return 'score_severity_very_low'.tr();
    } else if (score < 45) {
      return 'score_severity_low'.tr();
    } else if (score <= 55) {
      return 'score_severity_average'.tr();
    } else if (score <= 65) {
      return 'score_severity_elevated'.tr();
    } else {
      return 'score_severity_high'.tr();
    }
  }

  /// Get accessibility label for score with full context
  static String getScoreAccessibilityLabel(double score) {
    final severityText = getScoreSeverityText(score);
    return '${'score'.tr()}: ${score.toStringAsFixed(1)} - $severityText';
  }
}
