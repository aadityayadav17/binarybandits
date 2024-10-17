/// The `ProfileScreen` widget displays and manages the user's profile information.
/// It allows users to view, edit, and save their profile details, including personal
/// information, dietary preferences, and dietary restrictions. The profile data is
/// stored and retrieved from Firebase Realtime Database.
///
/// The screen also provides functionality to calculate the user's daily calorie
/// requirements based on their weight, height, and dietary preferences. Additionally,
/// it filters and uploads possible recipes that match the user's dietary needs.
///
/// The `ProfileScreen` widget is a stateful widget that maintains the state of the
/// profile form fields and handles various actions such as saving the profile,
/// loading profile data, and logging out the user.
///
/// Properties:
/// - `fromSignup`: A boolean indicating whether the screen is accessed from the signup
///   process.
///
/// State:
/// - `ProfileScreenState`: The state class for `ProfileScreen` that manages the profile
///   form fields, handles data loading and saving, and provides UI elements for the
///   profile screen.
///
/// Methods:
/// - `initState`: Initializes the state and loads the user's profile data if the user
///   is logged in.
/// - `_saveProfile`: Validates and saves the profile data to Firebase Realtime Database,
///   calculates the user's calorie requirements, and filters possible recipes based on
///   the user's preferences.
/// - `_loadProfile`: Loads the user's profile data from Firebase Realtime Database.
/// - `_logout`: Logs out the user and redirects to the login screen.
/// - `_updateSaveStatus`: Updates the save status of the profile form.
/// - `_validateName`: Validates the name field to ensure it is not empty.
/// - `_showInvalidInputDialog`: Displays a dialog indicating invalid input if the name
///   field is empty.
///
/// The `ProfileScreen` widget uses various other widgets such as `ProfileFormFields`
/// and `SaveButton` to build the profile form and handle user interactions.
library profile_screen;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'widgets/profile_form_fields.dart';
import 'widgets/save_button.dart';
import '../home_screen/home_screen.dart';
import '../login_screen/login_screen.dart';
import 'package:binarybandits/models/recipe.dart';

class ProfileScreen extends StatefulWidget {
  final bool fromSignup;

  const ProfileScreen({super.key, required this.fromSignup});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  // Controllers for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _expectedWeightController =
      TextEditingController();
  final TextEditingController _homeDistrictController = TextEditingController();

  double calories = 0;
  String? dietaryPreference = 'No Preference';
  List<String> dietaryRestrictions = [];
  bool _isSaved = false;
  bool _isNameValid = false;

  // Firebase Realtime Database reference
  final databaseRef = FirebaseDatabase.instance.ref();
  User? user; // Firebase user object to track the logged-in user

  // Load user-specific profile data
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _loadProfile(user!.uid); // Load user-specific profile data using UID
    } else {}
  }

  // Save profile data to Firebase Realtime Database
  void _saveProfile() async {
    _validateName(
        _nameController.text); // Ensure validation is called before checking

    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    double expectedWeight =
        double.tryParse(_expectedWeightController.text) ?? 0;

    if (weight == 0 || height == 0) {
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
        final String response = await rootBundle
            .loadString('assets/recipes/D3801 Recipes - Recipes.json');
        final List<dynamic> recipeData = json.decode(response);

        List<Map<String, dynamic>> possibleRecipes = [];

        // Filter the recipes based on user's preferences and requirements
        for (var recipeJson in recipeData) {
          Recipe recipe = Recipe.fromJson(recipeJson);

          bool meetsCalorieRequirement = recipe.energyKcal <= (calories / 4);
          bool matchesDietaryPreference =
              dietaryPreference == 'No Preference' ||
                  recipe.classification?.toLowerCase() ==
                      dietaryPreference?.toLowerCase();
          bool noAllergenConflict = dietaryRestrictions.every((restriction) =>
              recipe.allergens == null ||
              !recipe.allergens!
                  .map((allergen) => allergen.toLowerCase())
                  .contains(restriction.toLowerCase()));

          // Add to possible recipes if all conditions are met
          if (meetsCalorieRequirement &&
              matchesDietaryPreference &&
              noAllergenConflict) {
            possibleRecipes.add({
              'recipe_id': recipe.id,
              'recipe_name': recipe.name,
            });
          }
        }

        // Upload possible recipes to Firebase under the node 'PossibleRecipes'
        await databaseRef
            .child('users/${user!.uid}/PossibleRecipes')
            .set(possibleRecipes);
        _updateSaveStatus(true);

        // Check if widget is still mounted before navigating
        if (widget.fromSignup && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      } catch (e) {
        print(e);
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
      } else {}
    } catch (e) {
      print(e);
    }
  }

  // Log out the user
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Log out from Firebase
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ), // Redirect to login
        );
      }
    } catch (e) {
      print(e);
    }
  }

  // Update the save status
  void _updateSaveStatus(bool saved) {
    setState(() {
      _isSaved = saved;
    });
  }

  // Validate the name field
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

  // Method to show an invalid input dialog
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
