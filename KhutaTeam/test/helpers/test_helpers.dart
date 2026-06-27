import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This function sets up the necessary mocks for testing
/// including EasyLocalization and SharedPreferences
Future<void> setupLocalizationForTest() async {
  // Setup SharedPreferences mock
  SharedPreferences.setMockInitialValues({});
  
  // Register the EasyLocalization.of method for the test environment
  EasyLocalization.logger.enableBuildModes = [];
  
  // Create a mock implementation of the tr() extension method
  await EasyLocalization.ensureInitialized();
}

/// Wraps a widget with the necessary providers for testing
/// including EasyLocalization
Widget wrapWithLocalization(Widget widget) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'test/helpers/mock_translations',
    fallbackLocale: const Locale('en'),
    child: MaterialApp(
      home: widget,
    ),
  );
}
