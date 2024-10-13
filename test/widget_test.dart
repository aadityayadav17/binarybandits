import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Build a simple widget.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Hello, World!'),
        ),
      ),
    );

    // Check if the text "Hello, World!" appears on the screen.
    expect(find.text('Hello, World!'), findsOneWidget);
  });
}
