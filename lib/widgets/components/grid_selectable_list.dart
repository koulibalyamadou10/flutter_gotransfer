import 'package:flutter/material.dart';

class GridSelectableItem {
  final String text;
  final String asset;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  GridSelectableItem({
    required this.text,
    required this.asset,
    this.leadingIcon,
    this.trailingIcon,
  });
}

class GridSelectableList extends StatefulWidget {
  final List<GridSelectableItem> items;
  final ValueChanged<int>? onItemSelected;
  final Color selectedColor;
  final Color? unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final double itemPadding;
  final double spacing;
  final double borderRadius;
  final int crossAxisCount;
  final double aspectRatio;
  final bool shrinkWrap;

  GridSelectableList({
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
    this.crossAxisCount = 2,
    this.aspectRatio = 1.2,
    this.shrinkWrap = true,
  });

  @override
  State<GridSelectableList> createState() => _GridSelectableListState();
}

class _GridSelectableListState extends State<GridSelectableList> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: widget.items.length,
      padding: EdgeInsets.all(widget.spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.spacing,
        mainAxisSpacing: widget.spacing,
        childAspectRatio: widget.aspectRatio,
      ),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = _selectedIndex == index;

        return Container(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onItemSelected?.call(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(widget.itemPadding),
              decoration: BoxDecoration(
                color: isSelected ? widget.selectedColor : widget.unselectedColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: isSelected ? widget.selectedColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: widget.selectedColor.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...[
                  Image.asset(item.asset, width: 75, height: 45),
                  const SizedBox(width: 6),
                ],
                  SizedBox(height: 20),
                  Text(
                    item.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? widget.selectedTextColor : widget.unselectedTextColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
