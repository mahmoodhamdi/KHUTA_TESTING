import 'package:flutter/services.dart';

/// Utility class for haptic feedback throughout the app.
///
/// Provides consistent haptic feedback for different interactions:
/// - Light: Button taps, selections
/// - Medium: Confirmations, successful actions
/// - Heavy: Errors, important alerts
/// - Selection: Toggle switches, option selections
class HapticUtils {
  /// Light impact for button taps and minor interactions.
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for confirmations and successful actions.
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for errors and important alerts.
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for toggles and option selections.
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate for important notifications (use sparingly).
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  /// Feedback for successful form submission.
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Feedback for error or validation failure.
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Feedback for button press.
  static void buttonPress() {
    HapticFeedback.lightImpact();
  }

  /// Feedback for card tap.
  static void cardTap() {
    HapticFeedback.lightImpact();
  }

  /// Feedback for answer selection in assessment.
  static void answerSelected() {
    HapticFeedback.selectionClick();
  }

  /// Feedback for navigation (next/previous question).
  static void navigation() {
    HapticFeedback.lightImpact();
  }

  /// Feedback for delete action.
  static void delete() {
    HapticFeedback.mediumImpact();
  }

  /// Feedback for completing an assessment.
  static void assessmentComplete() {
    HapticFeedback.mediumImpact();
  }
}
