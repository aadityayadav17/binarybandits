import 'package:binarybandits/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we assume the user is NOT signed in
    bool isLoggedIn = false; // This will be replaced with Firebase auth logic

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // If user is not logged in, go to LoginScreen, otherwise HomeScreen
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
