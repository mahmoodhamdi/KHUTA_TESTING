# Testing Guide for Khuta

## Overview

This directory contains tests for the Khuta application. The tests are organized by type and feature, following a consistent pattern to ensure comprehensive test coverage.

## Test Structure

Tests are organized in the following structure:

```
test/
├── cubit/                  # Unit tests for BLoC/Cubit state management
│   ├── auth/               # Authentication-related tests
│   │   └── auth_cubit_test.dart
│   └── connectivity/       # Connectivity-related tests
│       └── connectivity_cubit_test.dart
├── widgets/                # Widget tests for UI components
│   ├── animated_bottom_bar_test.dart
│   └── login_screen_test.dart
├── integration/            # Integration tests for feature flows
│   ├── auth_flow_test.dart
│   └── navigation_flow_test.dart
├── helpers/                # Test helpers and utilities
│   ├── mock_translations/  # Mock translation files for testing
│   │   └── en.json
│   └── test_helpers.dart   # Helper functions for testing
└── README.md               # This file
```

## Test Types

### Unit Tests

Unit tests focus on testing individual components in isolation, such as Cubits and utility functions. These tests verify that each component behaves as expected without dependencies on other parts of the system.

### Widget Tests

Widget tests focus on testing individual UI components to ensure they render correctly and respond to user interactions as expected. These tests verify that widgets display the correct information and handle user input properly.

### Integration Tests

Integration tests focus on testing how different components work together to implement a feature or user flow. These tests verify that the application behaves correctly when multiple components interact.

## Running Tests

To run all tests, use the following command from the project root:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/cubit/auth/auth_cubit_test.dart
```

To run all tests of a specific type:

```bash
flutter test test/widgets/
```

## Test Approach

### Mocking Dependencies

We use the `mockito` package to mock dependencies like Firebase services and platform channels. This allows us to test our code in isolation without relying on external services.

Example of mocking Firebase Auth:

```dart
@GenerateMocks([FirebaseAuth, UserCredential, User])
import 'auth_cubit_test.mocks.dart';

// In the test setup
MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
AuthCubit authCubit = AuthCubit(auth: mockFirebaseAuth);
```

### Generating Mock Classes

After adding the `@GenerateMocks` annotation, you need to generate the mock classes by running:

```bash
flutter pub run build_runner build
```

Or to continuously generate mocks during development:

```bash
flutter pub run build_runner watch
```

### Testing Widgets

For widget testing, we use the `testWidgets` function provided by the Flutter test framework. This allows us to build widgets, interact with them, and verify their behavior.

Example of a widget test:

```dart
testWidgets('renders all UI elements correctly', (WidgetTester tester) async {
  // Build the widget
  await tester.pumpWidget(MaterialApp(home: MyWidget()));
  
  // Verify UI elements
  expect(find.text('Title'), findsOneWidget);
  expect(find.byType(Button), findsOneWidget);
  
  // Interact with the widget
  await tester.tap(find.byType(Button));
  await tester.pump();
  
  // Verify the result
  expect(find.text('Button Pressed'), findsOneWidget);
});
```

### Testing Integration Flows

For integration testing, we test how different components work together to implement a feature or user flow. This involves building multiple widgets, navigating between screens, and verifying that the application behaves correctly.

Example of an integration test:

```dart
testWidgets('login flow works correctly', (WidgetTester tester) async {
  // Build the login screen
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));
  
  // Enter credentials
  await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'password');
  
  // Tap login button
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  // Verify navigation to home screen
  expect(find.byType(HomeScreen), findsOneWidget);
});
```

## Best Practices

1. **Test One Thing at a Time**: Each test should focus on testing a single behavior or outcome.

2. **Arrange-Act-Assert**: Follow the AAA pattern in your tests:
   - **Arrange**: Set up the test environment and inputs
   - **Act**: Execute the code being tested
   - **Assert**: Verify the expected outcomes

3. **Descriptive Test Names**: Use descriptive names that explain what the test is checking.

4. **Clean Setup and Teardown**: Use `setUp` and `tearDown` to ensure each test starts with a clean state.

5. **Group Related Tests**: Use `group` to organize related tests together.

6. **Mock External Dependencies**: Always mock external dependencies like Firebase services, network requests, and platform channels.

7. **Test Edge Cases**: Include tests for edge cases and error conditions, not just the happy path.

## Adding New Tests

When adding new tests:

1. Create a new test file in the appropriate directory based on the test type (unit, widget, or integration)
2. Import the necessary dependencies
3. Set up mocks for external dependencies
4. Write tests following the AAA pattern
5. Run the tests to ensure they pass

## Coverage

To generate a coverage report:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Then open `coverage/html/index.html` in a browser to view the coverage report.