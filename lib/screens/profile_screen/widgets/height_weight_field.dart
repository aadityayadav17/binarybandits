import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class HeightWeightField extends StatelessWidget {
  final String labelText;
  final String unit;
  final Function(String) onChanged; // Add onChanged callback

  const HeightWeightField({
    Key? key,
    required this.labelText,
    required this.unit,
    required this.onChanged, // Make this parameter required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white, // Overall white rectangle remains
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: 30, // Set the width for the TextField
                child: TextField(
                  onChanged:
                      onChanged, // Connect the TextField onChanged to the widget's callback
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: GoogleFonts.roboto(fontSize: 16),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4), // Reduced padding
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
              const SizedBox(width: 8),
              Text(
                unit,
                style: GoogleFonts.roboto(
                    fontSize: 16, color: const Color(0xFF979797)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
