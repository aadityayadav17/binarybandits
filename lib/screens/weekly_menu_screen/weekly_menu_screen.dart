/// A screen that displays the weekly menu for the user. It allows users to view,
/// save, and remove recipes from their weekly menu. The recipes are loaded from
/// Firebase and matched with local JSON data.
///
/// The screen provides functionalities to:
/// - Load recipes from Firebase and match them with local JSON data.
/// - Update recipes in the weekly menu and collection.
/// - Navigate between recipes.
/// - Clear all recipes from the weekly menu.
/// - Show a dialog to confirm clearing all recipes.
///
/// The screen also includes a bottom navigation bar for navigating to other
/// screens such as Home, Recipe Selection, and Grocery List.
///
/// The main components of the screen are:
/// - Recipe cards displaying the current recipe.
/// - Buttons to save or remove the current recipe.
/// - Navigation buttons to move to the next or previous recipe.
/// - A button to clear all recipes from the weekly menu.
///
/// The screen handles loading states and navigates to a different screen if no
/// recipes are available in the weekly menu.
library weekly_menu_screen;

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
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WeeklyMenuScreen extends StatefulWidget {
  const WeeklyMenuScreen({super.key});

  @override
  WeeklyMenuScreenState createState() => WeeklyMenuScreenState();
}

