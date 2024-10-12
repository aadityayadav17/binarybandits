import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen/login_screen.dart';
import '../profile_screen/profile.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _keepMeSignedIn = false;
  bool _agreeToPrivacyPolicy = false;
  bool _showPassword = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearFocus() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  Future<void> _saveKeepMeSignedInPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepMeSignedIn', value);
  }

  Future<void> _signUp() async {
    if (!_agreeToPrivacyPolicy) {
      _showErrorDialog('Please agree to the privacy policy to continue.');
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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

      // Navigate to ProfileScreen after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(fromSignup: true),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define proportional sizes based on screen dimensions
    double proportionalFontSize(double size) =>
        size * screenWidth / 375; // Assuming base screen width is 375
    double proportionalHeight(double size) =>
        size * screenHeight / 812; // Assuming base screen height is 812
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
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/app-logo.png',
                      width: proportionalWidth(164),
                      height: proportionalHeight(26),
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              SizedBox(height: proportionalHeight(20)),
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(proportionalWidth(24)),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(48)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Started',
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
                        controller: _emailController, // Add controller
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
                        controller: _passwordController, // Add controller
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            Text(
                              'Keep me signed in',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                fontSize: proportionalFontSize(14),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: proportionalHeight(10)),
                    Row(
                      children: [
                        SizedBox(
                          height: proportionalHeight(24),
                          width: proportionalWidth(24),
                          child: Checkbox(
                            value: _agreeToPrivacyPolicy,
                            onChanged: (bool? value) {
                              setState(() {
                                _agreeToPrivacyPolicy = value ?? false;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: proportionalWidth(8)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                fontSize: proportionalFontSize(14),
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(text: 'I have read '),
                                TextSpan(
                                  text: 'privacy policy',
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigate to privacy policy
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: proportionalHeight(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Sign Up',
                          style: GoogleFonts.roboto(
                            fontSize: proportionalFontSize(36),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: _signUp, // Call the sign-up method
                          child: Image.asset(
                            'assets/icons/screens/log_screen/log-rectangle.png',
                            width: proportionalWidth(110),
                            height: proportionalHeight(110),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: proportionalHeight(100)),
                    TextButton(
                      onPressed: () {
                        // Sign up action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign In',
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
