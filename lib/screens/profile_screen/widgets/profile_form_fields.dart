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
  final VoidCallback onAnyFieldChanged;
  final String? dietaryPreference;
  final List<String> dietaryRestrictions;
  final Function(String?) onNameValidated;

  const ProfileFormFields({
    Key? key,
    required this.onDietaryPreferenceChanged,
    required this.onDietaryRestrictionsChanged,
    required this.onAnyFieldChanged,
    this.dietaryPreference,
    required this.dietaryRestrictions,
    required this.onNameValidated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          labelText: "Preferred Name*",
          onChanged: (String? value) {
            onAnyFieldChanged();
            onNameValidated(value);
          },
        ),
        const SizedBox(height: 16),
        PhoneNumberField(
          labelText: "Phone Number",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),
        BudgetField(
          labelText: "Budget/Week",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),
        HeightWeightField(
          labelText: "Height",
          unit: "CM",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),
        HeightWeightField(
          labelText: "Weight",
          unit: "KG",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),
        HeightWeightField(
          labelText: "Expected Weight",
          unit: "KG",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: "Home District",
          isLocationField: true,
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),
        DropdownField(
          labelText: "Dietary Preference",
          currentValue: dietaryPreference,
          items: const ['No Preference', 'Vegan', 'Vegetarian'],
          onChanged: (value) {
            onDietaryPreferenceChanged(value);
            onAnyFieldChanged();
          },
        ),
        const SizedBox(height: 16),
        MultiSelectDropdownField(
          labelText: "Dietary Restrictions",
          items: const ['Dairy', 'Eggs', 'Fish', 'Nuts', 'Shellfish', 'Soy'],
          selectedItems: dietaryRestrictions,
          onChanged: (value) {
            onDietaryRestrictionsChanged(value);
            onAnyFieldChanged();
          },
        ),
      ],
    );
  }
}
