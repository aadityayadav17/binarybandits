import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/grocery_list_screen/no_grocery_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _database = FirebaseDatabase.instance.ref();

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

class GroceryListScreen extends StatefulWidget {
  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  String selectedTab = "All";
  bool cheapestOption = false;
  Map<int, bool> _selectedIngredients = {};
  List<String> removedStores = [];
  List<Map<String, dynamic>> ingredientPrices = [];
  String? _userBudget;
  Map<int, bool> _showIngredientName = {};
  Map<String, List<String>> storeProductNames = {
    'Coles': [],
    'Woolworths': [],
    'Aldi': [],
  };

  @override
  void initState() {
    super.initState();
    _loadProductData();
    _fetchUserBudget(); // Fetch the user's budget
  }

  Future<void> _fetchUserBudget() async {
    User? user = _auth.currentUser; // Get the currently authenticated user

    if (user == null) {
      return;
    }

    DatabaseReference userBudgetRef =
        _database.child('users/${user.uid}/budget');
    final snapshot = await userBudgetRef.get();

    if (snapshot.exists) {
      setState(() {
        _userBudget =
            snapshot.value.toString(); // Convert the value to a String
      });
    } else {
      setState(() {
        _userBudget = 'No budget set'; // Handle if there's no budget set
      });
    }
  }

  Future<List<String>> _fetchAcceptedIngredients() async {
    User? user = _auth.currentUser;

    if (user == null) {
      return [];
    }

    List<String> acceptedIngredients = [];
    DatabaseReference ingredientsRef =
        _database.child('users/${user.uid}/ingredients');
    DatabaseReference weeklyMenuRef =
        _database.child('users/${user.uid}/recipeWeeklyMenu');

    final ingredientsSnapshot = await ingredientsRef.once();
    final weeklyMenuSnapshot = await weeklyMenuRef.once();

    if (ingredientsSnapshot.snapshot.value == null ||
        weeklyMenuSnapshot.snapshot.value == null) {
      print('No data found in ingredients or weekly menu');
      return [];
    }

    final ingredientsData =
        ingredientsSnapshot.snapshot.value as Map<dynamic, dynamic>?;
    final weeklyMenuData =
        weeklyMenuSnapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (ingredientsData != null && weeklyMenuData != null) {
      ingredientsData.forEach((key, value) {
        // Step 1: Check if the ingredient itself is accepted
        if (value['accepted'] == true) {
          Map<dynamic, dynamic> ingredientRecipes = value['recipes'] ?? {};

          // Step 2: Check if any recipe linked to this ingredient is accepted in the recipeWeeklyMenu
          bool shouldAccept = ingredientRecipes.keys.any((recipeId) {
            print(
                'Checking recipe ID $recipeId for ingredient ${value['name']}');

            // Check the recipeWeeklyMenu for the recipe's "id" field instead of using the key directly
            bool recipeFoundAndAccepted =
                weeklyMenuData.values.any((weeklyMenuEntry) {
              return weeklyMenuEntry['id'] == recipeId &&
                  weeklyMenuEntry['accepted'] == true;
            });

            if (recipeFoundAndAccepted) {
              print('Recipe $recipeId is accepted in weekly menu.');
              return true;
            } else {
              print(
                  'Recipe $recipeId is not accepted or not found in weekly menu.');
              return false;
            }
          });

          // Step 3: If a valid recipe is accepted, add the ingredient to the accepted list
          if (shouldAccept) {
            acceptedIngredients.add(value['name']);
            print('Ingredient ${value['name']} accepted.');
          } else {
            print('Ingredient ${value['name']} skipped (no accepted recipe).');
          }
        } else {
          print(
              'Ingredient ${value['name']} skipped (ingredient not accepted).');
        }
      });
    }

    return acceptedIngredients;
  }

