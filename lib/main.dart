import 'package:binarybandits/screens/login_screen/login_screen.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'firebase_options.dart'; // Import Firebase options for platform-specific initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Use correct platform options
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Track authentication state using FirebaseAuth
  User? _user; // This will hold the current user, null if not authenticated
  bool _isLoading =
      true; // To manage the loading state while checking authentication

  @override
  void initState() {
    super.initState();

    // Check the user's current authentication state
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user; // Update user state
        _isLoading = false; // Finished checking auth state
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading screen while checking if user is logged in
      return MaterialApp(
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // If user is logged in (_user is not null), show HomeScreen; otherwise, LoginScreen
      home: _user != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}
