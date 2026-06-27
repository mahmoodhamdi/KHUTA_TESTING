import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/cubit/auth/auth_cubit.dart';
import 'package:khuta/cubit/auth/auth_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helpers.dart';
@GenerateMocks([FirebaseAuth, UserCredential, User])
import 'auth_cubit_test.mocks.dart';

void main() async {
  // Setup localization
  TestWidgetsFlutterBinding.ensureInitialized();
  await setupLocalizationForTest();

  late MockFirebaseAuth mockFirebaseAuth;
  late AuthCubit authCubit;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    // Setup the auth cubit with mocked dependencies
    authCubit = AuthCubit(auth: mockFirebaseAuth);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    group('login', () {
      test(
        'emits [AuthLoading, AuthSuccess] when login is successful and email is verified',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          when(mockUser.emailVerified).thenReturn(true);
          when(mockUser.email).thenReturn(email);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

          // Act
          await authCubit.login(email, password);

          // Assert
          expect(authCubit.state, isA<AuthSuccess>());
          expect((authCubit.state as AuthSuccess).email, equals(email));
        },
      );

      test(
        'emits [AuthLoading, AuthEmailVerificationRequired] when login is successful but email is not verified',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          when(mockUser.emailVerified).thenReturn(false);
          when(mockUser.email).thenReturn(email);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

          // Act
          await authCubit.login(email, password);

          // Assert
          expect(authCubit.state, isA<AuthEmailVerificationRequired>());
          expect(
            (authCubit.state as AuthEmailVerificationRequired).email,
            equals(email),
          );
        },
      );

      test('emits [AuthLoading, AuthFailure] when login fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final exception = FirebaseAuthException(code: 'user-not-found');

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(exception);

        // Act
        await authCubit.login(email, password);

        // Assert
        expect(authCubit.state, isA<AuthFailure>());
      });
    });

    group('register', () {
      test(
        'emits [AuthLoading, AuthEmailVerificationRequired] when registration is successful',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';

          when(mockUser.email).thenReturn(email);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => mockUserCredential);

          // Act
          await authCubit.register(email, password);

          // Assert
          verify(mockUser.sendEmailVerification()).called(1);
          expect(authCubit.state, isA<AuthEmailVerificationRequired>());
          expect(
            (authCubit.state as AuthEmailVerificationRequired).email,
            equals(email),
          );
        },
      );

      test(
        'emits [AuthLoading, AuthFailure] when registration fails',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';
          final exception = FirebaseAuthException(code: 'email-already-in-use');

          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenThrow(exception);

          // Act
          await authCubit.register(email, password);

          // Assert
          expect(authCubit.state, isA<AuthFailure>());
        },
      );
    });

    group('resetPassword', () {
      test(
        'emits [AuthLoading, AuthPasswordResetSent] when password reset email is sent successfully',
        () async {
          // Arrange
          const email = 'test@example.com';

          when(
            mockFirebaseAuth.sendPasswordResetEmail(email: email),
          ).thenAnswer((_) async => {});

          // Act
          await authCubit.resetPassword(email);

          // Assert
          expect(authCubit.state, isA<AuthPasswordResetSent>());
          expect(
            (authCubit.state as AuthPasswordResetSent).email,
            equals(email),
          );
        },
      );

      test(
        'emits [AuthLoading, AuthFailure] when password reset fails',
        () async {
          // Arrange
          const email = 'test@example.com';
          final exception = FirebaseAuthException(code: 'user-not-found');

          when(
            mockFirebaseAuth.sendPasswordResetEmail(email: email),
          ).thenThrow(exception);

          // Act
          await authCubit.resetPassword(email);

          // Assert
          expect(authCubit.state, isA<AuthFailure>());
        },
      );
    });

    // Add more test groups for other methods in AuthCubit
  });
}
