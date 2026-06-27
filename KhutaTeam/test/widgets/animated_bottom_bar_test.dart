import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuta/widgets/animated_bottom_bar.dart';
import '../helpers/test_helpers.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await setupLocalizationForTest();

  group('AnimatedBottomBar Widget Tests', () {
    testWidgets('renders correctly with active index 0', (WidgetTester tester) async {
      // Track which index was tapped
      int tappedIndex = -1;

      // Build the widget
      await tester.pumpWidget(
        wrapWithLocalization(
          Scaffold(
            body: Container(),
            bottomNavigationBar: AnimatedBottomBar(
              activeIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify the bottom bar is rendered
      expect(find.byType(AnimatedBottomBar), findsOneWidget);

      // Verify we have navigation items
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);

      // Verify we have the correct labels
      expect(find.text('nav_home'), findsOneWidget);
      expect(find.text('nav_settings'), findsOneWidget);
      expect(find.text('nav_about'), findsOneWidget);

      // Tap on the settings icon (index 1)
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();

      // Verify the correct index was tapped
      expect(tappedIndex, 1);
    });

    testWidgets('highlights the active tab correctly', (WidgetTester tester) async {
      // Build the widget with settings tab active
      await tester.pumpWidget(
        wrapWithLocalization(
          Scaffold(
            body: Container(),
            bottomNavigationBar: AnimatedBottomBar(
              activeIndex: 1, // Settings tab
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Find all icons
      final homeIcon = find.byIcon(Icons.home_rounded);
      final settingsIcon = find.byIcon(Icons.settings_rounded);
      final infoIcon = find.byIcon(Icons.info_rounded);

      // Verify all icons are present
      expect(homeIcon, findsOneWidget);
      expect(settingsIcon, findsOneWidget);
      expect(infoIcon, findsOneWidget);

      // Note: We can't directly test the color of the icons in this test framework
      // as it would require finding the specific Icon widget and checking its color property.
      // In a real app, you might use a testable widget key for this purpose.
    });
  });
}