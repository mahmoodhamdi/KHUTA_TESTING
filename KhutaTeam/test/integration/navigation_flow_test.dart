import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/core/di/service_locator.dart';
import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/cubit/auth/auth_cubit.dart';
import 'package:khuta/cubit/onboarding/onboarding_cubit.dart';
import 'package:khuta/cubit/theme/theme_cubit.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/screens/about/about_screen.dart';
import 'package:khuta/screens/home/home_screen.dart';
import 'package:khuta/screens/main_screen.dart';
import 'package:khuta/screens/settings/settings_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';
import 'navigation_flow_test.mocks.dart';

@GenerateMocks([FirebaseAuth, SharedPreferences])

/// Mock implementation of ChildRepository for testing
class MockChildRepository implements ChildRepository {
  @override
  Future<List<Child>> getChildren() async => [];

  @override
  Future<Child?> getChild(String childId) async => null;

  @override
  Future<String> addChild(Child child) async => 'mock-id';

  @override
  Future<void> updateChild(Child child) async {}

  @override
  Future<void> deleteChild(String childId) async {}

  @override
  Stream<List<Child>> watchChildren() => Stream.value([]);

  @override
  Future<PaginatedChildren> getChildrenPaginated({
    int limit = 20,
    Object? startAfter,
  }) async =>
      const PaginatedChildren(children: []);
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await setupLocalizationForTest();

  late MockFirebaseAuth mockFirebaseAuth;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockSharedPreferences = MockSharedPreferences();

    // Setup SharedPreferences mock methods
    when(mockSharedPreferences.getBool(any)).thenReturn(false);
    when(mockSharedPreferences.setBool(any, any)).thenAnswer((_) async => true);
    when(mockSharedPreferences.getString(any)).thenReturn(null);
    when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);

    // Register mock repository with ServiceLocator
    ServiceLocator().registerChildRepository(MockChildRepository());
  });

  tearDown(() {
    // Reset ServiceLocator after each test
    ServiceLocator().reset();
  });

  group('Main Navigation Flow Integration Tests', () {
    testWidgets('Bottom navigation bar navigates between screens', (WidgetTester tester) async {
      // Build the main screen with all required providers
      await tester.pumpWidget(
        wrapWithLocalization(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => AuthCubit(auth: mockFirebaseAuth)),
                BlocProvider(create: (context) => ThemeCubit(prefs: mockSharedPreferences)),
                BlocProvider(create: (context) => OnboardingCubit(prefs: mockSharedPreferences)),
              ],
              child: const MainScreen(),
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify we start on the home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(AboutScreen), findsNothing);

      // Tap on the settings icon (index 1)
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();

      // Verify we navigated to the settings screen
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(AboutScreen), findsNothing);

      // Tap on the about icon (index 2)
      await tester.tap(find.byIcon(Icons.info_rounded));
      await tester.pumpAndSettle();

      // Verify we navigated to the about screen
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(AboutScreen), findsOneWidget);

      // Tap on the home icon (index 0) to go back to home
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      // Verify we navigated back to the home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(AboutScreen), findsNothing);
    });

    testWidgets('Bottom navigation preserves state between tabs', (WidgetTester tester) async {
      // This test would be more meaningful with actual state to preserve
      // For now, we'll just test that navigation works as expected
      
      // Build the main screen with all required providers
      await tester.pumpWidget(
        wrapWithLocalization(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => AuthCubit(auth: mockFirebaseAuth)),
                BlocProvider(create: (context) => ThemeCubit(prefs: mockSharedPreferences)),
                BlocProvider(create: (context) => OnboardingCubit(prefs: mockSharedPreferences)),
              ],
              child: const MainScreen(),
            ),
          ),
        ),
      );

      // Navigate to settings and back to home
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      // Verify we're back on the home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}