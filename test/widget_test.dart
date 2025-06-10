/// NEA Bill Check App Tests
/// Developed by Samyk Chaudhary
/// GitHub: @immsamyak (https://github.com/immsamyak/neabillcheck)

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_management/main.dart';

void main() {
  testWidgets('Splash screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen shows
    expect(find.text('NEA Bill Check'), findsOneWidget);
    expect(find.text('Check your electricity bill easily'), findsOneWidget);
    expect(find.byIcon(Icons.electric_bolt_rounded), findsOneWidget);
  });
}
