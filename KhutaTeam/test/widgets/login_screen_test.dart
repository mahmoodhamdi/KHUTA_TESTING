import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/cubit/auth/auth_cubit.dart';
import 'package:khuta/screens/auth/login_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/test_helpers.dart';

@GenerateMocks([FirebaseAuth])
import 'login_screen_test.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await setupLocalizationForTest();

  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all UI elements correctly', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        wrapWithLocalization(
          MaterialApp(
            home: BlocProvider(
              create: (context) => AuthCubit(auth: mockFirebaseAuth),
              child: const LoginScreen(),
            ),
          ),
        ),
      );

      // Verify all UI elements are present
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);
      
      // Verify text fields are present
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Verify buttons are present
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('validates email field correctly', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        wrapWithLocalization(
          MaterialApp(
            home: BlocProvider(
              create: (context) => AuthCubit(auth: mockFirebaseAuth),
              child: const LoginScreen(),
            ),
          ),
        ),
      );

      // Find the login button
      final loginButton = find.byType(ElevatedButton);
      
      // Tap the login button without entering any text
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation error for empty email
      expect(find.text('Required'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation error for invalid email
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Enter valid email
      await tester.enterText(find.byType(TextFormField).at(0), 'valid@example.com');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify no email validation error
      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(find.text('Required'), findsNothing);
    });

    testWidgets('validates password field correctly', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        wrapWithLocalization(
          MaterialApp(
            home: BlocProvider(
              create: (context) => AuthCubit(auth: mockFirebaseAuth),
              child: const LoginScreen(),
            ),
          ),
        ),
      );

      // Find the login button
      final loginButton = find.byType(ElevatedButton);
      
      // Enter valid email but no password
      await tester.enterText(find.byType(TextFormField).at(0), 'valid@example.com');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation error for empty password
      expect(find.text('Required'), findsOneWidget);

      // Enter password that's too short
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation error for short password
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);

      // Enter valid password
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify no password validation error
      expect(find.text('Required'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });
  });
}