  Future<void> _loadProductData() async {
    final String response =
        await rootBundle.loadString('assets/recipes/products/products.json');
    final data = await json.decode(response);

    // Fetch accepted ingredients from Firebase after checking the recipeWeeklyMenu
    List<String> acceptedIngredients = await _fetchAcceptedIngredients();

    List<Map<String, dynamic>> filteredProducts = [];

    for (var product in data['products']) {
      String ingredientName = product['ingredient_name'];

      // Only add products that match the accepted ingredients from Firebase
      if (acceptedIngredients.contains(ingredientName)) {
        filteredProducts.add(product);
      }
    }

    if (filteredProducts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NoGroceryListScreen()),
        );
      });
      return;
    }

    // Sort and update the UI with filtered products
    filteredProducts.sort((a, b) => a['ingredient_name']
        .toString()
        .toLowerCase()
        .compareTo(b['ingredient_name'].toString().toLowerCase()));

    setState(() {
      ingredientPrices = filteredProducts;
      _selectedIngredients.clear();
      for (var product in ingredientPrices) {
        _selectedIngredients[ingredientPrices.indexOf(product)] = false;
        storeProductNames['Coles']!.add(product['coles']['product_name']);
        storeProductNames['Woolworths']!
            .add(product['woolworths']['product_name']);
        storeProductNames['Aldi']!.add(product['aldi']['product_name']);
      }
    });
  }

// Since the prices are stored as Strings, just return the string values as they are
  String formatPrice(double? price) {
    if (price == null) {
      return "None"; // or another placeholder for unavailable prices
    }
    return "\$${price.toStringAsFixed(2)}"; // Display price with two decimal points
  }

  String formatProductName(String? productName, String ingredientName) {
    if (productName == null || productName.toLowerCase() == "none") {
      return "No Product Available for $ingredientName";
    }
    return productName;
  }

  double calculateTotalCheapestCost() {
    double totalCost = 0.0;

    for (var product in ingredientPrices) {
      double? colesPrice =
          removedStores.contains("Coles") ? null : product['coles']['price'];
      double? woolworthsPrice = removedStores.contains("Woolworths")
          ? null
          : product['woolworths']['price'];
      double? aldiPrice =
          removedStores.contains("Aldi") ? null : product['aldi']['price'];

      // Get the lowest price among the available stores
      double? lowestPrice = [colesPrice, woolworthsPrice, aldiPrice]
          .where((price) => price != null)
          .reduce((a, b) => a! < b! ? a : b);

      // Add the lowest price to the total cost
      if (lowestPrice != null) {
        totalCost += lowestPrice;
      }
    }

    return totalCost;
  }

  double calculateTotalHighestCost() {
    double totalCost = 0.0;

    for (var product in ingredientPrices) {
      double? colesPrice =
          removedStores.contains("Coles") ? null : product['coles']['price'];
      double? woolworthsPrice = removedStores.contains("Woolworths")
          ? null
          : product['woolworths']['price'];
      double? aldiPrice =
          removedStores.contains("Aldi") ? null : product['aldi']['price'];

      // Get the highest price among the available stores
      double? highestPrice = [colesPrice, woolworthsPrice, aldiPrice]
          .where((price) => price != null)
          .reduce((a, b) => a! > b! ? a : b);

      // Add the highest price to the total cost
      if (highestPrice != null) {
        totalCost += highestPrice;
      }
    }

    return totalCost;
  }

  // Function to calculate the total cost for a specific store
  double calculateTotalCostForStore(String store) {
    double totalCost = 0.0;

    for (var product in ingredientPrices) {
      double? storePrice = product[store.toLowerCase()]['price'];

      if (storePrice != null) {
        totalCost += storePrice;
      }
    }

    return totalCost;
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: proportionalWidth(context, 16),
              top: proportionalHeight(context, 10),
              bottom:
                  proportionalHeight(context, 0), // Reduced the bottom padding
            ),
            child: Text(
              "Grocery List",
              style: GoogleFonts.robotoFlex(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: proportionalFontSize(context, 32),
                height: 0.9,
              ),
            ),
          ),
