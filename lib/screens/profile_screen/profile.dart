import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/profile_form_fields.dart';
import 'widgets/save_button.dart';
import '../home_screen/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool fromSignup; // Track where the screen was launched from

  const ProfileScreen({super.key, required this.fromSignup});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? dietaryPreference = 'No Preference';
  List<String> dietaryRestrictions = [];
  bool _isSaved = false; // State to manage save status
  bool _isNameValid = false; // State to manage if the name is entered

  void _updateSaveStatus(bool saved) {
    setState(() {
      _isSaved = saved;
    });
  }

  void _validateName(String? name) {
    setState(() {
      _isNameValid = name?.isNotEmpty ?? false;
    });
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

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(239, 250, 244, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(239, 250, 244, 1),
          elevation: 0,
          toolbarHeight: proportionalHeight(60),
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(left: proportionalWidth(8)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: proportionalWidth(16),
                  top: proportionalHeight(10),
                  bottom: proportionalHeight(24),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: proportionalFontSize(36),
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: proportionalWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileFormFields(
                      onNameValidated: _validateName,
                      onDietaryPreferenceChanged: (value) {
                        _updateSaveStatus(false);
                        dietaryPreference = value;
                      },
                      onDietaryRestrictionsChanged: (value) {
                        _updateSaveStatus(false);
                        dietaryRestrictions = value;
                      },
                      dietaryPreference: dietaryPreference,
                      dietaryRestrictions: dietaryRestrictions,
                      onAnyFieldChanged: () {
                        _updateSaveStatus(false);
                      },
                    ),
                    SizedBox(height: proportionalHeight(24)),
                    SaveButton(
                      isSaved: _isSaved,
                      onPressed: () {
                        if (_isNameValid) {
                          _updateSaveStatus(true); // Logic to save profile data
                          // Check where the user came from before deciding what to do next
                          if (widget.fromSignup) {
                            // Navigate to HomeScreen if the user came from the signup page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
                        } else {
                          // Optionally handle what happens when the name isn't valid
                          // For example, you could show a dialog or a notification
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Invalid Input'),
                                content: Text(
                                    'Please enter a valid name to proceed.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Dismiss the dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }, // Always provide a non-nullable function
                    ),
                    SizedBox(height: proportionalHeight(40)),
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
