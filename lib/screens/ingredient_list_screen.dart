import 'package:flutter/material.dart';

class IngredientListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ingredient List',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Recipe Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecipeTab('All', true),
                  _buildRecipeTab('Recipe 1', false),
                  _buildRecipeTab('Recipe 2', false),
                  _buildRecipeTab('Recipe 3', false),
                ],
              ),
            ),
          ),
          // Add all button and item count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Add all ingredients to grocery list logic
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add all'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                  ),
                ),
                Text(
                  '10 Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Ingredients List
          Expanded(
            child: ListView.builder(
              itemCount: 10, // dynamic based on your ingredient list
              itemBuilder: (context, index) {
                return _buildIngredientCard();
              },
            ),
          ),
          // Add to Grocery List button
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Add selected ingredients to grocery list
              },
              child: Text('Add to Grocery List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildRecipeTab(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Change selected tab logic
        },
        child: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green[400] : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  Widget _buildIngredientCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.green),
            onPressed: () {
              // Add single ingredient to grocery list logic
            },
          ),
          title: Text('Ingredient name'),
          trailing: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Text(''),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (int index) {
        // Handle tab switching
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.kitchen),
          label: 'Recipes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Grocery List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'Notes',
        ),
      ],
      selectedItemColor: Colors.green[400],
      unselectedItemColor: Colors.grey[600],
    );
  }
}
