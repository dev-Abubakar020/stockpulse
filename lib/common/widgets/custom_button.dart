import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  final double borderRadius;
  final double? height;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.boxShadow,
    this.borderRadius = 14,
    this.height = 52,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClickable = !isLoading && !isDisabled && onPressed != null;

    final defaultGradient = LinearGradient(
      colors: [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final effectiveGradient = backgroundColor != null
        ? null
        : (gradient ?? defaultGradient);

    final effectiveBgColor =
        backgroundColor ??
        (effectiveGradient == null ? theme.colorScheme.primary : null);

    final textColor = foregroundColor ?? Colors.white;

    final effectiveShadow =
        boxShadow ??
        (isClickable && effectiveGradient != null
            ? [
                BoxShadow(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: isClickable ? textColor : textColor.withValues(alpha: 0.6),
          ),
        ),
        if (!isLoading && suffixIcon != null) ...[
          const SizedBox(width: 8),
          suffixIcon!,
        ],
      ],
    );

    return Container(
      width: fullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        color: effectiveGradient == null ? effectiveBgColor : null,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isClickable ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
