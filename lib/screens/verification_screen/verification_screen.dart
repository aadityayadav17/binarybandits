/// A screen that handles email verification for the user. This screen periodically checks if the user's email
/// has been verified and navigates to the profile screen upon successful verification.
///
/// The screen displays a message instructing the user to check their email for a verification link and provides
/// options to resend the verification email or go back to the sign-up screen.
///
/// The verification check is performed every 5 seconds using a timer. If the email is verified, the timer is
/// canceled, and the user is navigated to the profile screen.
///
/// The screen also includes a button to manually check the email verification status and a button to resend the
/// verification email.
///
/// The layout of the screen is responsive, with font sizes and dimensions adjusted proportionally based on the
/// screen size.
library verification_screen;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:binarybandits/screens/profile_screen/profile.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkEmailVerified();
    });
  }

  // Check if the email is verified
  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      _timer?.cancel();
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const ProfileScreen(fromSignup: true),
        ));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Show a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double proportionalFontSize(double size) => size * screenWidth / 375;
    double proportionalHeight(double size) => size * screenHeight / 812;
    double proportionalWidth(double size) => size * screenWidth / 375;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 250, 244, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: proportionalHeight(120)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: proportionalWidth(24)),
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
                    'Verify Your Email',
                    style: GoogleFonts.roboto(
                      fontSize: proportionalFontSize(36),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: proportionalHeight(16)),
                  Text(
                    'We\'ve sent a verification email to your address. Please check your inbox and click the verification link to continue.',
                    style: GoogleFonts.roboto(
                      fontSize: proportionalFontSize(16),
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: proportionalHeight(160)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.roboto(
                          fontSize: proportionalFontSize(36),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _checkEmailVerified();
                          _showSnackBar(
                              'Checking email verification status...');
                        },
                        child: Image.asset(
                          'assets/icons/screens/log_screen/log-rectangle.png',
                          width: proportionalWidth(110),
                          height: proportionalHeight(110),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: proportionalHeight(80)),
                  TextButton(
                    onPressed: () async {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user.sendEmailVerification();
                        _showSnackBar(
                            'Verification email resent. Please check your inbox.');
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Resend Verification Email',
                      style: GoogleFonts.roboto(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w400,
                        fontSize: proportionalFontSize(16),
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: proportionalHeight(10)),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Back to Sign Up',
                      style: GoogleFonts.roboto(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w400,
                        fontSize: proportionalFontSize(16),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: proportionalHeight(60)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
