import 'package:flutter/material.dart';

class RecipeSelectionScreen extends StatelessWidget {
  const RecipeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Discover and Recipe Texts with 4 and Selected on new lines
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Discover",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28, // Slightly larger
                      ),
                    ),
                    Text(
                      "Recipe",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Selected",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Spacer(flex: 2), // Add spacer to push the card down

            // Recipe Card
            Card(
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconText(
                            'assets/icons/screens/recipe_selection_screen/cooking-difficulty-easy.png',
                            'Easy'),
                        _buildIconText(
                            'assets/icons/screens/recipe_selection_screen/time-clock.png',
                            '20 min'),
                        _buildIconText(
                            'assets/icons/screens/recipe_selection_screen/price.png',
                            'Price'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Calories & Protein Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconText(
                            'assets/icons/screens/recipe_selection_screen/calories.png',
                            'XX Calories'),
                        _buildIconText(
                            'assets/icons/screens/recipe_selection_screen/protein.png',
                            'XX Protein'),
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

            const SizedBox(height: 16),

            // Done Button and Add/Remove Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionIcon(Icons.close, Colors.red),
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
                _buildActionIcon(Icons.add, Colors.green),
              ],
            ),

            const Spacer(flex: 1), // Adjust this as needed
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Add your missing icon here
            label: '',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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

  // Helper method to build the action icon
  Widget _buildActionIcon(IconData icon, Color color) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () {
        // Handle icon button press
      },
    );
  }
}
