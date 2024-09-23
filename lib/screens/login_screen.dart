import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    width: 150,
                    height: 50,
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                ), // Rounded corners only on top
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
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Input Field with label above
                  Text(
                    'Email',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
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
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Keep Me Signed In and Forgot Password Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (bool? value) {},
                          ),
                          Text(
                            'Keep me sign in',
                            style: GoogleFonts.roboto(),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Forgot password action
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.roboto(
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Row for the "Sign In" text and arrow button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              90, // Adjust the width to match your image size
                          height:
                              90, // Adjust the height to match your image size
                          fit: BoxFit
                              .fill, // Ensure the image fits within the given size
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Sign up action
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.roboto(
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
