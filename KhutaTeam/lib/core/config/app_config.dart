import 'package:flutter/foundation.dart';

/// Application configuration for environment-specific settings.
///
/// Provides compile-time constants for determining the current build mode.
/// Uses Flutter's foundation library constants which are tree-shaken in release builds.
///
/// Usage:
/// ```dart
/// if (AppConfig.isDebug) {
///   // Debug-only code
/// }
///
/// final provider = AppConfig.isDebug
///     ? const AndroidDebugProvider()
///     : const AndroidPlayIntegrityProvider();
/// ```
class AppConfig {
  AppConfig._();

  /// Returns true if running in debug/development mode.
  ///
  /// Debug mode is enabled when running with `flutter run` or `flutter run --debug`.
  /// In this mode, assertions are enabled and debug providers can be used.
  static bool get isDebug => kDebugMode;

  /// Returns true if running in release/production mode.
  ///
  /// Release mode is enabled when running with `flutter run --release` or
  /// when building with `flutter build apk --release`.
  /// In this mode, all debug code is stripped and production providers must be used.
  static bool get isProduction => kReleaseMode;

  /// Returns true if running in profile mode.
  ///
  /// Profile mode is enabled when running with `flutter run --profile`.
  /// Used for performance profiling with some debug features disabled.
  static bool get isProfile => kProfileMode;
}
