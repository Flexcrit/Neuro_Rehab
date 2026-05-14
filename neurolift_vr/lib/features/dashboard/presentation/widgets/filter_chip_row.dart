import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Horizontal scrollable row of filter chips for session filtering.
///
/// When a chip is tapped, it triggers the [onFilterChanged] callback
/// which the DashboardPage connects to [DashboardCubit.changeFilter].
class FilterChipRow extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChipRow({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const List<String> _filters = [
    'All',
    'Fruit Picking',
    'High Score',
    'Completed',
    'In Progress',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = _filters[index];
          final isActive = filter == activeFilter;

          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.chipSelected : AppColors.chipUnselected,
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(
                        color: AppColors.surfaceVariant,
                        width: 1,
                      ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
