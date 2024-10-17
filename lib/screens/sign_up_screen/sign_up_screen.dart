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

        // Check if the widget is still mounted before using context
        if (mounted) {
          // Navigate to the VerificationScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
          );
        }
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

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40), // Space for the close button
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 20, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'This Privacy Policy outlines how EATEASY collects, uses, and protects the personal information you provide when using our mobile application. By using the App, you agree to the collection and use of information in accordance with this policy.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Information We Collect',
                        style: TextStyle(
                          fontSize: 18, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We collect the following personal information from users:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email Address: Used for login and authentication purposes.\n',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Optional Information',
                        style: TextStyle(
                          fontSize: 18, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your Height, Weight, Expected Weight are Used to provide personalized health and dietary recommendations.\n'
                        'Your Phone Number is used for optional contact and support purposes.\n'
                        'Your Name is used to personalize the user experience within the app.\n'
                        'Weekly Budget for Groceries is used to tailor recommendations based on your budget preferences.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'How We Use Your Information',
                        style: TextStyle(
                          fontSize: 18, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'The information we collect is used for the following purposes:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Authentication: Your email address is used for login and to ensure secure access to your account.\n'
                        'Personalization: Optional information such as height, weight, expected weight, and weekly budget allows us to customize the user experience and provide recommendations tailored to your needs.\n'
                        'Communication: If you provide a phone number, it may be used to contact you for customer support or app-related updates.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Data Storage and Processing',
                        style: TextStyle(
                          fontSize: 18, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'All personal data collected is:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Stored in Firebase: We use Firebase services to securely store your data.\n'
                        'Processed Locally: Any processing of your personal data, including calculations or recommendations, occurs locally on your device to enhance privacy and reduce data transmission.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Data Sharing and Security',
                        style: TextStyle(
                          fontSize: 18, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We do not sell or share your personal information with third parties, except as required by law or to comply with legal obligations.\n\n'
                        'We take appropriate security measures to protect against unauthorized access, alteration, disclosure, or destruction of your personal data. Firebase services also offer built-in security protocols to safeguard your information.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your Rights and Choices',
                        style: TextStyle(
                          fontSize: 18, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'View and update your personal information within the app.\n\n'
                        'If you wish to delete your account and personal data, you can request this through the app’s settings.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Changes to This Policy',
                        style: TextStyle(
                          fontSize: 18, // Increased font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the App and updating the effective date at the top of this policy.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0.0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
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
                                      _showPrivacyPolicyDialog(); // Show the pop-up dialog
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
