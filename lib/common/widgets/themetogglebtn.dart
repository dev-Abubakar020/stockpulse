
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/theme_helper.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Material(
      color: theme.card,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => ThemeController.to.toggleTheme(),
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.border, width: 1),
          ),
          child: Icon(
            theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: theme.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}