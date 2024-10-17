import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class BudgetField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller; // Add controller for budget input
  final Function(String) onChanged;

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
