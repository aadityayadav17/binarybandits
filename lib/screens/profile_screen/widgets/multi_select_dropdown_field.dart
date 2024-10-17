import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MultiSelectDropdownField extends StatefulWidget {
  final String labelText;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const MultiSelectDropdownField({
    super.key,
    required this.labelText,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  MultiSelectDropdownFieldState createState() =>
      MultiSelectDropdownFieldState();
}

class MultiSelectDropdownFieldState extends State<MultiSelectDropdownField> {
  bool _isDropdownOpen = false;
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(MultiSelectDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != oldWidget.selectedItems) {
      setState(() {
        _selectedItems = List.from(widget.selectedItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double proportionalFontSize(double size) => size * screenWidth / 375;
    double proportionalHeight(double size) => size * screenHeight / 812;
    double proportionalWidth(double size) => size * screenWidth / 375;

    return Container(
      width: proportionalWidth(300),
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
            widget.labelText,
            style: GoogleFonts.roboto(
              fontSize: proportionalFontSize(14),
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
                  fontSize: proportionalFontSize(16),
                  color: const Color(0xFF000000),
                ),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: proportionalWidth(16)),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: proportionalHeight(24),
                                      width: proportionalWidth(24),
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
                                    SizedBox(width: proportionalWidth(16)),
                                    Text(
                                      item,
                                      style: GoogleFonts.roboto(
                                        fontSize: proportionalFontSize(16),
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
                  width: proportionalWidth(24),
                  height: proportionalHeight(24),
                ),
                iconSize: proportionalWidth(24),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: proportionalHeight(200),
                width: proportionalWidth(268),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(proportionalWidth(10)),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: Radius.circular(proportionalWidth(40)),
                  thickness: WidgetStateProperty.all(proportionalWidth(6)),
                  thumbVisibility: WidgetStateProperty.all(true),
                ),
              ),
              menuItemStyleData: MenuItemStyleData(
                height: proportionalHeight(40),
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
