/// A custom widget that displays a labeled input field for height or weight
/// with a specified unit. The input field is styled with proportional sizes
/// based on the screen dimensions.
///
/// The widget takes a label text, unit, a text editing controller, and a
/// callback function to handle changes in the input field.
///
/// Example usage:
/// ```dart
/// HeightWeightField(
///   labelText: 'Height',
///   unit: 'cm',
///   controller: heightController,
///   onChanged: (value) {
///     // Handle change
///   },
/// )
/// ```
///
/// Parameters:
/// - `labelText`: The text to display as the label for the input field.
/// - `unit`: The unit of measurement to display next to the input field.
/// - `controller`: The [TextEditingController] to manage the input field's text.
/// - `onChanged`: A callback function that is called when the input field's text changes.
library height_weight_field;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class HeightWeightField extends StatelessWidget {
  final String labelText;
  final String unit;
  final TextEditingController
      controller; // Add controller for height/weight input
  final Function(String) onChanged;

  // Add controller to constructor
  const HeightWeightField({
    super.key,
    required this.labelText,
    required this.unit,
    required this.controller, // Add controller as a required parameter
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
        color: Colors.white, // Overall white rectangle remains
        borderRadius: BorderRadius.circular(
            proportionalWidth(10)), // Proportional border radius
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
          SizedBox(height: proportionalHeight(8)),
          Row(
            children: [
              SizedBox(
                width: proportionalWidth(
                    30), // Proportional width for the TextField
                child: TextField(
                  controller: controller, // Attach the controller here
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: GoogleFonts.roboto(fontSize: proportionalFontSize(16)),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: proportionalHeight(4),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // Underline color
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromRGBO(
                            73, 160, 120, 1), // Underline color when focused
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: proportionalWidth(8)),
              Text(
                unit,
                style: GoogleFonts.roboto(
                  fontSize: proportionalFontSize(16),
                  color: const Color(0xFF979797),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
