import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'phone_number_field.dart';
import 'budget_field.dart';
import 'height_weight_field.dart';
import 'dropdown_field.dart';
import 'multi_select_dropdown_field.dart';

class ProfileFormFields extends StatelessWidget {
  final Function(String?) onDietaryPreferenceChanged;
  final Function(List<String>) onDietaryRestrictionsChanged;
  final VoidCallback onAnyFieldChanged; // Add a general callback
  final String? dietaryPreference;
  final List<String> dietaryRestrictions;

  const ProfileFormFields({
    Key? key,
    required this.onDietaryPreferenceChanged,
    required this.onDietaryRestrictionsChanged,
    required this.onAnyFieldChanged, // Make sure this is passed in constructor
    this.dietaryPreference,
    required this.dietaryRestrictions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: CustomTextField(
                labelText: "Preferred Name",
                onChanged: (_) => onAnyFieldChanged())),
        const SizedBox(height: 16),
        Center(
            child: PhoneNumberField(
                labelText: "Phone Number",
                onChanged: (_) => onAnyFieldChanged())),
        const SizedBox(height: 16),
        Center(
            child: BudgetField(
                labelText: "Budget", onChanged: (_) => onAnyFieldChanged())),
        const SizedBox(height: 16),
        Center(
            child: HeightWeightField(
                labelText: "Height",
                unit: "CM",
                onChanged: (_) => onAnyFieldChanged())),
        const SizedBox(height: 16),
        Center(
            child: HeightWeightField(
                labelText: "Weight",
                unit: "KG",
                onChanged: (_) => onAnyFieldChanged())),
        const SizedBox(height: 16),
        Center(
            child: HeightWeightField(
                labelText: "Excepted Weight",
                unit: "KG",
                onChanged: (_) => onAnyFieldChanged())),
        const SizedBox(height: 16),
        Center(
            child: CustomTextField(
                labelText: "Home District",
                isLocationField: true,
                onChanged: (_) => onAnyFieldChanged())),
        const SizedBox(height: 16),
        Center(
          child: DropdownField(
            labelText: "Dietary Preference",
            currentValue: dietaryPreference,
            items: const ['Classic', 'Vegan', 'Vegetarian'],
            onChanged: (value) {
              onDietaryPreferenceChanged(value);
              onAnyFieldChanged();
            },
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: MultiSelectDropdownField(
            labelText: "Dietary Restrictions",
            items: const ['Dairy', 'Eggs', 'Fish', 'Nuts', 'Shellfish', 'Soy'],
            selectedItems: dietaryRestrictions,
            onChanged: (value) {
              onDietaryRestrictionsChanged(value);
              onAnyFieldChanged();
            },
          ),
        ),
      ],
    );
  }
}
