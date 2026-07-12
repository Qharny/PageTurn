// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pageturn/data/repositories/repository_locator.dart';
import 'package:pageturn/data/sources/remote/gutendex_source.dart';
import 'package:pageturn/main.dart';

void main() {
  setUpAll(() async {
    // Bypass path_provider (unavailable under plain `flutter test`) with a
    // temp directory so Hive can still open its local index.
    final tempDir = Directory.systemTemp.createTempSync('pageturn_test_');
    await RepositoryLocator.init(testDirectoryPath: tempDir.path);

    // `flutter test`'s TestWidgetsFlutterBinding makes all real HTTP
    // requests fail (status 400), but Home now fetches live Gutendex data
    // on load. Swap in a fake client serving a captured real response so
    // the widget tree under test doesn't depend on network access.
    final fixture = File('test/fixtures/gutendex_search_alice.json').readAsStringSync();
    RepositoryLocator.gutendex = GutendexSource(
      client: MockClient((request) async => http.Response(fixture, 200)),
    );
  });

  testWidgets('Home page layout and bottom tab switching smoke test', (WidgetTester tester) async {
    // Set onboarding as completed to skip to home
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for splash screen to complete and transition to home. A polling
    // loop is used instead of pumpAndSettle: Home shows an indeterminate
    // CircularProgressIndicator while its (mocked) network fetch resolves,
    // and pumpAndSettle never returns while one is on screen. Real
    // Future.delayed calls are interleaved so pending real I/O (Hive) gets
    // a chance to complete between pumps.
    await tester.pump(const Duration(milliseconds: 3600));
    for (int i = 0; i < 50 && find.text('BOOK OF THE DAY').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    // Verify that our home screen is loaded and contains main sections
    expect(find.text('PageTurn'), findsOneWidget);
    expect(find.text('BOOK OF THE DAY'), findsOneWidget);
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

    // Tap "Get Started" to complete onboarding and route to home. As above,
    // a polling loop is used since Home shows an indeterminate spinner
    // while its (mocked) network fetch resolves.
    await tester.tap(find.text('Get Started'));
    for (int i = 0; i < 50 && find.text('PageTurn').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    // Verify that our home page is loaded
    expect(find.text('PageTurn'), findsOneWidget);
    expect(find.text('BOOK OF THE DAY'), findsOneWidget);
  });
}
