import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? dietaryPreference = 'Classic';
  String? dietaryRestrictions = 'None';

  String _selectedCountryCode = '+61'; // Default country code
  final TextEditingController _preferredNameController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _exceptWeightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme, // Apply Roboto Flex font globally
        ),
      ),
      home: Scaffold(
        backgroundColor:
            const Color.fromRGBO(239, 250, 244, 1), // Updated background color
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(
              239, 250, 244, 1), // Match the background color
          elevation: 0,
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Profile heading aligned left
            children: [
              const SizedBox(height: 10),
              const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 24),

              // Centered Fields
              Center(
                  child:
                      _buildField("Preferred Name", _preferredNameController)),
              const SizedBox(height: 16),

              // Phone Number with Country Code Picker
              Center(
                  child: _buildPhoneNumberField(
                      "Phone Number", _phoneNumberController)),
              const SizedBox(height: 16),

              Center(child: _buildLabeledField("Budget", _budgetController)),
              const SizedBox(height: 16),

              Center(
                  child: _buildCompositionField("Body Composition",
                      _heightController, _weightController)),
              const SizedBox(height: 16),

              Center(
                  child: _buildLabeledField(
                      "Except Weight (KG)", _exceptWeightController,
                      keyboardType: TextInputType.number)),
              const SizedBox(height: 16),

              Center(
                  child: _buildField("Home District", _locationController,
                      isLocationField: true)),
              const SizedBox(height: 16),

              Center(
                  child: _buildDropDown("Dietary Preference", dietaryPreference,
                      ['Classic', 'Vegan', 'Keto'], (String? value) {
                setState(() {
                  dietaryPreference = value;
                });
              })),
              const SizedBox(height: 16),

              Center(
                  child: _buildDropDown(
                      "Dietary Restrictions",
                      dietaryRestrictions,
                      ['None', 'Gluten-Free', 'Dairy-Free'], (String? value) {
                setState(() {
                  dietaryRestrictions = value;
                });
              })),
              const SizedBox(height: 24),

              // Centered Save Button
              Center(
                child: SizedBox(
                  width: 300, // Center and reduce width
                  child: ElevatedButton(
                    onPressed: () {
                      // Save profile logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.robotoFlex(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Space for the floating Save button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(
      String labelText, TextEditingController controller) {
    return Container(
      width: 300, // Adjust width of the container
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
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          const SizedBox(height: 4), // Adjust spacing between label and inputs
          Row(
            children: [
              // Country Code Picker with a Small Rectangle for Country Code
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 0), // Reduced padding
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF979797), // Border color
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: CountryCodePicker(
                  onChanged: (countryCode) {
                    setState(() {
                      _selectedCountryCode = countryCode.dialCode!;
                    });
                  },
                  initialSelection: 'IN', // Set default country
                  favorite: ['+91', 'IN'], // Favorites
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  textStyle:
                      GoogleFonts.roboto(fontSize: 14, color: Colors.black),
                  padding:
                      EdgeInsets.zero, // No padding inside country code picker
                ),
              ),
              const SizedBox(
                  width:
                      12), // Reduced spacing between country code picker and phone number

              // Phone number input field
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.roboto(fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8), // Adjust internal padding
                    hintText: 'Phone Number',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build labeled fields like Budget, Except Weight
  Widget _buildLabeledField(
    String labelText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: 300, // Adjust width of the container
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
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.roboto(fontSize: 16),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2), // Minimal padding
            ),
          ),
        ],
      ),
    );
  }

  // Method to build Body Composition with two text fields
  Widget _buildCompositionField(
      String labelText,
      TextEditingController heightController,
      TextEditingController weightController) {
    return Container(
      width: 300, // Adjust width of the container
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
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.roboto(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "CM",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2), // Minimal padding
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.roboto(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "KG",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2), // Minimal padding
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build the basic field with label and optional location icon
  Widget _buildField(
    String labelText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool isLocationField = false,
  }) {
    return Container(
      width: 300, // Adjust width of the container
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
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.roboto(fontSize: 16),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: isLocationField
                  ? const Icon(Icons.location_on, color: Colors.black54)
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ), // Ensure the icon is properly constrained
              contentPadding: const EdgeInsets.only(
                  top: 8, bottom: 8), // Minimal padding to align
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown(String labelText, String? currentValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: 300, // Adjust width of the container
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
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              isExpanded: true,
              onChanged: onChanged,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.roboto(fontSize: 16)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
