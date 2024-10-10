import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';

class NoWeeklyMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/common/back-key.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Menu",
                  style: GoogleFonts.robotoFlex(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
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
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      "Selected",
                      style: GoogleFonts.robotoFlex(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 240),
            Center(
              child: Column(
                children: [
                  Text(
                    'You have no recipes in the Weekly Menu!',
                    style: GoogleFonts.robotoFlex(
                      textStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go to Home to add recipes!',
                    style: GoogleFonts.robotoFlex(
                      textStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
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
              // Action for Grocery List button
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
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/discover-recipe-off.png',
              width: 22,
              height: 22,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/grocery-list-off.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/weekly-menu-on.png',
              width: 26,
              height: 26,
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
