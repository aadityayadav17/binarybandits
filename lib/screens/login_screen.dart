import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  // Remove the const keyword from here
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
              Center(
                child: Image.asset(
                  'assets/images/app-logo.png',
                  width: 150,
                  height: 50,
                ),
              ),
              SizedBox(height: 50), // Space between logo and form
              Text(
                'Welcome Back',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
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
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/icons/screens/log_screen/log-rectangle.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Center(
                        child: IconButton(
                          icon: Image.asset(
                            'assets/icons/screens/log_screen/continue-arrow.png',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            // Sign in action
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
