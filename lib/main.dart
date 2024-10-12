import 'package:binarybandits/screens/login_screen/login_screen.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

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

class MyApp extends StatefulWidget {
  final FirebaseAuth auth;

  const MyApp({Key? key, required this.auth}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    );
  }
}
