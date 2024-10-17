import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/sign_up_screen/sign_up_screen.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _keepMeSignedIn = false;
  bool _showPassword = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Load the keep me signed in preference when the screen is created
  @override
  void initState() {
    super.initState();
    _loadKeepMeSignedInPreference();
  }

  // Dispose the focus nodes
  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Clear the focus of the text fields
  void _clearFocus() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  // Load the keep me signed in preference
  Future<void> _loadKeepMeSignedInPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _keepMeSignedIn = prefs.getBool('keepMeSignedIn') ?? false;
    });
  }

  // Save the keep me signed in preference
  Future<void> _saveKeepMeSignedInPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepMeSignedIn', value);
  }

  // Sign in with email and password
  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter both email and password'),
          ),
        );
      }
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save the keep me signed in preference
      await _saveKeepMeSignedInPreference(_keepMeSignedIn);

      // If keep me signed in is false, set up a listener to sign out when the app is closed
      if (!_keepMeSignedIn) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            // User has been signed out
            _saveKeepMeSignedInPreference(false);
          }
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = 'Authentication failed. Please check your credentials.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double proportionalFontSize(double size) => size * screenWidth / 375;
    double proportionalHeight(double size) => size * screenHeight / 812;
    double proportionalWidth(double size) => size * screenWidth / 375;

    return GestureDetector(
      onTap: _clearFocus,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(239, 250, 244, 1),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: proportionalHeight(120)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: proportionalWidth(24)),
                child: Image.asset(
                  'assets/images/app-logo.png',
                  width: proportionalWidth(164),
                  height: proportionalHeight(26),
                  alignment: Alignment.centerLeft,
                ),
              ),
              SizedBox(height: proportionalHeight(20)),
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(proportionalWidth(24)),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(48),
                    topRight: Radius.circular(48),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.roboto(
                        fontSize: proportionalFontSize(36),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: proportionalHeight(16)),
                    Text(
                      'Email',
                      style: GoogleFonts.roboto(
                        fontSize: proportionalFontSize(14),
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: proportionalHeight(5)),
                    SizedBox(
                      height: proportionalHeight(40),
                      child: TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: proportionalHeight(10),
                            horizontal: proportionalWidth(10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: proportionalHeight(20)),
                    Text(
                      'Password',
                      style: GoogleFonts.roboto(
                        fontSize: proportionalFontSize(14),
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: proportionalHeight(5)),
                    SizedBox(
                      height: proportionalHeight(40),
                      child: TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: proportionalHeight(10),
                            horizontal: proportionalWidth(10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            child: Container(
                              width: proportionalWidth(40),
                              height: proportionalHeight(40),
                              alignment: Alignment.center,
                              child: Image.asset(
                                _showPassword
                                    ? 'assets/icons/screens/log_screen/eye-open.png'
                                    : 'assets/icons/screens/log_screen/eye-closed.png',
                                width: proportionalWidth(20),
                                height: proportionalHeight(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: proportionalHeight(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                height: proportionalHeight(24),
                                width: proportionalWidth(24),
                                child: Checkbox(
                                  value: _keepMeSignedIn,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _keepMeSignedIn = value ?? false;
                                      _clearFocus();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: proportionalWidth(8)),
                              Flexible(
                                child: Text(
                                  'Keep me signed in',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w400,
                                    fontSize: proportionalFontSize(14),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Forgot password action
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.roboto(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w400,
                              fontSize: proportionalFontSize(14),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: proportionalHeight(43)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.roboto(
                              fontSize: proportionalFontSize(36),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to HomeScreen when the button is clicked
                            _signIn();
                          },
                          child: Image.asset(
                            'assets/icons/screens/log_screen/log-rectangle.png',
                            width: proportionalWidth(110),
                            height: proportionalHeight(110),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: proportionalHeight(100)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.roboto(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w400,
                          fontSize: proportionalFontSize(20),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: proportionalHeight(100)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
