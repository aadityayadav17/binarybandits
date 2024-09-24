import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State to track if the checkbox is checked or not
  bool _keepMeSignedIn = false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    // Get the full width of the screen using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Set the background color of the whole screen to light green
      backgroundColor:
          const Color.fromRGBO(239, 250, 244, 1), // Light green background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add height above the logo
            const SizedBox(height: 120), // You can adjust this height

            // App Logo with reduced padding below the logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/app-logo.png',
                    width: 164,
                    height: 26,
                    alignment:
                        Alignment.centerLeft, // Align the logo to the left
                  ),
                ],
              ),
            ),

            // Remove extra space between logo and rectangle (SizedBox height set to 0)
            const SizedBox(height: 20),

            // Container with rounded white background for the main content
            Container(
              width:
                  screenWidth, // Set the width to the full width of the screen
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white, // White background for the content
                borderRadius: BorderRadius.all(Radius.circular(48)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Back Text
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.roboto(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Input Field with label above
                  Text(
                    'Email',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 40, // Set height of the text box
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10), // Adjust padding to fit text
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password Input Field with label above
                  Text(
                    'Password',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 40, // Set height of the text box
                    child: TextField(
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
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
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              _showPassword
                                  ? 'assets/icons/screens/log_screen/eye-open.png'
                                  : 'assets/icons/screens/log_screen/eye-closed.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Keep Me Signed In and Forgot Password Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Functional Checkbox
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _keepMeSignedIn,
                              onChanged: (bool? value) {
                                setState(() {
                                  _keepMeSignedIn = value ??
                                      false; // Update the checkbox state
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Keep me signed in',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: TextButton(
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
                                fontSize: 14,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Row for the "Sign In" text and arrow button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: GoogleFonts.roboto(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Sign in action
                        },
                        child: Image.asset(
                          'assets/icons/screens/log_screen/log-rectangle.png',
                          width:
                              110, // Adjust the width to match your image size
                          height:
                              110, // Adjust the height to match your image size
                          fit: BoxFit
                              .fill, // Ensure the image fits within the given size
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 140),

                  // Sign Up button aligned with text boxes
                  TextButton(
                    onPressed: () {
                      // Sign up action
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
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 74),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
