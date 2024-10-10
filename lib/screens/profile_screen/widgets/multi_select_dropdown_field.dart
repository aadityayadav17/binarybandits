import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MultiSelectDropdownField extends StatefulWidget {
  final String labelText;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const MultiSelectDropdownField({
    Key? key,
    required this.labelText,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MultiSelectDropdownFieldState createState() =>
      _MultiSelectDropdownFieldState();
}

class _MultiSelectDropdownFieldState extends State<MultiSelectDropdownField> {
  bool _isDropdownOpen = false;
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

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
            widget.labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              hint: Text(
                _selectedItems.isEmpty
                    ? 'Select Options'
                    : _selectedItems.join(', '),
                style: GoogleFonts.roboto(
                    fontSize: 16, color: const Color(0xFF000000)),
                overflow: TextOverflow.ellipsis,
              ),
              items: widget.items
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: StatefulBuilder(
                          builder: (context, menuSetState) {
                            final isSelected = _selectedItems.contains(item);
                            return InkWell(
                              onTap: () {
                                if (isSelected) {
                                  _selectedItems.remove(item);
                                } else {
                                  _selectedItems.add(item);
                                }
                                setState(() {});
                                menuSetState(() {});
                                widget.onChanged(_selectedItems);
                              },
                              child: Container(
                                height: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    // Replacing the icon-based checkboxes with actual checkboxes
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          if (value == true) {
                                            _selectedItems.add(item);
                                          } else {
                                            _selectedItems.remove(item);
                                          }
                                          setState(() {});
                                          menuSetState(() {});
                                          widget.onChanged(_selectedItems);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      item,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ))
                  .toList(),
              onMenuStateChange: (isOpen) {
                setState(() {
                  _isDropdownOpen = isOpen;
                });
              },
              iconStyleData: IconStyleData(
                icon: Image.asset(
                  _isDropdownOpen
                      ? 'assets/icons/screens/profile_screen/dropdown-off-display.png'
                      : 'assets/icons/screens/profile_screen/dropdown-on-display.png',
                  width: 24,
                  height: 24,
                ),
                iconSize: 24,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                width: 268,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.zero,
              ),
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
