import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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

  // Define product names for each store
  List<String> colesProductNames = [
    "Coles Product 1",
    "Coles Product 2",
    "Coles Product 3",
    // Add more product names...
  ];

  List<String> woolworthsProductNames = [
    "Woolworths Product 1",
    "Woolworths Product 2",
    "Woolworths Product 3",
    // Add more product names...
  ];

  List<String> aldiProductNames = [
    "Aldi Product 1",
    "Aldi Product 2",
    "Aldi Product 3",
    // Add more product names...
  ];

  @override
  void initState() {
    super.initState();
    loadProducts().then((loadedProducts) {
      setState(() {
        products = loadedProducts;
        products.sort((a, b) => a['ingredient_name']
            .toString()
            .compareTo(b['ingredient_name'].toString()));

        // Initialize the selection map
        for (int i = 0; i < products.length; i++) {
          _selectedIngredients[i] = false;
        }
        _expandedIndex = null; // No item is expanded initially
      });
    });
  }

  // Prices are now stored as Strings, not doubles
  List<Map<String, String>> ingredientPrices = [
    {"Coles": "10.00", "Woolworths": "12.49", "Aldi": "8.99"},
    {"Coles": "15.50", "Woolworths": "16.00", "Aldi": "14.75"},
    {"Coles": "120.99", "Woolworths": "220.00", "Aldi": "180.45"},
    // Add more items with prices for each store...
  ];

// Since the prices are stored as Strings, just return the string values as they are
  String formatPrice(String? price) {
    if (price == null || price.isEmpty) return "None";
    return "\$$price"; // Add the dollar sign before the price
  }

  Future<List<dynamic>> loadProducts() async {
    final String response =
        await rootBundle.loadString('assets/recipes/products/products.json');
    final data = json.decode(response);
    return data[
        'products']; // Ensure you are accessing the correct field for the product list
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
                        : null, // Disable for individual tabs
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
    // Ensure that the item count matches the number of products loaded from the JSON
    return ListView.builder(
      itemCount: products.length, // Use the length of the products list
      itemBuilder: (context, index) {
        bool isSelected = _selectedIngredients[index] ?? false;

        // Build the grocery list item for each product
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
    if (products.isEmpty) return Text('Loading...');

    final product = products[index];

    if (selectedTab == "All") {
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

        return _buildListTile(
          index,
          _getItemLabel(
              index), // Dynamically display the product name based on selection
          isSelected,
          _buildAllTabPriceDisplay(index, lowestPrice, colesPrice,
              woolworthsPrice, aldiPrice, isSelected),
        );
      }
    } else {
      // Individual store tabs: Display product names and their prices
      String displayedPrice = selectedTab == "Coles"
          ? product['coles']['price']
          : selectedTab == "Woolworths"
              ? product['woolworths']['price']
              : product['aldi']['price'];

      return _buildListTile(
        index,
        _getItemLabel(
            index), // Dynamically display the product name for the selected store
        isSelected,
        _buildIndividualTabPriceDisplay(displayedPrice),
      );
    }

    return SizedBox.shrink(); // In case no valid product is found
  }

  /// Helper method to get the item label (ingredient or product name)
  String _getItemLabel(int index) {
    if (products.isEmpty)
      return 'Loading...'; // Handle case when data is not loaded

    final product = products[index];
    final ingredientName = product['ingredient_name'];

    // Get the manually selected store for this product, if any
    String? manuallySelectedStore = _manuallySelectedPrices[index];

    if (selectedTab == "All") {
      if (manuallySelectedStore != null) {
        // If a store has been manually selected, show the product name from that store
        if (manuallySelectedStore == "Coles") {
          return product['coles']['product_name'];
        } else if (manuallySelectedStore == "Woolworths") {
          return product['woolworths']['product_name'];
        } else if (manuallySelectedStore == "Aldi") {
          return product['aldi']['product_name'];
        }
      } else if (cheapestOption) {
        // If no manual selection, find the cheapest product name based on price
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

          if (lowestPrice == colesPrice) {
            return product['coles']['product_name'];
          } else if (lowestPrice == woolworthsPrice) {
            return product['woolworths']['product_name'];
          } else if (lowestPrice == aldiPrice) {
            return product['aldi']['product_name'];
          }
        }
      }
      return ingredientName; // Default to ingredient name if no manual or cheapest selection
    } else if (selectedTab == "Coles" && !removedStores.contains("Coles")) {
      return product['coles']['product_name'];
    } else if (selectedTab == "Woolworths" &&
        !removedStores.contains("Woolworths")) {
      return product['woolworths']['product_name'];
    } else if (selectedTab == "Aldi" && !removedStores.contains("Aldi")) {
      return product['aldi']['product_name'];
    }

    return 'Product name $index'; // Fallback if no tab is selected
  }

