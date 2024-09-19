import 'package:flutter/material.dart';

class RecipeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back button
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Discover Recipe",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                "4 Selected",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
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
                        _buildIconText(Icons.sentiment_satisfied, 'Easy'),
                        _buildIconText(Icons.timer, '20 min'),
                        _buildIconText(Icons.attach_money, 'Price'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Calories & Protein Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconText(Icons.restaurant_menu, 'XX Calories'),
                        _buildIconText(Icons.fitness_center, 'XX Protein'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Recipe Name
                    Text(
                      'Recipe Name Recipe Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Recipe Name Recipe Name',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text('Done'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Add/Remove Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionIcon(Icons.close, Colors.red),
                _buildActionIcon(Icons.add, Colors.green),
              ],
            ),
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
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  // Helper method to build the icon with text below it
  Widget _buildIconText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.green),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Helper method to build add/remove action buttons
  Widget _buildActionIcon(IconData icon, Color color) {
    return IconButton(
      icon: Icon(icon, color: color),
      iconSize: 40,
      onPressed: () {
        // Handle icon action
      },
    );
  }
}
