import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50), // Padding from top

              // Row for logo on the left
              Row(
                children: [
                  Image.asset(
                    'assets/images/app-logo.png',
                    width: 164,
                    height: 26,
                    alignment: Alignment.centerLeft, // Logo aligned to left
                  ),
                ],
              ),

              SizedBox(height: 50), // Space between logo and form

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
                      width: 90,
                      height: 90,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Sign Up Text Button
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
      ),
    );
  }
}
