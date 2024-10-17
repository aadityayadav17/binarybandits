import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
  String selectedTab = "All"; // Default selected tab is "All"
  bool cheapestOption = false;
  Map<int, bool> _selectedIngredients = {};
  List<String> removedStores = [];
  List<dynamic> products = [];
  Map<int, bool> _expandedItems = {};
  int? _expandedIndex;
  Map<int, String> _manuallySelectedPrices = {};
  Map<int, bool> _showIngredientNames = {};
  Map<int, String?> _selectedStorePrices = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> acceptedIngredients = [];
  List<String> unavailableProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadAcceptedIngredients();
    await loadProducts();
    _matchProductsWithIngredients();
    setState(() {});
  }

  Future<void> _loadAcceptedIngredients() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DataSnapshot snapshot =
          await _database.child('users/${user.uid}/ingredients').get();
      if (snapshot.value != null) {
        Map<dynamic, dynamic> ingredients =
            snapshot.value as Map<dynamic, dynamic>;
        acceptedIngredients = ingredients.entries
            .where((entry) => entry.value['accepted'] == true)
            .map((entry) => Map<String, dynamic>.from(entry.value))
            .toList();
      }
    }
  }

// Since the prices are stored as Strings, just return the string values as they are
  String formatPrice(String price) {
    if (price == '' || price == 'NONE') return 'N/A';
    return '\$$price';
  }

  Future<void> loadProducts() async {
    final String response =
        await rootBundle.loadString('assets/recipes/products/products.json');
    final data = json.decode(response);
    products = data['products'];
    products.sort((a, b) => a['ingredient_name']
        .toString()
        .compareTo(b['ingredient_name'].toString()));
  }

  void _matchProductsWithIngredients() {
    List<dynamic> matchedProducts = [];
    for (var ingredient in acceptedIngredients) {
      var matchedProduct = products.firstWhere(
          (product) =>
              product['ingredient_name'].toLowerCase() ==
              ingredient['name'].toLowerCase(),
          orElse: () => null);

      if (matchedProduct != null) {
        matchedProducts.add({
          ...matchedProduct,
          'quantity': ingredient['quantity'],
          'unit': ingredient['unit']
        });
      } else {
        unavailableProducts.add(ingredient['name']);
      }
    }
    products = matchedProducts;

    // Initialize the selection and display states
    for (int i = 0; i < products.length; i++) {
      _selectedStorePrices[i] = null; // No store is selected by default
    }
  }

  Widget _buildGroceryList() {
    return ListView.builder(
      itemCount: products.length,
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

  Widget _buildUnavailableProductsDropdown() {
    if (unavailableProducts.isEmpty) return SizedBox.shrink();
    return ExpansionTile(
      title: Text('Products unavailable for:'),
      children: unavailableProducts
          .map((product) => ListTile(title: Text('• $product')))
          .toList(),
    );
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
                    onChanged: (value) {
                      setState(() {
                        cheapestOption = value;

                        // Reset all selected store prices if the toggle is turned off
                        if (!cheapestOption) {
                          _selectedStorePrices.clear();
                        }
                      });
                    },
                    activeColor: const Color.fromRGBO(
                        73, 160, 120, 1), // Set the active color
                  ),
                ),
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
          _buildUnavailableProductsDropdown(),
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

// Helper method to build the grocery list item
  Widget _buildGroceryListItem(int index, bool isSelected) {
    if (products.isEmpty) return Text('Loading...');

    final product = products[index];

    if (selectedTab == "All") {
      double? colesPrice = removedStores.contains("Coles")
          ? null
          : _parsePrice(product['coles']['price']);
      double? woolworthsPrice = removedStores.contains("Woolworths")
          ? null
          : _parsePrice(product['woolworths']['price']);
      double? aldiPrice =
          removedStores.contains("Aldi") || product['aldi']['price'] == "NONE"
              ? null
              : _parsePrice(product['aldi']['price']);

      List<double?> validPrices = [colesPrice, woolworthsPrice, aldiPrice]
          .where((price) => price != null && price > 0)
          .toList();

      if (validPrices.isNotEmpty) {
        return _buildListTile(
          index,
          _getItemLabel(index),
          isSelected,
          _buildAllTabPriceDisplay(
              index, colesPrice, woolworthsPrice, aldiPrice),
        );
      }
    } else {
      // Individual store tabs: Display product names and their prices
      String displayedPrice = selectedTab == "Coles"
          ? product['coles']['price'].toString()
          : selectedTab == "Woolworths"
              ? product['woolworths']['price'].toString()
              : product['aldi']['price'].toString();

      return _buildListTile(
        index,
        _getItemLabel(index),
        isSelected,
        _buildIndividualTabPriceDisplay(displayedPrice),
      );
    }

    return SizedBox.shrink(); // In case no valid product is found
  }

  double? _parsePrice(dynamic price) {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price);
    return null;
  }

  String _getItemLabel(int index) {
    if (products.isEmpty)
      return 'Loading...'; // Handle case when data is not loaded

    final product = products[index];
    final ingredientName = product['ingredient_name'];

    // Check if the user has long pressed to show the ingredient name
    bool showIngredientName = _showIngredientNames[index] ?? false;

    // If the user has long pressed, show the ingredient name
    if (showIngredientName) {
      return ingredientName;
    }

    // Get the manually selected store for this product (if any)
    String? selectedStore = _selectedStorePrices[index];

    // If no store has been manually selected and the cheapest toggle is on, select the cheapest product
    if (selectedStore == null && cheapestOption) {
      double? colesPrice = removedStores.contains("Coles")
          ? null
          : double.tryParse(product['coles']['price']);
      double? woolworthsPrice = removedStores.contains("Woolworths")
          ? null
          : double.tryParse(product['woolworths']['price']);
      double? aldiPrice =
          removedStores.contains("Aldi") || product['aldi']['price'] == "NONE"
              ? null
              : double.tryParse(product['aldi']['price']);

      List<double?> validPrices = [colesPrice, woolworthsPrice, aldiPrice]
          .where((price) => price != null && price > 0)
          .toList();

      if (validPrices.isNotEmpty) {
        double? lowestPrice = validPrices.reduce((a, b) => a! < b! ? a : b);

        // Automatically select the store with the lowest price and display its product name
        if (lowestPrice == colesPrice) {
          selectedStore = "Coles";
        } else if (lowestPrice == woolworthsPrice) {
          selectedStore = "Woolworths";
        } else if (lowestPrice == aldiPrice) {
          selectedStore = "Aldi";
        }

        // Update the state to reflect this auto-selection
        _selectedStorePrices[index] = selectedStore;

        // Return the product name of the cheapest store
        if (selectedStore == "Coles") {
          return product['coles']['product_name'];
        } else if (selectedStore == "Woolworths") {
          return product['woolworths']['product_name'];
        } else if (selectedStore == "Aldi") {
          return product['aldi']['product_name'];
        }
      }
    }

    // If a store has been manually selected, display its product name
    if (selectedStore == "Coles") {
      return product['coles']['product_name'];
    } else if (selectedStore == "Woolworths") {
      return product['woolworths']['product_name'];
    } else if (selectedStore == "Aldi") {
      return product['aldi']['product_name'];
    }

    // Default to ingredient name if no store is selected
    return ingredientName;
  }

  Widget _buildListTile(
      int index, String itemLabel, bool isSelected, Widget trailing) {
    bool isExpanded =
        _expandedItems[index] ?? false; // Check if the current item is expanded

    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0), // Reduce vertical padding between items
      child: GestureDetector(
        onLongPress: () {
          // Toggle between showing product name and ingredient name on long press
          setState(() {
            _showIngredientNames[index] =
                !(_showIngredientNames[index] ?? false); // Toggle the state
          });
        },
        onTap: () {
          // Toggle the expanded state on simple click
          setState(() {
            _expandedItems[index] =
                !(_expandedItems[index] ?? false); // Toggle expansion
          });
        },
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
            maxLines: isExpanded
                ? null
                : 2, // Show full text if expanded, otherwise limit to 2 lines
            overflow: isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis, // Show ellipsis if collapsed
          ),
          trailing: trailing,
        ),
      ),
    );
  }

  Widget _buildAllTabPriceDisplay(int index, double? colesPrice,
      double? woolworthsPrice, double? aldiPrice) {
    String? selectedStore =
        _selectedStorePrices[index]; // Get the manually selected store (if any)

    // If the cheapest option is enabled and no manual selection, auto-select the cheapest price
    if (cheapestOption && selectedStore == null) {
      double? lowestPrice = [colesPrice, woolworthsPrice, aldiPrice]
          .where((price) => price != null && price > 0)
          .reduce((a, b) => a! < b! ? a : b);

      // Automatically select the store with the lowest price
      if (lowestPrice == colesPrice) {
        selectedStore = "Coles";
      } else if (lowestPrice == woolworthsPrice) {
        selectedStore = "Woolworths";
      } else if (lowestPrice == aldiPrice) {
        selectedStore = "Aldi";
      }

      // Update the state to reflect this auto-selection
      _selectedStorePrices[index] = selectedStore;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coles price
        GestureDetector(
          onTap: () {
            setState(() {
              if (selectedStore == "Coles") {
                _selectedStorePrices[index] =
                    null; // Deselect if Coles was already selected
              } else {
                _selectedStorePrices[index] = "Coles"; // Select Coles
              }
            });
          },
          child: _buildPriceColumn(
            colesPrice,
            selectedStore == "Coles", // Show in black if selected
          ),
        ),
        SizedBox(width: 10), // Space between columns

        // Woolworths price
        GestureDetector(
          onTap: () {
            setState(() {
              if (selectedStore == "Woolworths") {
                _selectedStorePrices[index] =
                    null; // Deselect if Woolworths was already selected
              } else {
                _selectedStorePrices[index] = "Woolworths"; // Select Woolworths
              }
            });
          },
          child: _buildPriceColumn(
            woolworthsPrice,
            selectedStore == "Woolworths", // Show in black if selected
          ),
        ),
        SizedBox(width: 10), // Space between columns

        // Aldi price
        GestureDetector(
          onTap: () {
            setState(() {
              if (selectedStore == "Aldi") {
                _selectedStorePrices[index] =
                    null; // Deselect if Aldi was already selected
              } else {
                _selectedStorePrices[index] = "Aldi"; // Select Aldi
              }
            });
          },
          child: _buildPriceColumn(
            aldiPrice,
            selectedStore == "Aldi", // Show in black if selected
          ),
        ),
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

  Widget _buildPriceColumn(double? storePrice, bool isSelected) {
    return SizedBox(
      width: proportionalWidth(context, 50), // Fixed width for store price
      child: Text(
        formatPrice(storePrice?.toString() ?? ''),
        style: TextStyle(
          color: isSelected
              ? Colors.black
              : Colors.grey, // Black if selected, grey otherwise
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
  Widget buildInfoBox(BuildContext context) {
    int totalItems =
        products.length; // Dynamically get the total number of items

    return Container(
      margin:
          EdgeInsets.only(bottom: 0), // Align with the bottom navigation bar
      child: ClipRRect(
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
                      'Total $totalItems items', // Dynamically display total number of items
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$XXXXX', // Placeholder for total cost
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
                      '\$XXXXX', // Placeholder for budget
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
                      '\$XXXXX', // Placeholder for amount to be saved
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
