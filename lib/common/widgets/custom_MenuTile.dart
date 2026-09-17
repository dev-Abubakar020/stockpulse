import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;
  final Color? color; // Added optional color property

  const MoreMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
    this.color, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    // Primary color defaults to dark slate if null, or custom color (e.g. Colors.red)
    final primaryColor = color ?? const Color(0xFF1E293B);

    // Background color defaults to light green, or red with opacity if custom color is provided
    final backgroundColor = color != null
        ? color!.withOpacity(0.1)
        : const Color(0xFFE8F5E9);

    // Icon color defaults to dark green, or uses the custom primary color
    final iconColor = color ?? const Color(0xFF1B5E3A);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
                // Chevron Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: color ?? const Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 66, right: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF1F5F9),
            ),
          ),
      ],
    );
  }
}