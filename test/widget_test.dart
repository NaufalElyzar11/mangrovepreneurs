// Basic widget test for Kalulut Hive Monitor app

import 'package:flutter_test/flutter_test.dart';

import 'package:mangrovepreneurs_v2/main.dart';

void main() {
  testWidgets('App renders MainScreen with bottom navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MangroveApp());

    // Verify that bottom navigation items are present
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify Dashboard page header is shown by default
    expect(find.text('Mangrovepreneurs'), findsOneWidget);
    expect(find.text('Your Hives'), findsOneWidget);
  });
}
