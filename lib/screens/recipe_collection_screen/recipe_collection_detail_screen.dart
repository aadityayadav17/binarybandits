/// A screen that displays the details of a selected recipe from the recipe collection.
///
/// This screen allows users to view detailed information about a recipe, add it to their weekly menu,
/// and navigate to other screens using the bottom navigation bar.
///
/// The screen uses proportional sizing for various UI elements to ensure responsiveness across different
/// screen sizes.
///
/// The screen also interacts with Firebase to check if the recipe is already in the user's weekly menu
/// and to add the recipe to the weekly menu and history.
///
/// The screen consists of the following main components:
/// - An app bar with a back button.
/// - A scrollable body that displays the recipe details and an "Add to My Menu" button.
/// - A bottom navigation bar for navigating to other screens.
///
/// The screen uses the following helper functions for proportional sizing:
/// - `proportionalWidth`: Calculates the proportional width based on the screen width.
/// - `proportionalHeight`: Calculates the proportional height based on the screen height.
/// - `proportionalFontSize`: Calculates the proportional font size based on the screen width.
///
/// The screen uses the following main methods:
/// - `initState`: Initializes the state and checks if the recipe is in the weekly menu.
/// - `_checkRecipeInWeeklyMenu`: Checks if the recipe is in the user's weekly menu in Firebase.
/// - `_addToMenu`: Adds the recipe to the user's weekly menu and history in Firebase.
///
/// The screen uses the following main widgets:
/// - `RecipeCardStack`: Displays a stack of recipe cards.
/// - `RecipeInformationCard`: Displays detailed information about the recipe.
/// - `ElevatedButton`: A button to add the recipe to the weekly menu.
///
/// The screen uses the following main properties:
/// - `recipe`: The recipe to display details for.
/// - `addedToMenu`: A boolean indicating whether the recipe has been added to the weekly menu.
/// - `_scrollController`: A scroll controller for the scrollable body.
library recipe_collection_detail_screen;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_collection_screen/widgets/recipe_card_component.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_information_card.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Proportional helper functions
double proportionalWidth(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

double proportionalHeight(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.height / 812;
}

double proportionalFontSize(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

class RecipeCollectionDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeCollectionDetailScreen({super.key, required this.recipe});

  @override
  RecipeCollectionDetailScreenState createState() =>
      RecipeCollectionDetailScreenState();
}

class RecipeCollectionDetailScreenState
    extends State<RecipeCollectionDetailScreen> {
  bool addedToMenu = false; // Initially false
  final ScrollController _scrollController = ScrollController();

  // Check if the recipe is in the weekly menu
  @override
  void initState() {
    super.initState();
    _checkRecipeInWeeklyMenu(); // Check if the recipe is in the menu
  }

  // Check if the recipe is in the weekly menu
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
            addedToMenu =
                true; // Set addedToMenu to true if recipe is found and accepted
          });
          break;
        }
      }
    } else {}
  }

  // Add the recipe to the weekly menu and history
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
      print('Error adding recipe to menu and history: $e');
    }
  }

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
                              "Saved Recipes",
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
