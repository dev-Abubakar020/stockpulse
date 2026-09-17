import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onScannerTap;
  final bool showScanner;
  final bool readOnly;
  final FocusNode? focusNode;

  const CustomSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onTap,
    this.onScannerTap,
    this.showScanner = false,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium,

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.45),
        ),

        prefixIcon: Icon(
          Icons.search_rounded,
          size: 21,
          color: colorScheme.onSurface.withValues(alpha: 0.55),
        ),

        suffixIcon: showScanner
            ? IconButton(
          onPressed: onScannerTap,
          icon: Icon(
            Icons.qr_code_scanner_rounded,
            size: 21,
            color: colorScheme.primary,
          ),
        )
            : null,

        filled: true,
        fillColor: primary.withValues(alpha: .06),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}