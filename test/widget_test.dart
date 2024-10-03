import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:binarybandits/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build the MyApp widget and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads by finding any widget from the home screen.
    // For this basic test, we'll just check that a MaterialApp widget exists.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
