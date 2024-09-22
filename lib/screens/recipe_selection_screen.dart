import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts package

class RecipeSelectionScreen extends StatelessWidget {
  const RecipeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme, // Apply Roboto Flex font globally
        ),
      ),
      home: Scaffold(
        // Set background color for Scaffold body
        backgroundColor:
            const Color(0xFFF5F5F5), // Body background color: #B4B4B4
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          toolbarHeight: 60,
          leading: IconButton(
            icon: Image.asset(
              'assets/icons/screens/recipe_selection_screen/back-key.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Discover and Recipe Texts with 4 and Selected on new lines
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Discover\nRecipe",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 36, // Slightly larger
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "4", // Or dynamically set this value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          "Selected",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Stack(
                  clipBehavior: Clip.none, // Allows the overlapping effect
                  alignment: Alignment.center, // Centers the stack items
                  children: [
                    // Image Card
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.9, // Set width for alignment
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20), // To match the card
                          child: Image.asset(
                            'assets/examples/screens/recipe_selection_screen/AlmondMilkPorridge.jpeg',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Recipe Information Card slightly overlapping the image card
                    Positioned(
                      top: 170, // This makes the card overlap the image by 50px
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            0.9, // Same width for alignment
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjusted for more rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon Row (Easy, Time, Price)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildIconText(
                                      'assets/icons/screens/recipe_selection_screen/cooking-difficulty-easy.png',
                                      'Easy',
                                    ),
                                    _buildIconText(
                                      'assets/icons/screens/recipe_selection_screen/time-clock.png',
                                      '20 min',
                                    ),
                                    _buildIconText(
                                      'assets/icons/screens/recipe_selection_screen/price.png',
                                      'Price',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Calories & Protein Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildIconText(
                                      'assets/icons/screens/recipe_selection_screen/calories.png',
                                      'XX Calories',
                                    ),
                                    _buildIconText(
                                      'assets/icons/screens/recipe_selection_screen/protein.png',
                                      'XX Protein',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Recipe Name
                                const Text(
                                  'Recipe Name Recipe Name',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Recipe Name Recipe Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 220), // Add spacing to push the buttons down

                // Done Button and Add/Remove Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Remove button with background
                    _buildActionIconWithBackground(
                      'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                      'assets/icons/screens/recipe_selection_screen/recipe-rejected.png',
                    ),

                    // Done Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle Done action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Done'),
                    ),

                    // Add button with background
                    _buildActionIconWithBackground(
                      'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                      'assets/icons/screens/recipe_selection_screen/recipe-accepted.png',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white, // Set background to plain white
          type: BottomNavigationBarType
              .fixed, // Ensures equal spacing for all items
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
                'assets/icons/bottom_navigation/grocery-list-on.png',
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

  // Helper method to build the icon with text below it
  Widget _buildIconText(String iconPath, String text,
      [double? width, double? height]) {
    // Set default width and height to 30 if not provided
    double iconWidth = width ?? 24;
    double iconHeight = height ?? 24;

    return Column(
      children: [
        Image.asset(
          iconPath,
          width: iconWidth,
          height: iconHeight,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Helper method to build the icon with a background rectangle and hard alignment
  Widget _buildActionIconWithBackground(
      String backgroundPath, String iconPath) {
    return Stack(
      children: [
        // Rectangle background (60x60)
        Image.asset(
          backgroundPath,
          width: 60,
          height: 60,
        ),
        // Foreground icon (24x24) with hard alignment using Positioned
        Positioned(
          top: 15, // Adjust the top value to align vertically
          left: 15, // Adjust the left value to align horizontally
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}