// Helper method to build the list tile
  Widget _buildListTile(
      int index, String itemLabel, bool isSelected, Widget trailing) {
    bool isExpanded =
        _expandedIndex == index; // Check if the current item is expanded

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
        title: GestureDetector(
          onTap: () {
            // Toggle the expanded state when the user taps the item name
            setState(() {
              if (_expandedIndex == index) {
                // If the current item is already expanded, collapse it
                _expandedIndex = null;
              } else {
                // Otherwise, expand the new item and collapse the previous one
                _expandedIndex = index;
              }
            });
          },
          child: Text(
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
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildAllTabPriceDisplay(
      int index,
      double? lowestPrice,
      double? colesPrice,
      double? woolworthsPrice,
      double? aldiPrice,
      bool isSelected) {
    // Get the manually selected store for this product, if any
    String? manuallySelectedStore = _manuallySelectedPrices[index];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coles price, but only if Coles is not removed
        if (!removedStores.contains("Coles"))
          GestureDetector(
            onTap: () {
              // When user clicks on Coles price, manually select it
              setState(() {
                _manuallySelectedPrices[index] = "Coles";
              });
            },
            child: _buildPriceColumn(
                colesPrice,
                (manuallySelectedStore == "Coles") ||
                    (manuallySelectedStore == null &&
                        lowestPrice == colesPrice),
                isSelected),
          ),
        SizedBox(width: 10), // Space between columns

        // Woolworths price, but only if Woolworths is not removed
        if (!removedStores.contains("Woolworths"))
          GestureDetector(
            onTap: () {
              // When user clicks on Woolworths price, manually select it
              setState(() {
                _manuallySelectedPrices[index] = "Woolworths";
              });
            },
            child: _buildPriceColumn(
                woolworthsPrice,
                (manuallySelectedStore == "Woolworths") ||
                    (manuallySelectedStore == null &&
                        lowestPrice == woolworthsPrice),
                isSelected),
          ),
        SizedBox(width: 10), // Space between columns

        // Aldi price, but only if Aldi is not removed
        if (!removedStores.contains("Aldi"))
          GestureDetector(
            onTap: () {
              // When user clicks on Aldi price, manually select it
              setState(() {
                _manuallySelectedPrices[index] = "Aldi";
              });
            },
            child: _buildPriceColumn(
                aldiPrice,
                (manuallySelectedStore == "Aldi") ||
                    (manuallySelectedStore == null && lowestPrice == aldiPrice),
                isSelected),
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

  // Helper method to build the price column (highlighting the selected price in black)
  Widget _buildPriceColumn(
      double? storePrice, bool isSelectedStore, bool isSelected) {
    return SizedBox(
      width: proportionalWidth(context, 50), // Fixed width for store price
      child: Text(
        formatPrice(storePrice?.toString()),
        style: TextStyle(
          color: isSelected
              ? Colors.grey
              : (isSelectedStore
                  ? Colors.black
                  : Colors
                      .grey), // Highlight the selected store's price in black
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
