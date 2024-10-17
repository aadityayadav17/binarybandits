import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool isLocationField;
  final Function(String) onChanged;
  final TextEditingController? controller; // Add controller parameter

  const CustomTextField({
    super.key,
    required this.labelText,
    this.isLocationField = false,
    required this.onChanged,
    this.controller, // Add controller to constructor
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
          TextField(
            controller: controller, // Use controller in TextField
            style: GoogleFonts.roboto(fontSize: proportionalFontSize(16)),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: isLocationField
                  ? const Icon(Icons.location_on,
                      color: Color.fromRGBO(2, 2, 2, 1))
                  : null,
              suffixIconConstraints: BoxConstraints(
                minWidth: proportionalWidth(24),
                minHeight: proportionalHeight(24),
              ),
              contentPadding: EdgeInsets.only(
                top: proportionalHeight(8),
                bottom: proportionalHeight(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
