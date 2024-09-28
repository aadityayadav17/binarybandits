import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';

class PhoneNumberField extends StatelessWidget {
  final String labelText;

  const PhoneNumberField({Key? key, required this.labelText}) : super(key: key);

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
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF979797)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CountryCodePicker(
                  onChanged: (countryCode) {},
                  initialSelection: 'AU',
                  favorite: ['+61', 'AU'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  textStyle:
                      GoogleFonts.roboto(fontSize: 14, color: Colors.black),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                    _PhoneNumberFormatter(),
                  ],
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
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

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    String cleanText = text.replaceAll(RegExp(r'\D'), '');

    if (cleanText.length > 4 && cleanText.length <= 7) {
      cleanText = '${cleanText.substring(0, 4)} ${cleanText.substring(4)}';
    } else if (cleanText.length > 7 && cleanText.length <= 10) {
      cleanText =
          '${cleanText.substring(0, 4)} ${cleanText.substring(4, 7)} ${cleanText.substring(7)}';
    } else if (cleanText.length > 10 && cleanText.length <= 15) {
      cleanText =
          '${cleanText.substring(0, 4)} ${cleanText.substring(4, 7)} ${cleanText.substring(7, 10)} ${cleanText.substring(10)}';
    }

    return TextEditingValue(
      text: cleanText,
      selection: TextSelection.collapsed(offset: cleanText.length),
    );
  }
}