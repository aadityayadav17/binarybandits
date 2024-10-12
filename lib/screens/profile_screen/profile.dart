import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
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
  bool _isSaved = false;
  bool _isNameValid = false;

  // Firebase Realtime Database reference
  final databaseRef = FirebaseDatabase.instance.ref();
  User? user; // Firebase user object to track the logged-in user

  @override
  void initState() {
    super.initState();
    // Get the currently signed-in user
    user = FirebaseAuth.instance.currentUser;

    // Load profile if the user is authenticated
    if (user != null) {
      _loadProfile(user!.uid); // Load user-specific profile data using UID
    } else {
      print('No user is signed in.');
    }
  }

  // Function to save the profile data to Firebase Realtime Database
  void _saveProfile() async {
    if (_isNameValid && user != null) {
      try {
        // Save profile data under the logged-in user's UID
        await databaseRef.child('users/${user!.uid}').set({
          'dietaryPreference': dietaryPreference,
          'dietaryRestrictions': dietaryRestrictions,
        });
        _updateSaveStatus(true);
        if (widget.fromSignup) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
        print('Profile saved successfully');
      } catch (e) {
        print('Error saving profile: $e');
      }
    }
  }

  // Function to load the profile data from Firebase Realtime Database
  void _loadProfile(String userId) async {
    try {
      DataSnapshot snapshot = await databaseRef.child('users/$userId').get();
      if (snapshot.exists) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          dietaryPreference = data['dietaryPreference'];
          dietaryRestrictions = List<String>.from(data['dietaryRestrictions']);
        });
        print('Profile loaded successfully');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

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

    double proportionalFontSize(double size) => size * screenWidth / 375;
    double proportionalHeight(double size) => size * screenHeight / 812;
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
                      onPressed:
                          _saveProfile, // Save profile to Firebase when button is pressed
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