class WeeklyMenuScreenState extends State<WeeklyMenuScreen> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();
  late List<Recipe> _recipes = [];
  late List<bool> _savedRecipes;
  bool _isLoading = true;
  Map<String, dynamic> _recipeCollection = {};
  Map<String, dynamic> _recipeWeeklyMenu = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _loadRecipes();
  }

  // Load recipes from Firebase and match with JSON data
  Future<void> _loadRecipes() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _recipes = [];
          _isLoading = false;
        });
        return;
      }

      await _loadRecipeCollection(user);
      await _loadRecipeWeeklyMenu(user);

      final String jsonResponse = await rootBundle
          .loadString('assets/recipes/D3801 Recipes - Recipes.json');
      final List<dynamic> jsonRecipes = json.decode(jsonResponse);

      List<Recipe> matchedRecipes = [];
      _recipeWeeklyMenu.forEach((key, value) {
        if (value['accepted'] == true) {
          var matchingRecipe = jsonRecipes.firstWhere(
              (jsonRecipe) => jsonRecipe['recipe_id'] == value['id'],
              orElse: () => null);
          if (matchingRecipe != null) {
            matchedRecipes.add(Recipe.fromJson(matchingRecipe));
          }
        }
      });

      setState(() {
        _recipes = matchedRecipes;
        _savedRecipes = List.generate(
            _recipes.length,
            (index) =>
                _recipeCollection.containsKey(_recipes[index].id) &&
                _recipeCollection[_recipes[index].id]['saved'] == true);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load recipe collection from Firebase
  Future<void> _loadRecipeCollection(User user) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('recipeCollection');

    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);

    if (snapshot.value != null) {
      Map<dynamic, dynamic> collectionMap =
          snapshot.value as Map<dynamic, dynamic>;
      Map<String, dynamic> processedMap = {};

      collectionMap.forEach((key, value) {
        String recipeId = value['id'].toString();
        processedMap[recipeId] = {
          'key': key,
          'name': value['name'],
          'saved': value['saved'] ?? false,
          'timestamp': value['timestamp'],
        };
      });

      _recipeCollection = processedMap;
    }
  }

  // Load weekly menu from Firebase
  Future<void> _loadRecipeWeeklyMenu(User user) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('recipeWeeklyMenu');

    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);

    if (snapshot.value != null) {
      Map<dynamic, dynamic> weeklyMenuMap =
          snapshot.value as Map<dynamic, dynamic>;
      Map<String, dynamic> processedMap = {};

      weeklyMenuMap.forEach((key, value) {
        String recipeId = value['id'].toString();
        processedMap[recipeId] = {
          'key': key,
          'id': value['id'],
          'name': value['name'],
          'accepted': value['accepted'] ?? false,
          'timestamp': value['timestamp'],
          'servings': value['servings'] ?? 1,
        };
      });

      _recipeWeeklyMenu = processedMap;
    }
  }

  // Update recipe in weekly menu
  Future<void> _updateRecipeInWeeklyMenu(String recipeId,
      {required bool accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _recipeWeeklyMenu.containsKey(recipeId)) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu')
          .child(_recipeWeeklyMenu[recipeId]['key']);

      await ref.update({
        'accepted': accepted,
        'timestamp': ServerValue.timestamp,
      });

      setState(() {
        _recipeWeeklyMenu[recipeId]['accepted'] = accepted;
      });
    }
  }

  // Update recipe in collection
  Future<void> _updateRecipeInCollection(Recipe recipe,
      {required bool saved}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference collectionRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeCollection');

      String? newRefKey;

      if (_recipeCollection.containsKey(recipe.id)) {
        // Update existing entry
        await collectionRef.child(_recipeCollection[recipe.id]['key']).update({
          'saved': saved,
          'timestamp': ServerValue.timestamp,
        });
      } else if (saved) {
        // Create new entry only if saving
        DatabaseReference newRef = collectionRef.push();
        newRefKey = newRef.key;
        await newRef.set({
          'id': recipe.id,
          'name': recipe.name,
          'saved': true,
          'timestamp': ServerValue.timestamp,
        });
      }

      // Update local state
      setState(() {
        if (!saved) {
          _recipeCollection[recipe.id]?['saved'] = false;
        } else {
          _recipeCollection[recipe.id] = {
            'key': _recipeCollection[recipe.id]?['key'] ?? newRefKey,
            'name': recipe.name,
            'saved': true,
            'timestamp': ServerValue.timestamp,
          };
        }
        _savedRecipes[_currentIndex] = saved;
      });
    }
  }

  // Go to next recipe
  void _nextRecipe() {
    if (_currentIndex < _recipes.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  // Go to previous recipe
  void _previousRecipe() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  // Remove recipe from weekly menu
  Future<void> _removeRecipe(int index) async {
    Recipe recipeToRemove = _recipes[index];
    try {
      await _updateRecipeInWeeklyMenu(recipeToRemove.id, accepted: false);

      setState(() {
        _recipes.removeAt(index);
        _savedRecipes.removeAt(index);
        if (_currentIndex >= _recipes.length) {
          _currentIndex = _recipes.length - 1;
        }
      });

      if (_recipes.isEmpty && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NoWeeklyMenuScreen()),
        );
      }
    } catch (e) {
      print('Error removing recipe: $e');
      // Optionally show an error message to the user
    }
  }

  // Toggle saved state of recipe
  void _toggleSavedRecipe(int index) async {
    Recipe currentRecipe = _recipes[index];
    bool newSavedState = !_savedRecipes[index];

    try {
      await _updateRecipeInCollection(currentRecipe, saved: newSavedState);
    } catch (e) {
      print('Error toggling saved recipe: $e');
      // Optionally show an error message to the user
    }
  }

  // Clear all recipes from weekly menu
  Future<void> _clearAllRecipes() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu');

      try {
        for (var recipeId in _recipeWeeklyMenu.keys) {
          await ref.child(_recipeWeeklyMenu[recipeId]['key']).update({
            'accepted': false,
            'timestamp': ServerValue.timestamp,
          });
        }

        setState(() {
          _recipes.clear();
          _savedRecipes.clear();
          for (var recipeId in _recipeWeeklyMenu.keys) {
            _recipeWeeklyMenu[recipeId]['accepted'] = false;
          }
        });

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NoWeeklyMenuScreen()),
          );
        }
      } catch (e) {
        print('Error clearing all recipes: $e');
        // Optionally show an error message to the user
      }
    }
  }

  // Show dialog to confirm clearing all recipes
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
                            "My Meal Plan",
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GroceryListScreen()),
              );
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
