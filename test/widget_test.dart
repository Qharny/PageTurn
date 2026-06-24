// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pageturn/main.dart';

void main() {
  testWidgets('Home page layout and bottom tab switching smoke test', (WidgetTester tester) async {
    // Set onboarding as completed to skip to home
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for splash screen to complete and transition to home
    await tester.pump(const Duration(milliseconds: 3600));
    await tester.pumpAndSettle();

    // Verify that our home screen is loaded and contains main sections
    expect(find.text('PageTurn'), findsOneWidget);
    expect(find.text('BOOK OF THE DAY'), findsOneWidget);
    expect(find.text('The Midnight Library'), findsOneWidget);
    expect(find.text('Continue Reading'), findsOneWidget);
    expect(find.text('Trending Now'), findsOneWidget);
    expect(find.text('African Spotlight'), findsOneWidget);
    expect(find.text('Recommended for You'), findsOneWidget);

    // Tap Library tab and verify it loads the placeholder
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('Manage your saved, reading, and completed books.'), findsOneWidget);
  });

  testWidgets('Onboarding flow smoke test', (WidgetTester tester) async {
    // Initialize onboarding as not completed (first visit)
    SharedPreferences.setMockInitialValues({'onboarding_completed': false});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for splash screen to complete and transition to onboarding
    await tester.pump(const Duration(milliseconds: 3600));
    await tester.pumpAndSettle();

    // Verify we are on onboarding page 1
    expect(find.text('Open. Read. Repeat.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap "Next" to go to Page 2
    await tester.tap(find.text('Next'));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Verify we are on onboarding page 2
    expect(find.text('Immersive Reading.'), findsOneWidget);

    // Tap "Next" to go to Page 3
    await tester.tap(find.text('Next'));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    // Verify we are on onboarding page 3
    expect(find.text('Take it Anywhere.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap "Get Started" to complete onboarding and route to home
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify that our home page is loaded
    expect(find.text('PageTurn'), findsOneWidget);
    expect(find.text('BOOK OF THE DAY'), findsOneWidget);
  });
}
