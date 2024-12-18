/// A screen that displays detailed information about a selected recipe and allows
/// the user to add the recipe to their weekly menu.
///
/// The `RecipeSearchDetailScreen` is a stateful widget that shows detailed information
/// about a recipe. It provides functionality to check if the recipe is already in the
/// user's weekly menu and allows the user to add it if not.
///
/// The screen includes:
/// - An app bar with a back button.
/// - A scrollable body with recipe details.
/// - A button to add the recipe to the weekly menu.
/// - A bottom navigation bar for navigation between different screens.
///
/// The screen uses Firebase to check and update the user's weekly menu and recipe history.
///
/// Proportional methods are used to ensure the UI scales correctly on different screen sizes.
///
/// Properties:
/// - `recipe`: The recipe to display details for.
///
/// Methods:
/// - `proportionalWidth`: Calculates width proportional to the screen size.
/// - `proportionalHeight`: Calculates height proportional to the screen size.
/// - `proportionalFontSize`: Calculates font size proportional to the screen size.
/// - `_checkRecipeInWeeklyMenu`: Checks if the recipe is in the user's weekly menu.
/// - `_addToMenu`: Adds the recipe to the user's weekly menu and history.
///
/// State:
/// - `addedToMenu`: A boolean indicating if the recipe has been added to the weekly menu.
/// - `_scrollController`: A controller for the scrollable content.
library recipe_search_detail_screen;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_collection_screen/widgets/recipe_card_component.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_information_card.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Proportional methods (you can extract these into a utils file later)
double proportionalWidth(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

double proportionalHeight(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.height / 812;
}

double proportionalFontSize(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

class RecipeSearchDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeSearchDetailScreen({super.key, required this.recipe});

  @override
  RecipeSearchDetailScreenState createState() =>
      RecipeSearchDetailScreenState();
}

class RecipeSearchDetailScreenState extends State<RecipeSearchDetailScreen> {
  bool addedToMenu = false; // Initially false
  final ScrollController _scrollController = ScrollController();

  // Initialize the state
  @override
  void initState() {
    super.initState();
    _checkRecipeInWeeklyMenu(); // Check recipe status in Firebase
  }

  // Check if the recipe is in the user's weekly menu
  Future<void> _checkRecipeInWeeklyMenu() async {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    // Ensure the user is authenticated
    if (user == null) {
      return;
    }

    // Fetch the user's weekly menu from Firebase using dynamic user ID
    final userId = user.uid;
    final databaseRef =
        FirebaseDatabase.instance.ref("users/$userId/recipeWeeklyMenu");
    final snapshot = await databaseRef.get();

    // Check if the snapshot exists
    if (snapshot.exists) {
      final weeklyMenuData = snapshot.value as Map<dynamic, dynamic>;

      // Check if the current recipe is in the weekly menu and if it's accepted
      for (var entry in weeklyMenuData.values) {
        if (entry['id'] == widget.recipe.id && entry['accepted'] == true) {
          setState(() {
            addedToMenu = true; // Set to true if recipe is found and accepted
          });
          break;
        }
      }
    } else {}
  }

  // Add the recipe to the user's weekly menu and history
  Future<void> _addToMenu() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final userId = user.uid;
    final weeklyMenuRef =
        FirebaseDatabase.instance.ref("users/$userId/recipeWeeklyMenu");
    final historyRef =
        FirebaseDatabase.instance.ref("users/$userId/recipeHistory");

    try {
      // Check if the recipe already exists in the weekly menu
      final weeklyMenuSnapshot = await weeklyMenuRef
          .orderByChild('id')
          .equalTo(widget.recipe.id)
          .once();
      if (weeklyMenuSnapshot.snapshot.value != null) {
        // Update existing entry
        final existingEntries =
            weeklyMenuSnapshot.snapshot.value as Map<dynamic, dynamic>;
        final existingKey = existingEntries.keys.first;
        await weeklyMenuRef.child(existingKey).update({
          'accepted': true,
          'timestamp': ServerValue.timestamp,
        });
      } else {
        // Add new entry
        await weeklyMenuRef.push().set({
          'id': widget.recipe.id,
          'name': widget.recipe.name,
          'accepted': true,
          'timestamp': ServerValue.timestamp,
        });
      }

      // Check if the recipe already exists in the history
      final historySnapshot =
          await historyRef.orderByChild('id').equalTo(widget.recipe.id).once();
      if (historySnapshot.snapshot.value != null) {
        // Update existing entry
        final existingEntries =
            historySnapshot.snapshot.value as Map<dynamic, dynamic>;
        final existingKey = existingEntries.keys.first;
        await historyRef.child(existingKey).update({
          'accepted': true,
          'timestamp': ServerValue.timestamp,
        });
      } else {
        // Add new entry
        await historyRef.push().set({
          'id': widget.recipe.id,
          'name': widget.recipe.name,
          'accepted': true,
          'timestamp': ServerValue.timestamp,
        });
      }

      setState(() {
        addedToMenu = true;
      });
    } catch (e) {
      print(e);
    }
  }

  // Build the Recipe Search Detail Screen
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final cardTopPosition = screenHeight * 0.35; // Top position for the card
    final cardHeight = screenHeight * 0.24; // Height for the card

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        toolbarHeight: proportionalHeight(context, 60),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: proportionalWidth(context, 8)),
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/common/back-key.png',
              width: proportionalWidth(context, 24),
              height: proportionalHeight(context, 24),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight - proportionalHeight(context, 60),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: proportionalWidth(context, 16),
                      top: proportionalHeight(context, 10),
                      bottom: proportionalHeight(context, 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recipe Search",
                              style: GoogleFonts.robotoFlex(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: proportionalFontSize(context, 32),
                                  letterSpacing: 0,
                                  height: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RecipeCardStack(
                    recipe: widget.recipe,
                    screenWidth: screenWidth,
                    cardTopPosition: cardTopPosition,
                    cardHeight: cardHeight,
                    scrollController: ScrollController(),
                  ),
                ],
              ),
              RecipeInformationCard(
                key: ValueKey(widget.recipe.id),
                recipe: widget.recipe,
                topPosition: cardTopPosition + proportionalHeight(context, 30),
                cardHeight: cardHeight,
                scrollController: _scrollController,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              Positioned(
                top: cardTopPosition + proportionalHeight(context, 260),
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: addedToMenu ? null : _addToMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: addedToMenu
                            ? Colors.grey
                            : const Color.fromRGBO(73, 160, 120, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              proportionalWidth(context, 10)),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: proportionalHeight(context, 12),
                        ),
                      ),
                      child: SizedBox(
                        width: proportionalWidth(context, 320),
                        child: Text(
                          addedToMenu
                              ? 'Added to My Meal Plan'
                              : 'Add to My Meal Plan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: proportionalFontSize(context, 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroceryListScreen(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeeklyMenuScreen(),
                ),
              );
              break;
            default:
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/home-off.png',
              width: proportionalWidth(context, 24),
              height: proportionalHeight(context, 24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/discover-recipe-off.png',
              width: proportionalWidth(context, 22),
              height: proportionalHeight(context, 22),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/grocery-list-off.png',
              width: proportionalWidth(context, 24),
              height: proportionalHeight(context, 24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/weekly-menu-off.png',
              width: proportionalWidth(context, 24),
              height: proportionalHeight(context, 24),
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
