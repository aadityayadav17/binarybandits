import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool isLocationField;
  final Function(String) onChanged;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.isLocationField = false,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
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
          TextField(
            style: GoogleFonts.roboto(fontSize: 16),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: isLocationField
                  ? const Icon(Icons.location_on,
                      color: Color.fromRGBO(2, 2, 2, 1))
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
            ),
          ),
        ],
      ),
    );
  }
}
