import 'dart:async';
import 'package:flutter/foundation.dart';

class RetryHelper {
  /// Retries an async operation with exponential backoff
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempt++;
        return await operation();
      } catch (e) {
        if (attempt >= maxAttempts) {
          rethrow;
        }

        if (e is Exception && shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        if (kDebugMode) debugPrint('Retry attempt $attempt failed: $e. Retrying in $delay...');
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffFactor).round(),
        );
      }
    }
  }

  /// Retries an async operation with a fixed delay between attempts
  static Future<T> retryWithFixedDelay<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        attempt++;
        return await operation();
      } catch (e) {
        if (attempt >= maxAttempts) {
          rethrow;
        }

        if (e is Exception && shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        if (kDebugMode) debugPrint('Retry attempt $attempt failed: $e. Retrying in $delay...');
        await Future.delayed(delay);
      }
    }
  }
}