// Cheapest Switch Row
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: proportionalWidth(context, 16)),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Right align the row contents
              children: [
                Text(
                  "Cheapest",
                  style: GoogleFonts.robotoFlex(
                    fontSize: proportionalFontSize(context, 12), // Smaller text
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: proportionalWidth(
                      context, 6), // Smaller space between text and switch
                ),
                Transform.scale(
                    scale: 0.7, // Further reduce the size of the switch
                    child: Switch(
                      value: cheapestOption,
                      onChanged: selectedTab == "All"
                          ? (value) {
                              setState(() {
                                cheapestOption = value;
                              });
                            }
                          : null, // Disable the switch for individual tabs
                      activeColor: const Color.fromRGBO(
                          73, 160, 120, 1), // Set the active color
                    )),
              ],
            ),
          ),
          SizedBox(
              height: proportionalHeight(
                  context, 0)), // Add some spacing after the switch row
          // Store Filter Tabs Row
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: proportionalWidth(context, 16)),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align the tabs to the right
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .end, // Ensure tabs are right-aligned inside
                    children: [
                      _buildFilterTab("All", context),
                      if (!removedStores.contains("Coles"))
                        _buildStoreTab("Coles", context),
                      if (!removedStores.contains("Woolworths"))
                        _buildStoreTab("Woolworths", context),
                      if (!removedStores.contains("Aldi"))
                        _buildStoreTab("Aldi", context),
                      if (removedStores.isNotEmpty)
                        _buildPlusTab(
                            context), // Add the plus tab if stores are removed
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: proportionalHeight(context, 16)),
          Expanded(
            child: _buildGroceryList(),
          ),
          buildInfoBox(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Build store tabs with long-press functionality for removal
  Widget _buildStoreTab(String store, BuildContext context) {
    return GestureDetector(
      onLongPress: () =>
          _showRemoveStoreDialog(store), // Handle long press to remove store
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedTab = store;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedTab == store
                ? const Color.fromRGBO(73, 160, 120, 1)
                : Colors.white,
            foregroundColor: selectedTab == store ? Colors.white : Colors.black,
            elevation: 0,
            side: BorderSide(color: Colors.black.withOpacity(0.2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            padding: EdgeInsets.symmetric(
              horizontal: proportionalWidth(context, 8),
              vertical: proportionalHeight(context, 4),
            ),
          ),
          child: Text(
            store,
            style: GoogleFonts.robotoFlex(
              fontSize: proportionalFontSize(context, 12),
            ),
          ),
        ),
      ),
    );
  }

  // Build the "plus" tab for re-adding removed stores
  Widget _buildPlusTab(BuildContext context) {
    return GestureDetector(
      onTap: _showReAddStoreDialog, // Show the dialog to re-add stores
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: null, // Disabled button appearance
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: proportionalWidth(context, 8),
              vertical: proportionalHeight(context, 4),
            ),
          ),
          child: Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  // Method to show confirmation dialog for removing a store
  void _showRemoveStoreDialog(String store) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.height * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Are you sure you want to remove $store?",
                    style: GoogleFonts.robotoFlex(
                      textStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.robotoFlex(
                            textStyle: TextStyle(
                              color: Color.fromRGBO(73, 160, 120, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            removedStores.add(store);
                            if (selectedTab == store)
                              selectedTab =
                                  "All"; // Switch back to "All" if the removed tab was selected
                          });
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          backgroundColor:
                              const Color.fromRGBO(73, 160, 120, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'Remove',
                          style: GoogleFonts.robotoFlex(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to show a dialog to re-add a removed store
  void _showReAddStoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Re-add a Store",
                    style: GoogleFonts.robotoFlex(
                      textStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Column(
                  children: removedStores.map((store) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            store,
                            style: GoogleFonts.robotoFlex(
                              textStyle: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              removedStores.remove(store);
                            });
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        Divider(
                          color: const Color.fromRGBO(
                              73, 160, 120, 1), // Add the green divider
                          thickness: 1,
                          height: 1,
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.robotoFlex(
                            textStyle: TextStyle(
                              color: Color.fromRGBO(73, 160, 120, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function for smaller filter tabs
  Widget _buildFilterTab(String label, BuildContext context) {
    bool isSelected =
        selectedTab == label; // Check if this tab is the selected one

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 2.0), // Smaller padding between tabs
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTab = label; // Update selected tab when this tab is clicked
            if (selectedTab != "All") {
              cheapestOption =
                  false; // Ensure the cheapest option is turned off when a specific store is selected
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromRGBO(
                  73, 160, 120, 1) // Active tab background color
              : Colors.white, // Inactive tab background color
          foregroundColor: isSelected
              ? Colors.white // Active tab text color
              : Colors.black, // Inactive tab text color
          elevation: 0,
          side: BorderSide(
            color: isSelected
                ? Colors.transparent // No border for the active tab
                : Colors.black.withOpacity(0.2), // Border for inactive tabs
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(
            horizontal: proportionalWidth(
                context, 8), // Adjust padding inside the button
            vertical: proportionalHeight(
                context, 4), // Reduce vertical height of the button
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.robotoFlex(
            fontSize: proportionalFontSize(
                context, 12), // Match text size to "Cheapest"
          ),
        ),
      ),
    );
  }

  // Helper method to build the grocery list
  Widget _buildGroceryList() {
    return ListView.builder(
      itemCount: ingredientPrices.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedIngredients[index] ?? false;
        return Column(
          children: [
            _buildGroceryListItem(index, isSelected),
            _buildDivider(),
          ],
        );
      },
    );
  }

// Helper method to build the grocery list item
  Widget _buildGroceryListItem(int index, bool isSelected) {
    String itemLabel = _getItemLabel(index);

    // Check if the ingredient name should be displayed (based on long press)
    if (_showIngredientName[index] ?? false) {
      itemLabel =
          ingredientPrices[index]['ingredient_name']; // Display ingredient name
    }

    if (selectedTab == "All") {
      double? colesPrice = removedStores.contains("Coles")
          ? null
          : ingredientPrices[index]['coles']['price'];
      double? woolworthsPrice = removedStores.contains("Woolworths")
          ? null
          : ingredientPrices[index]['woolworths']['price'];
      double? aldiPrice = removedStores.contains("Aldi")
          ? null
          : ingredientPrices[index]['aldi']['price'];

      double? lowestPrice = [colesPrice, woolworthsPrice, aldiPrice]
          .where((price) => price != null)
          .reduce((a, b) => a! < b! ? a : b);

      return GestureDetector(
        onLongPress: () {
          setState(() {
            _showIngredientName[index] = !(_showIngredientName[index] ?? false);
          });
        },
        child: _buildListTile(
          index,
          itemLabel,
          isSelected,
          _buildAllTabPriceDisplay(index, lowestPrice, colesPrice,
              woolworthsPrice, aldiPrice, isSelected),
        ),
      );
    } else {
      String displayedPrice = formatPrice(
          ingredientPrices[index][selectedTab.toLowerCase()]['price']);

      return GestureDetector(
        onLongPress: () {
          setState(() {
            _showIngredientName[index] = !(_showIngredientName[index] ?? false);
          });
        },
        child: _buildListTile(
          index,
          itemLabel,
          isSelected,
          _buildIndividualTabPriceDisplay(displayedPrice),
        ),
      );
    }
  }

  String _getItemLabel(int index) {
    if (selectedTab == "All") {
      // In the All tab, display ingredient names when cheapestOption is off
      if (!cheapestOption) {
        return ingredientPrices[index]['ingredient_name'];
      } else {
        double? colesPrice = removedStores.contains("Coles")
            ? null
            : ingredientPrices[index]['coles']['price'];
        double? woolworthsPrice = removedStores.contains("Woolworths")
            ? null
            : ingredientPrices[index]['woolworths']['price'];
        double? aldiPrice = removedStores.contains("Aldi")
            ? null
            : ingredientPrices[index]['aldi']['price'];

        double? lowestPrice = [colesPrice, woolworthsPrice, aldiPrice]
            .where((price) => price != null)
            .reduce((a, b) => a! < b! ? a : b);

        if (lowestPrice == colesPrice) {
          return ingredientPrices[index]['coles']['product_name'];
        } else if (lowestPrice == woolworthsPrice) {
          return ingredientPrices[index]['woolworths']['product_name'];
        } else if (lowestPrice == aldiPrice) {
          return ingredientPrices[index]['aldi']['product_name'];
        }
      }
    } else {
      // For individual store tabs, display the product name or fallback message
      return formatProductName(
          ingredientPrices[index][selectedTab.toLowerCase()]['product_name'],
          ingredientPrices[index]['ingredient_name']);
    }

    // Default return in case none of the conditions above are met
    return "Unknown Product"; // or any other fallback value
  }

// Helper method to build the list tile
  Widget _buildListTile(
      int index, String itemLabel, bool isSelected, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0), // Reduce vertical padding between items
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              _selectedIngredients[index] = !isSelected;
            });
          },
          child: Icon(
            isSelected
                ? Icons.check_circle
                : Icons.radio_button_unchecked, // Checkmark or empty circle
            color: isSelected
                ? const Color.fromRGBO(
                    73, 160, 120, 1) // Active color for checkmark
                : Colors.grey,
            size: proportionalFontSize(context, 24),
          ),
        ),
        title: Text(
          '$itemLabel', // Dynamically display the label based on the selected tab
          style: GoogleFonts.robotoFlex(
            fontSize: proportionalFontSize(
                context, 14), // Smaller font size for ingredients
            color: isSelected
                ? Colors.grey
                : Colors.black, // Grey out text when checked
            decoration: isSelected
                ? TextDecoration.lineThrough
                : null, // Strikethrough when checked
          ),
          maxLines: null, // Allows text to wrap to a new line if necessary
          overflow:
              TextOverflow.visible, // Ensures text is visible when wrapped
        ),
        trailing: trailing,
      ),
    );
  }

// Helper method to build price display for the "All" tab
  Widget _buildAllTabPriceDisplay(
      int index,
      double? lowestPrice,
      double? colesPrice,
      double? woolworthsPrice,
      double? aldiPrice,
      bool isSelected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!removedStores.contains("Coles"))
          _buildPriceColumn(colesPrice, lowestPrice, isSelected),
        SizedBox(width: 10),
        if (!removedStores.contains("Woolworths"))
          _buildPriceColumn(woolworthsPrice, lowestPrice, isSelected),
        SizedBox(width: 10),
        if (!removedStores.contains("Aldi"))
          _buildPriceColumn(aldiPrice, lowestPrice, isSelected),
      ],
    );
  }

