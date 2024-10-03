import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/recipe_selection_screen.dart';
import 'package:binarybandits/screens/profile_screen/profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
          elevation: 0,
          toolbarHeight: 96,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Logo
                  Container(
                    width: 140, // Adjust width here
                    height: 40, // Adjust height here
                    child: Image.asset(
                      'assets/images/app-logo.png', // App logo image path
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Profile Icon with Background Rectangle
                  GestureDetector(
                    onTap: () {
                      // Navigate to Profile Screen when profile icon is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProfileScreen(), // Replace with your ProfileScreen widget
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment
                          .center, // Centers the profile on the rectangle
                      children: [
                        // Rectangle background
                        Container(
                          width: 96, // Rectangle width
                          height: 96, // Rectangle height
                          child: Image.asset(
                            'assets/icons/screens/home_screen/background-rectangle.png', // Background rectangle image path
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Profile icon
                        Positioned(
                          top: 28,
                          left: 28,
                          child: Container(
                            width: 32, // Profile image width
                            height: 32, // Profile image height
                            child: Image.asset(
                              'assets/icons/screens/home_screen/profile.png', // Profile image path
                              fit: BoxFit.contain,
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
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Hello, USER!',
                  style: GoogleFonts.robotoFlex(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  'What do you want to eat?',
                  style: GoogleFonts.robotoFlex(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color.fromRGBO(73, 160, 120, 1),
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        30), // Adjusted borderRadius to make it flatter
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4), // Reduced vertical padding
                  child: Row(
                    children: [
                      // Custom Search Icon from Assets
                      Image.asset(
                        'assets/icons/screens/home_screen/search-button.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                          width:
                              8), // Space between the icon and the text field
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search for recipe',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Discover Recipe Button with Image Background
                _buildFeatureButton(
                  context,
                  'assets/images/home_screen/discover-recipe.png',
                  'DISCOVER\nRECIPE',
                  () {
                    // Navigate to RecipeSelectionScreen when Discover Recipe is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipeSelectionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Recipe Collection and Grocery List buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureButton(
                        context,
                        'assets/images/home_screen/recipe-collection.png',
                        'RECIPE\nCOLLECTION',
                        () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFeatureButton(
                        context,
                        'assets/images/home_screen/grocery-list.png',
                        'GROCERY\nLIST',
                        () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Weekly Menu and History Recipe buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureButton(
                        context,
                        'assets/images/home_screen/weekly-menu.png',
                        'WEEKLY\nMENU',
                        () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFeatureButton(
                        context,
                        'assets/images/home_screen/recipe-history.png',
                        'HISTORY\nRECIPE',
                        () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white, // Set background to plain white
          type: BottomNavigationBarType
              .fixed, // Ensures equal spacing for all items
          currentIndex: 0, // Default selected index (Home)
          onTap: (index) {
            switch (index) {
              case 0:
                // Action for Home button
                break;
              case 1:
                // Navigate to RecipeSelectionScreen when Grocery List button is clicked
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
                'assets/icons/bottom_navigation/home-on.png',
                width: 24,
                height: 24,
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
                'assets/icons/bottom_navigation/discover-recipe-off.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_navigation/weekly-menu-off.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
          ],
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }

  // Helper method to build buttons with background image and text overlay
  Widget _buildFeatureButton(
    BuildContext context,
    String imagePath,
    String text,
    VoidCallback onTap, // Add onTap callback
  ) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap callback when button is clicked
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),
          ),
          // White blur overlay for text
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Text over the blur
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoFlex(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const HomeScreen());
}
