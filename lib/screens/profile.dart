import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? dietaryPreference = 'Classic';
  String? dietaryRestrictions = 'None';

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
            crossAxisAlignment: CrossAxisAlignment.start,
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

              // Preferred Name
              _buildField("Preferred Name", _preferredNameController),
              const SizedBox(height: 16),

              // Phone Number
              _buildField("Phone Number", _phoneNumberController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),

              // Budget
              _buildField("Budget", _budgetController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              // Body Height and Weight
              Row(
                children: [
                  Expanded(
                      child: _buildField("Body Height (CM)", _heightController,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildField("Body Weight (KG)", _weightController,
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),

              // Except Weight
              _buildField("Except Weight (KG)", _exceptWeightController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              // Home District with Location Search
              _buildField("Home District", _locationController,
                  isLocationField: true),
              const SizedBox(height: 16),

              // Dietary Preference
              _buildDropDown("Dietary Preference", dietaryPreference,
                  ['Classic', 'Vegan', 'Keto'], (String? value) {
                setState(() {
                  dietaryPreference = value;
                });
              }),
              const SizedBox(height: 16),

              // Dietary Restrictions
              _buildDropDown("Dietary Restrictions", dietaryRestrictions,
                  ['None', 'Gluten-Free', 'Dairy-Free'], (String? value) {
                setState(() {
                  dietaryRestrictions = value;
                });
              }),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
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
              const SizedBox(height: 40), // Space for the floating Save button
            ],
          ),
        ),
      ),
    );
  }

  // Single method to build the field with label on top
  Widget _buildField(
    String labelText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool isLocationField = false,
  }) {
    return Container(
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.roboto(fontSize: 16),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon:
                  isLocationField ? const Icon(Icons.location_on) : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown(String labelText, String? currentValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return Container(
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