// Helper method to build price display for individual tabs
  Widget _buildIndividualTabPriceDisplay(String displayedPrice) {
    return Text(
      displayedPrice, // Display the price for the selected store
      style: const TextStyle(color: Colors.grey), // Price is always grey
    );
  }

// Helper method to build the price column (highlighting the cheapest price in black if applicable)
  // Example in _buildPriceColumn where the price is displayed
  Widget _buildPriceColumn(
      double? storePrice, double? lowestPrice, bool isSelected) {
    return SizedBox(
      width: proportionalWidth(context, 50), // Fixed width for store price
      child: Text(
        formatPrice(storePrice),
        style: TextStyle(
          color: isSelected
              ? Colors.grey
              : (cheapestOption && lowestPrice == storePrice
                  ? Colors.black
                  : Colors
                      .grey), // Highlight the cheapest price in black unless selected
        ),
        textAlign: TextAlign.end, // Align to the right for consistency
      ),
    );
  }

// Helper method to build a divider between list items
  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade400, // Blunt line between items
      thickness: 1, // Thickness of the divider
      height: 1, // Reduce the gap around the divider
      indent: 16, // Padding on the left side of the divider
      endIndent: 16, // Padding on the right side of the divider
    );
  }

  // Method for the rounded rectangle information box
  // Method for the rounded rectangle information box
  Widget buildInfoBox(BuildContext context) {
    int totalItems =
        ingredientPrices.length; // Get the total number of items dynamically

    // Calculate the total cost based on the selected tab and the cheapest toggle
    double totalCost = cheapestOption
        ? calculateTotalCheapestCost() // Use the cheapest items' total when the toggle is on
        : selectedTab == "All"
            ? calculateTotalCheapestCost() // Use cheapest items' total for "All" tab
            : calculateTotalCostForStore(
                selectedTab); // Use specific store's total cost for individual store tabs

    double budget = _userBudget != null
        ? double.tryParse(_userBudget!) ?? 0.0
        : 150.0; // Use user's budget or default to $150
    double savings =
        budget - totalCost; // Calculate savings as "budget - total cost"

    return Container(
      margin:
          EdgeInsets.only(bottom: 0), // Align with the bottom navigation bar
      child: ClipRRect(
        // Clip the blur effect to the rounded corners
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(proportionalWidth(context, 10)),
          topRight: Radius.circular(proportionalWidth(context, 10)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: proportionalHeight(context, 16),
              horizontal: proportionalWidth(context, 16),
            ),
            decoration: BoxDecoration(
              color: Colors.white, // Semi-transparent for frosted effect
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(proportionalWidth(context, 24)),
                topRight: Radius.circular(proportionalWidth(context, 24)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3), // Subtle shadow
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Offset for the shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total $totalItems items', // Display the total number of items
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${totalCost.toStringAsFixed(2)}', // Display the calculated total cost
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: proportionalHeight(context, 8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your budget', // Budget label
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${budget.toStringAsFixed(2)}', // Display the user's budget or a default
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: proportionalHeight(context, 8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SAVE', // Action label
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${savings.toStringAsFixed(2)}', // Display the calculated savings
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
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
            // Action for Grocery List button
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
            'assets/icons/bottom_navigation/grocery-list-on.png',
            width: proportionalWidth(context, 26),
            height: proportionalHeight(context, 26),
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
    );
  }
}
