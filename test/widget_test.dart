import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:binarybandits/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_mock.dart'; // Import the mock file we created

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build the MyApp widget and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads by finding any widget from the home screen.
    // For this basic test, we'll just check that a MaterialApp widget exists.
    expect(find.byType(MaterialApp), findsOneWidget);

    // You can add more specific widget tests here
    // For example:
    // expect(find.text('Welcome to Binary Bandits'), findsOneWidget);
  });
}
