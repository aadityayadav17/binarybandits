import 'package:flutter/material.dart';
import 'package:binarybandits/screens/home_screen.dart';

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
              // Action for Grocery List button
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
              'assets/icons/bottom_navigation/home-off.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/discover-recipe-on.png',
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
              'assets/icons/bottom_navigation/weekly-menu-off.png',
              width: 24,
              height: 24,
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
}
