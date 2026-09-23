import 'package:flutter/material.dart';
import '../theme/theme_helper.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final bool isSearching;
  final Widget? action;
  final double iconSize;
  final double topMargin;

  const EmptyStateWidget({
    super.key,
    this.isSearching = false,
    this.icon,
    this.title,
    this.subtitle,
    this.action,
    this.iconSize = 55.0,
    this.topMargin = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve icon with fallback logic
    final IconData effectiveIcon = icon ??
        (isSearching
            ? Icons.search_off_rounded
            : Icons.shopping_cart_outlined);

    // Resolve title with fallback logic
    final String effectiveTitle = title ??
        (isSearching ? 'No results found' : 'No items yet');

    // Resolve subtitle with fallback logic
    final String effectiveSubtitle = subtitle ??
        (isSearching
            ? 'Try changing your search terms or filters.'
            : 'Items you add or complete will appear here.');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: topMargin),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        // vertical: 50,
      ),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF131D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF1E2D44)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              effectiveIcon,
              size: iconSize,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              effectiveSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}