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
          Color.fromRGBO(239, 250, 244, 1), // Light green background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
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

            SizedBox(height: 10), // Space between logo and content

            // Container with rounded white background for the main content
            Container(
              width:
                  screenWidth, // Set the width to the full width of the screen
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white, // White background for the content
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ), // Rounded corners only on top
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Back Text
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.roboto(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Email Input Field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.roboto(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Password Input Field
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.roboto(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

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
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Row for the button, with the combined rectangle and arrow image aligned right
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align the button to the right
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Sign in action
                        },
                        child: Image.asset(
                          'assets/icons/screens/log_screen/log-rectangle.png',
                          width:
                              60, // Adjust the width to match your image size
                          height:
                              60, // Adjust the height to match your image size
                          fit: BoxFit
                              .fill, // Ensure the image fits within the given size
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
