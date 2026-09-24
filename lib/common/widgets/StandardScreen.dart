import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';
import 'ambientglow.dart';

class CustomScreen extends StatelessWidget {
  const CustomScreen({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.backgroundColor,
    this.glowColor,
    this.showAmbientBackground = true,
    this.safeArea = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? glowColor;

  final bool showAmbientBackground;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLG,
            vertical: AppConstants.spaceLG,
          ),
      child: body,
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor:
      backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,

      appBar: appBar,

      body: Stack(
        children: [
          if (showAmbientBackground && glowColor != null)
            Positioned.fill(
              child: AmbientBackground(
                glowColor: glowColor!,
              ),
            ),

          content,
        ],
      ),

      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}