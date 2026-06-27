import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/cubit/auth/auth_cubit.dart';
import 'package:khuta/screens/auth/login_screen.dart';
import 'package:khuta/screens/auth/register_screen.dart';
import 'package:khuta/screens/auth/reset_password_screen.dart';
import 'package:khuta/screens/main_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
import 'auth_flow_test.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await setupLocalizationForTest();

  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
  });

  group('Authentication Flow Integration Tests', () {
    testWidgets('Login screen navigates to register screen', (WidgetTester tester) async {
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

      // Verify login screen is displayed
      expect(find.text('Login'), findsOneWidget);

      // Find and tap the register button
      final registerButton = find.text("Don't have an account? Register");
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Verify navigation to register screen
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('Login screen navigates to forgot password screen', (WidgetTester tester) async {
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

      // Find and tap the forgot password button
      final forgotPasswordButton = find.text('Forgot Password?');
      expect(forgotPasswordButton, findsOneWidget);
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Verify navigation to reset password screen
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });

    testWidgets('Successful login navigates to main screen', (WidgetTester tester) async {
      // Setup mock responses
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUserCredential.user).thenReturn(mockUser);
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

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

      // Enter login credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap the login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start animations
      await tester.pump(const Duration(seconds: 2)); // Wait for animations

      // Verify navigation to main screen
      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets('Failed login shows error message', (WidgetTester tester) async {
      // Setup mock to throw an exception
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

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

      // Enter login credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

      // Tap the login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start animations
      await tester.pump(const Duration(seconds: 2)); // Wait for animations

      // Verify error message is shown
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}