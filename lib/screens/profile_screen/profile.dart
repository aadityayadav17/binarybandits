import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:google_fonts/google_fonts.dart';
import 'widgets/profile_form_fields.dart';
import 'widgets/save_button.dart';
import '../home_screen/home_screen.dart';
import '../login_screen/login_screen.dart'; // Login screen import

class ProfileScreen extends StatefulWidget {
  final bool fromSignup;

  const ProfileScreen({super.key, required this.fromSignup});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for each field
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _budgetController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _expectedWeightController = TextEditingController();
  TextEditingController _homeDistrictController = TextEditingController();

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
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _loadProfile(user!.uid); // Load user-specific profile data using UID
    } else {
      print('No user is signed in.');
    }
  }

  // Save profile data to Firebase Realtime Database
  void _saveProfile() async {
    if (_isNameValid && user != null) {
      try {
        await databaseRef.child('users/${user!.uid}').set({
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'budget': _budgetController.text,
          'height': _heightController.text,
          'weight': _weightController.text,
          'expectedWeight': _expectedWeightController.text,
          'homeDistrict': _homeDistrictController.text,
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
    } else {
      // Show a dialog or alert if name is not valid
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Input'),
          content: Text('Please enter a valid name to save your profile.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Load profile data from Firebase Realtime Database
  void _loadProfile(String userId) async {
    try {
      DataSnapshot snapshot = await databaseRef.child('users/$userId').get();
      if (snapshot.exists) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? '';
          _budgetController.text = data['budget'] ?? '';
          _heightController.text = data['height'] ?? '';
          _weightController.text = data['weight'] ?? '';
          _expectedWeightController.text = data['expectedWeight'] ?? '';
          _homeDistrictController.text = data['homeDistrict'] ?? '';
          dietaryPreference = data['dietaryPreference'] ?? 'No Preference';
          dietaryRestrictions = (data['dietaryRestrictions'] != null)
              ? List<String>.from(data['dietaryRestrictions'] as List)
              : [];
        });
        print('Profile loaded successfully');
      } else {
        print('No profile data found for user: $userId');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  // Log out the user
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Log out from Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ), // Redirect to login
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // Reset the user's account (delete user data from Firebase Realtime Database)
  void _resetAccount() async {
    if (user != null) {
      try {
        await databaseRef
            .child('users/${user!.uid}')
            .remove(); // Remove user data
        print('Account reset successfully');
        _logout(); // Log out after resetting the account
      } catch (e) {
        print('Error resetting account: $e');
      }
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
                      nameController: _nameController,
                      phoneNumberController: _phoneNumberController,
                      budgetController: _budgetController,
                      heightController: _heightController,
                      weightController: _weightController,
                      expectedWeightController: _expectedWeightController,
                      homeDistrictController: _homeDistrictController,
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
                      onPressed: _saveProfile,
                    ),
                    SizedBox(height: proportionalHeight(24)),

                    // Logout and Reset buttons
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red color for logout
                      ),
                      child: Text('Log Out'),
                    ),
                    SizedBox(height: proportionalHeight(16)),
                    ElevatedButton(
                      onPressed: _resetAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange, // Orange color for reset
                      ),
                      child: Text('Reset Account'),
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
