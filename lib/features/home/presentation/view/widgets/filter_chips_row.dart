import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class FilterChipsRow extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;

  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(
              right: index == filters.length - 1 ? 0 : 8,
            ),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: selected,
              selectedColor: HealthCareColors.primary,
              backgroundColor: theme.cardColor,
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : (theme.brightness == Brightness.dark
                        ? HealthCareColors.darkTextPrimary
                        : HealthCareColors.textPrimary),
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selected
                      ? Colors.transparent
                      : (theme.brightness == Brightness.dark
                          ? HealthCareColors.darkBorder
                          : HealthCareColors.borderLight),
                ),
              ),
              onSelected: (_) => onFilterSelected(index),
            ),
          );
        },
      ),
    );
  }
}
