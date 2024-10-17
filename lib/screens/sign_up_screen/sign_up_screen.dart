/// A StatefulWidget that represents the sign-up screen of the application.
///
/// This screen allows users to create a new account by providing their email
/// and password. It also includes options to keep the user signed in and to
/// agree to the privacy policy. Upon successful sign-up, a verification email
/// is sent to the user.
///
/// The screen includes the following features:
/// - Email and password input fields with validation.
/// - Checkbox to keep the user signed in.
/// - Checkbox to agree to the privacy policy.
/// - Toggle to show/hide the password.
/// - Proportional sizing based on screen dimensions.
/// - Navigation to the verification screen upon successful sign-up.
/// - Navigation to the login screen.
///
/// The sign-up process is handled using Firebase Authentication.
///
/// The class consists of:
/// - TextEditingController for email and password input fields.
/// - FocusNode for managing focus on input fields.
/// - Methods to handle sign-up, clear focus, and show snack bars.
/// - Proportional helper functions for responsive design.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const SignUpScreen()),
/// );
/// ```
library sign_up_screen;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_screen/login_screen.dart';
import 'package:binarybandits/screens/verification_screen/verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

// Proportional helper functions
class SignUpScreenState extends State<SignUpScreen> {
  bool _keepMeSignedIn = false;
  bool _agreeToPrivacyPolicy = false;
  bool _showPassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Clear focus from text fields
  void _clearFocus() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  // Sign up method
  Future<void> _signUp() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar('Please enter both email and password.');
      return;
    }

    if (!_agreeToPrivacyPolicy) {
      _showSnackBar('Please agree to the privacy policy to continue.');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Send an email verification to the user
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        _showSnackBar(
            'A verification email has been sent. Please check your email.');

        // Navigate to the VerificationScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VerificationScreen()),
        );
      }
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
          errorMessage = 'Signup failed: ${e.message}';
          break;
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar('An unexpected error occurred. Please try again.');
    }
  }

  // Show a snackbar with the given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
