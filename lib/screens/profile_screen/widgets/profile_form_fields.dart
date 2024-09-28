import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'custom_text_field.dart';
import 'phone_number_field.dart';
import 'budget_field.dart';
import 'height_weight_field.dart';
import 'dropdown_field.dart';

class ProfileFormFields extends StatelessWidget {
  final Function(String?) onDietaryPreferenceChanged;
  final Function(String?) onDietaryRestrictionsChanged;
  final String? dietaryPreference;
  final String? dietaryRestrictions;

  const ProfileFormFields({
    Key? key,
    required this.onDietaryPreferenceChanged,
    required this.onDietaryRestrictionsChanged,
    this.dietaryPreference,
    this.dietaryRestrictions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomTextField(labelText: "Preferred Name"),
        const SizedBox(height: 16),
        const PhoneNumberField(labelText: "Phone Number"),
        const SizedBox(height: 16),
        const BudgetField(labelText: "Budget"),
        const SizedBox(height: 16),
        const HeightWeightField(labelText: "Height", unit: "CM"),
        const SizedBox(height: 16),
        const HeightWeightField(labelText: "Weight", unit: "KG"),
        const SizedBox(height: 16),
        const HeightWeightField(labelText: "Excepted Weight", unit: "KG"),
        const SizedBox(height: 16),
        const CustomTextField(
            labelText: "Home District", isLocationField: true),
        const SizedBox(height: 16),
        DropdownField(
          labelText: "Dietary Preference",
          currentValue: dietaryPreference,
          items: const ['Classic', 'Vegan', 'Vegetarian'],
          onChanged: onDietaryPreferenceChanged,
        ),
        const SizedBox(height: 16),
        DropdownField(
          labelText: "Dietary Restrictions",
          currentValue: dietaryRestrictions,
          items: const [
            'None',
            'Dairy',
            'Eggs',
            'Fish',
            'Nuts',
            'Shellfish',
            'Soy'
          ],
          onChanged: onDietaryRestrictionsChanged,
        ),
      ],
    );
  }
}
