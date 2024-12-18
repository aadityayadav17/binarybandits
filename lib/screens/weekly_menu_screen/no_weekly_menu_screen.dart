/// A stateless widget that represents the screen displayed when there are no
/// recipes in the weekly meal plan. The screen includes an app bar with a
/// back button, a message indicating that no recipes are selected, and a
/// bottom navigation bar for navigating between different sections of the app.
///
/// The screen is divided into the following sections:
/// - AppBar: Contains a back button.
/// - Body: Displays a message indicating that no recipes are selected and
///   prompts the user to add recipes.
/// - BottomNavigationBar: Allows navigation to Home, Recipe Selection,
///   Grocery List, and Weekly Menu screens.
///
/// The widget uses the `GoogleFonts` package for custom fonts and
/// `MediaQuery` to adapt the layout to different screen sizes.
library no_weekly_menu_screen;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';

class NoWeeklyMenuScreen extends StatelessWidget {
  const NoWeeklyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      letterSpacing: 0,
                      height: 0.9,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '0',
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
            SizedBox(height: screenHeight * 0.3),
            Center(
              child: Column(
                children: [
                  Text(
                    'You have no recipes in the Meal Plan!',
                    style: GoogleFonts.robotoFlex(
                      textStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Go to Home to add recipes!',
                    style: GoogleFonts.robotoFlex(
                      textStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Weekly Menu is selected
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const RecipeSelectionScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GroceryListScreen()),
              );
              break;
            case 3:
              // Already on Weekly Menu screen
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
