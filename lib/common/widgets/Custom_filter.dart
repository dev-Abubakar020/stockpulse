import 'package:flutter/material.dart';

class CustomFilterTabs extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const CustomFilterTabs({
    super.key,
    required this.items,
     this.selectedIndex = 0,
     this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;

          return InkWell(
            onTap: onChanged != null ? () => onChanged!(index) : null,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? primary
                    : primary.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                items[index],
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}