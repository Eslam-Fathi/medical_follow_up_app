import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/app_icons.dart';
import 'package:medical_follow_up_app/core/utils/colors.dart';

class SearchAndFilterRow extends StatelessWidget {
  const SearchAndFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search follow-up checks',
              prefixIcon:  Icon(AppIcons.search),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: HealtecColors.textSecondary.withOpacity(
                  theme.brightness == Brightness.dark ? 0.7 : 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          width: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: open filter sheet
            },
            child:  Icon(
              AppIcons.filter,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
