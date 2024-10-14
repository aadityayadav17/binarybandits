import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/widgets/recipe_card_component.dart';
import 'package:binarybandits/screens/weekly_menu_screen/widgets/recipe_information_card.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/no_weekly_menu_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WeeklyMenuScreen extends StatefulWidget {
  WeeklyMenuScreen({Key? key}) : super(key: key);

  @override
  _WeeklyMenuScreenState createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends State<WeeklyMenuScreen> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();
  late List<Recipe> _recipes = [];
  late List<bool> _savedRecipes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _loadRecipes();
  }

  // Load recipes from Firebase and match with JSON data
  Future<void> _loadRecipes() async {
    try {
      // Get the current user ID from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is logged in.");
        setState(() {
          _recipes = [];
          _isLoading = false;
        });
        return;
      }
      String userId = user.uid;

      // Fetch the recipeWeeklyMenu from Firebase where accepted is true
      final DatabaseReference ref =
          FirebaseDatabase.instance.ref("users/$userId/recipeWeeklyMenu");
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        final Map<String, dynamic> weeklyMenu =
            Map<String, dynamic>.from(snapshot.value as Map);

        // Filter recipes where "accepted" is true
        final acceptedRecipes = weeklyMenu.values
            .where((recipe) => recipe['accepted'] == true)
            .toList();

        print("Accepted recipes from Firebase: $acceptedRecipes");

        // Load the recipes from the JSON file
        final String jsonResponse = await rootBundle
            .loadString('assets/recipes/D3801 Recipes - Recipes.json');
        final List<dynamic> jsonRecipes = json.decode(jsonResponse);

        print("Recipes from JSON: ${jsonRecipes.length}");

        // Match the recipes from the Firebase weeklyMenu with the JSON file based on ID
        List<Recipe> matchedRecipes = [];
        for (var menuRecipe in acceptedRecipes) {
          var matchingRecipe = jsonRecipes.firstWhere(
              (jsonRecipe) => jsonRecipe['recipe_id'] == menuRecipe['id'],
              orElse: () => null);
          if (matchingRecipe != null) {
            matchedRecipes.add(Recipe.fromJson(matchingRecipe));
          } else {
            print("No matching recipe found for ID: ${menuRecipe['id']}");
          }
        }

        setState(() {
          _recipes = matchedRecipes;
          _savedRecipes = List.generate(_recipes.length, (index) => false);
          _isLoading = false;
        });

        print("Loaded recipes: ${_recipes.length}");
      } else {
        print("No recipes found in Firebase.");
        setState(() {
          _recipes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading recipes: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextRecipe() {
    if (_currentIndex < _recipes.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousRecipe() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _removeRecipe(int index) {
    setState(() {
      _recipes.removeAt(index);
      _savedRecipes.removeAt(index);
      if (_currentIndex >= _recipes.length) {
        _currentIndex = _recipes.length - 1;
      }
      if (_recipes.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NoWeeklyMenuScreen()),
        );
      }
    });
  }

  void _toggleSavedRecipe(int index) {
    setState(() {
      _savedRecipes[index] = !_savedRecipes[index];
    });
  }

  void _clearAllRecipes() {
    setState(() {
      _recipes.clear();
      _savedRecipes.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NoWeeklyMenuScreen()),
      );
    });
  }

  void _showClearAllDialog(BuildContext context) {
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
                vertical: MediaQuery.of(context).size.height * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Are you sure you want to clear it all?",
                    style: GoogleFonts.robotoFlex(
                      textStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'No',
                          style: GoogleFonts.robotoFlex(
                            textStyle: TextStyle(
                              color: Color.fromRGBO(73, 160, 120, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _clearAllRecipes();
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
                          'Yes',
                          style: GoogleFonts.robotoFlex(
                            textStyle: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardTopPosition = screenHeight * 0.35;
    final cardHeight = screenHeight * 0.3;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recipes.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NoWeeklyMenuScreen()),
        );
      });
      return Container();
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        toolbarHeight: screenHeight * 0.05,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.02),
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/common/back-key.png',
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SizedBox(
        height: screenHeight - screenHeight * 0.05,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "My Menu",
                            style: GoogleFonts.robotoFlex(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: screenHeight * 0.04,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_recipes.length}',
                                style: GoogleFonts.robotoFlex(
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenHeight * 0.04,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                "Selected",
                                style: GoogleFonts.robotoFlex(
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenHeight * 0.02,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
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
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.008),
                          child: TextButton(
                            onPressed: () {
                              _showClearAllDialog(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Clear all',
                              style: GoogleFonts.robotoFlex(
                                textStyle: TextStyle(
                                  color: Color.fromRGBO(73, 160, 120, 1),
                                  fontSize: screenHeight * 0.015,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    RecipeCardStack(
                      recipe: _recipes[_currentIndex],
                      screenWidth: screenWidth * 0.9,
                      cardTopPosition: cardTopPosition,
                      cardHeight: cardHeight,
                      scrollController: _scrollController,
                    ),
                    // Cross button
                    Positioned(
                      top: cardTopPosition * 0.05,
                      left: screenWidth * 0.05,
                      child: IconButton(
                        icon: Image.asset(
                          'assets/icons/screens/recipe_overview_screen/cross.png',
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                        ),
                        onPressed: () => _removeRecipe(_currentIndex),
                      ),
                    ),
                    // Save button
                    Positioned(
                      top: cardTopPosition * 0.05,
                      right: screenWidth * 0.05,
                      child: IconButton(
                        icon: Image.asset(
                          _savedRecipes[_currentIndex]
                              ? 'assets/icons/screens/recipe_selection_screen/save-on.png'
                              : 'assets/icons/screens/recipe_selection_screen/save.png',
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                        ),
                        onPressed: () => _toggleSavedRecipe(_currentIndex),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            RecipeInformationCard(
              key: ValueKey(_recipes[_currentIndex].id),
              recipe: _recipes[_currentIndex],
              topPosition: cardTopPosition + screenHeight * 0.08,
              cardHeight: cardHeight,
              scrollController: _scrollController,
              screenWidth: screenWidth,
            ),
            if (_currentIndex > 0)
              Positioned(
                left: -screenWidth * 0.04,
                top: (screenHeight - screenHeight * 0.25) / 2,
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/screens/weekly_menu_screen/left.png',
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                  ),
                  onPressed: _previousRecipe,
                ),
              ),
            if (_currentIndex < _recipes.length - 1)
              Positioned(
                right: -screenWidth * 0.04,
                top: (screenHeight - screenHeight * 0.25) / 2,
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/screens/weekly_menu_screen/right.png',
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                  ),
                  onPressed: _nextRecipe,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeSelectionScreen(),
                ),
              );
              break;
            case 2:
              // Action for Discover Recipe button
              break;
            case 3:
              // Action for Weekly Menu button
              break;
            default:
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/home-off.png',
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/discover-recipe-off.png',
              width: screenWidth * 0.055,
              height: screenWidth * 0.055,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/grocery-list-off.png',
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/weekly-menu-on.png',
              width: screenWidth * 0.065,
              height: screenWidth * 0.065,
            ),
            label: '',
          ),
        ],
        selectedItemColor: const Color.fromRGBO(73, 160, 120, 1),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
