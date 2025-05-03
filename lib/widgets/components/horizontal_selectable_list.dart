import 'package:flutter/material.dart';

class HorizontalSelectableItem {
  final String text;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  HorizontalSelectableItem({
    required this.text,
    this.leadingIcon,
    this.trailingIcon,
  });
}

class HorizontalSelectableList extends StatefulWidget {
  final List<HorizontalSelectableItem> items;
  final ValueChanged<int>? onItemSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final double itemPadding;
  final double spacing;
  final double borderRadius;
  final bool shrinkWrap;

  const HorizontalSelectableList({
    super.key,
    required this.items,
    this.onItemSelected,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    this.itemPadding = 12.0,
    this.spacing = 8.0,
    this.borderRadius = 8.0,
    this.shrinkWrap = false,
  });

  @override
  State<HorizontalSelectableList> createState() => _HorizontalSelectableListState();
}

class _HorizontalSelectableListState extends State<HorizontalSelectableList> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: widget.shrinkWrap ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = _selectedIndex == index;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onItemSelected?.call(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(widget.itemPadding),
                decoration: BoxDecoration(
                  color: isSelected ? widget.selectedColor : widget.unselectedColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: isSelected ? widget.selectedColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: widget.selectedColor.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.leadingIcon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconTheme(
                          data: IconThemeData(
                            color: isSelected ? widget.selectedTextColor
                                : widget.unselectedTextColor,
                            size: 20,
                          ),
                          child: item.leadingIcon!,
                        ),
                      ),
                    ],
                    Text(
                      item.text,
                      style: TextStyle(
                        color: isSelected ? widget.selectedTextColor
                            : widget.unselectedTextColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (item.trailingIcon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconTheme(
                          data: IconThemeData(
                            color: isSelected ? widget.selectedTextColor
                                : widget.unselectedTextColor,
                            size: 20,
                          ),
                          child: item.trailingIcon!,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Méthode pour récupérer l'index sélectionné
  int? get selectedIndex => _selectedIndex;

  // Méthode pour récupérer l'item sélectionné
  HorizontalSelectableItem? get selectedItem {
    return _selectedIndex != null ? widget.items[_selectedIndex!] : null;
  }
}