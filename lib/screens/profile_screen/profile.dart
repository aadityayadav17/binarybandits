import 'package:flutter/material.dart';  // Flutter framework for UI components
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Authentication
import 'package:firebase_database/firebase_database.dart';  // Firebase Realtime Database
import 'package:google_fonts/google_fonts.dart';  // Google Fonts for text styling
import 'package:flutter/services.dart';  // For loading assets (like JSON files)
import 'dart:convert';  // For JSON encoding and decoding
import 'widgets/profile_form_fields.dart';  // Custom widget for profile form fields
import 'widgets/save_button.dart';  // Custom widget for save button
import '../home_screen/home_screen.dart';  // Home screen navigation after saving profile
import '../login_screen/login_screen.dart';  // Login screen for log out functionality
import 'package:binarybandits/models/recipe.dart';

class ProfileScreen extends StatefulWidget {
  final bool fromSignup;

  const ProfileScreen({super.key, required this.fromSignup});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _expectedWeightController = TextEditingController();
  final TextEditingController _homeDistrictController = TextEditingController();
 
  double calories = 0;
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
  _validateName(
      _nameController.text); // Ensure validation is called before checking

  double weight = double.tryParse(_weightController.text) ?? 0;
  double height = double.tryParse(_heightController.text) ?? 0;
  double expectedWeight = double.tryParse(_expectedWeightController.text) ?? 0;

  if (weight == 0 || height == 0) {
    print("Invalid inputs for calorie calculation");
    return;
  }

  // Using a general estimation formula 
  calories = ((10 * weight) + (6.25 * height)) * 1.55;

  if (weight < expectedWeight) {
    calories += 500;
  } else if (weight > expectedWeight) {
    calories -= 500;
  }

  // Adjust calories based on dietary preference
  if (dietaryPreference == 'Vegetarian') {
    calories *= 0.9;
  } else if (dietaryPreference == 'Vegan') {
    calories *= 0.85;
  }

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
          'calorieRequirement': calories,
        });

      // Load recipes from the JSON file
      final String response = await rootBundle.loadString('assets/recipes/D3801 Recipes - Recipes.json');
      final List<dynamic> recipeData = json.decode(response);

      List<Map<String, dynamic>> possibleRecipes = [];

      // Filter the recipes based on user's preferences and requirements
      for (var recipeJson in recipeData) {
        Recipe recipe = Recipe.fromJson(recipeJson);

        bool meetsCalorieRequirement = recipe.energyKcal <= (calories / 4);
        bool matchesDietaryPreference = dietaryPreference == 'No Preference' || 
            recipe.classification?.toLowerCase() == dietaryPreference?.toLowerCase();
        bool noAllergenConflict = dietaryRestrictions.every((restriction) =>
            recipe.allergens == null || !recipe.allergens!.map((allergen) => allergen.toLowerCase()).contains(restriction.toLowerCase()));

        // Add to possible recipes if all conditions are met
        if (meetsCalorieRequirement && matchesDietaryPreference && noAllergenConflict) {
          possibleRecipes.add({
            'recipe_id': recipe.id,
            'recipe_name': recipe.name,
          });
        }
      }

      // Upload possible recipes to Firebase under the node 'PossibleRecipes'
      await databaseRef.child('users/${user!.uid}/PossibleRecipes').set(possibleRecipes);
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
      // Show the dialog only if the name is not valid (empty)
      if (!_isNameValid) {
        _showInvalidInputDialog(context);
      }
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
      _isNameValid = name?.trim().isNotEmpty ??
          false; // Trim spaces before checking for empty
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
                        backgroundColor: const Color.fromARGB(
                            255, 255, 255, 255), // Same green as Save button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              proportionalWidth(10)), // Same border radius
                        ),
                        fixedSize: Size(
                          proportionalWidth(315), // Same width
                          proportionalHeight(48), // Same height
                        ),
                      ),
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.robotoFlex(
                          fontSize: proportionalFontSize(18), // Same font size
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(
                              73, 160, 120, 1), // Same font color
                        ),
                      ),
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

  void _showInvalidInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Invalid Input",
                    style: GoogleFonts.robotoFlex(
                      textStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  "Please enter a valid name to save your profile.",
                  style: GoogleFonts.robotoFlex(
                    textStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.018,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          backgroundColor:
                              const Color.fromRGBO(73, 160, 120, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'OK',
                          style: GoogleFonts.robotoFlex(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
