import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/utils/app_constants.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final IconData icon;
  final Color iconColor;
  final bool? positive;
  final dynamic theme;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.iconColor,
    this.positive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on positive state, or fallback to neutral secondary color if null
    final changeColor = positive == null
        ? theme.textSecondary
        : (positive! ? theme.success : theme.error);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppConstants.reportIconBoxSize,
                height: AppConstants.reportIconBoxSize,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: AppConstants.iconLG,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSM),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMD),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          // Only show the percentage row if percentage text is provided
          if (percentage.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceSM),
            Row(
              children: [
                // Render the arrow icon only if positive is explicitly true or false
                if (positive != null) ...[
                  Icon(
                    positive!
                        ? CupertinoIcons.arrow_up_right
                        : CupertinoIcons.arrow_down_right,
                    size: AppConstants.iconXS,
                    color: changeColor,
                  ),
                  const SizedBox(width: AppConstants.spaceXS),
                ],
                Text(
                  percentage,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}