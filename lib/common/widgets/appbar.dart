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
    this.isDarkIcons = true,
    this.backgroundColor = Colors.transparent, // Default transparent
    this.elevation = 0,                         // Default 0
  });

  final Widget? title;
  final bool showBackArrow;
  final bool centerTitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final bool isDarkIcons;
  final Color backgroundColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,

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
      actionsPadding: const EdgeInsets.only(right: 16),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}