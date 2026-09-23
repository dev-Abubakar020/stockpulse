import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.centerTitle = false,
    this.isDarkIcons = true, // Choose light or dark status bar icons
  });

  final Widget? title;
  final bool showBackArrow;
  final bool centerTitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final bool isDarkIcons;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,

      // Explicitly set the status bar overlay to transparent
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkIcons ? Brightness.dark : Brightness.light,
        statusBarBrightness: isDarkIcons ? Brightness.light : Brightness.dark,
      ),

      automaticallyImplyLeading: false,
      leadingWidth: 56,

      leading: showBackArrow
          ? IconButton(
        onPressed: leadingOnPressed ?? () => Get.back(),
        icon: const Icon(Icons.arrow_back),
      )
          : leadingIcon != null
          ? IconButton(
        onPressed: leadingOnPressed,
        icon: Icon(leadingIcon),
      )
          : null,

      title: title,
      centerTitle: centerTitle,
      titleSpacing: showBackArrow || leadingIcon != null ? 0 : 16,
      actions: actions,
      actionsPadding: const EdgeInsets.only(right: 16),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}