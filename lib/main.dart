/// This is the entry point of the app.
///
/// The `main` function initializes the Flutter framework and Firebase.
/// It ensures that Firebase is initialized before running the app.
/// If Firebase is already initialized, it uses the existing instance.
///
/// The `MyApp` widget is the root of the application. It takes a `FirebaseAuth`
/// instance as a required parameter.
///
/// The `MyAppState` class manages the state of the `MyApp` widget. It listens
/// for authentication state changes and updates the UI accordingly.
///
/// The `build` method of `MyAppState` returns a `MaterialApp` widget. If the
/// app is still loading, it shows a loading indicator. Once loading is complete,
/// it shows either the `HomeScreen` if the user is authenticated, or the
/// `LoginScreen` if the user is not authenticated.
///
/// The `routes` property of `MaterialApp` defines the available routes in the
/// app. It includes routes for the `RecipeSelectionScreen` and the
/// `NoRecipeSelectionScreen`.
library main;

import 'package:binarybandits/screens/login_screen/login_screen.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/no_recipe_selection_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart'; // Assuming you have this screen
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// This is the entry point of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      Firebase.app(); // if already initialized, use that one
    } else {
      rethrow;
    }
  }

  runApp(MyApp(auth: FirebaseAuth.instance));
}

// This is the main app widget
class MyApp extends StatefulWidget {
  final FirebaseAuth auth;

  const MyApp({super.key, required this.auth});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Binary Bandits',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _user != null ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/recipe_selection_screen': (context) =>
            const RecipeSelectionScreen(), // Assuming you have this screen
        '/no_recipe_selection_screen': (context) => NoRecipeSelectionScreen(),
      },
    );
  }
}
