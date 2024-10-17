/// A custom widget that represents a budget input field with a label and a text field.
///
/// The `BudgetField` widget is designed to take a monetary input from the user. It includes
/// a label, a dollar sign prefix, and a text field for entering the budget amount. The text
/// field is controlled by a `TextEditingController` and allows only numeric input with a
/// maximum length of 5 digits.
///
/// The widget adjusts its size and font based on the screen dimensions to ensure a
/// responsive design.
///
/// ## Parameters:
///
/// - `labelText` (String): The text to display as the label for the budget field.
/// - `controller` (TextEditingController): The controller to manage the text input for the budget field.
/// - `onChanged` (Function(String)): A callback function that is called whenever the text in the field changes.
///
/// ## Example:
///
/// ```dart
/// BudgetField(
///   labelText: 'Enter Budget',
///   controller: _budgetController,
///   onChanged: (value) {
///     // Handle change in budget input
///   },
/// )
/// ```
///
/// ## Note:
///
/// The widget uses the `google_fonts` package to apply the Roboto font to the text elements.
library budget_field;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class BudgetField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller; // Add controller for budget input
  final Function(String) onChanged;

  // Update the constructor to include controller as a required parameter
  const BudgetField({
    super.key,
    required this.labelText,
    required this.controller, // Add controller as required parameter
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define proportional sizes based on screen dimensions
    double proportionalFontSize(double size) =>
        size * screenWidth / 375; // Assuming base screen width is 375
    double proportionalHeight(double size) =>
        size * screenHeight / 812; // Assuming base screen height is 812
    double proportionalWidth(double size) => size * screenWidth / 375;

    return Container(
      width: proportionalWidth(300), // Proportional width for the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(proportionalWidth(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: proportionalWidth(1),
            blurRadius: proportionalWidth(5),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: proportionalWidth(16),
        vertical: proportionalHeight(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: proportionalFontSize(14),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797),
            ),
          ),
          SizedBox(height: proportionalHeight(4)),
          Row(
            children: [
              Text(
                '\$',
                style: GoogleFonts.roboto(
                  fontSize: proportionalFontSize(16),
                  color: const Color(0xFF979797),
                ),
              ),
              SizedBox(width: proportionalWidth(8)),
              SizedBox(
                width: proportionalWidth(
                    50), // Proportional width for the underline
                child: TextField(
                  controller: controller, // Attach the controller here
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  style: GoogleFonts.roboto(fontSize: proportionalFontSize(16)),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: proportionalHeight(4),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromRGBO(73, 160, 120, 1),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromRGBO(73, 160, 120, 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
