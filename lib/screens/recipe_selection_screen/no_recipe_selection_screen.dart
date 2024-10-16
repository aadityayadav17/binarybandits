import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:binarybandits/screens/recipe_overview_screen/recipe_overview_screen.dart';
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';

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

class NoRecipeSelectionScreen extends StatelessWidget {
  // Updated class name
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
                  "Discover\nRecipes",
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
                      'All',
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
                    'You have added all the recipes!',
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
                    'Please wait until new recipes are added.',
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
            SizedBox(
                height: screenHeight * 0.235), // Adjust this value as needed
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RecipeOverviewScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(proportionalWidth(context, 10)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: proportionalWidth(context, 70),
                    vertical: proportionalHeight(context, 12),
                  ),
                ),
                child: Text(
                  'Done',
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Meal Plan is selected
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              // Action for Discover Recipe button
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GroceryListScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WeeklyMenuScreen()),
              );
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
              'assets/icons/bottom_navigation/discover-recipe-on.png',
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
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
              'assets/icons/bottom_navigation/weekly-menu-off.png',
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
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
