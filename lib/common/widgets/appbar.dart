// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const CustomAppBar({
//     super.key,
//     this.title,
//     this.actions,
//     this.leadingIcon,
//     this.leadingOnPressed,
//     this.showBackArrow = false,
//   });
//
//   final Widget? title;
//   final bool showBackArrow;
//   final IconData? leadingIcon;
//   final List<Widget>? actions;
//   final VoidCallback? leadingOnPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       leadingWidth: 56,
//       leading: showBackArrow
//           ? IconButton(
//         onPressed: () => Get.back(),
//         icon: const Icon(Icons.arrow_back),
//       )
//           : leadingIcon != null
//           ? IconButton(
//         onPressed: leadingOnPressed,
//         icon: Icon(leadingIcon),
//       )
//           : null,
//
//       title: title,
//
//       // When there is NO leading widget,
//       // title starts at standard 16px.
//       titleSpacing: showBackArrow || leadingIcon != null ? 0 : 16,
//
//       actions: actions,
//
//       // Material 3
//       actionsPadding: const EdgeInsets.only(right: 16),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

import 'package:flutter/material.dart';
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
  });

  final Widget? title;
  final bool showBackArrow;
  final bool centerTitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,

      leadingWidth: 56,

      leading: showBackArrow
          ? IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back),
      )
          : leadingIcon != null
          ? IconButton(
        onPressed: leadingOnPressed,
        icon: Icon(leadingIcon),
      )
          : null,

      title: title,

      // Left aligned by default
      centerTitle: centerTitle,

      // 16px from left when no leading widget
      titleSpacing: showBackArrow || leadingIcon != null ? 0 : 16,

      actions: actions,
      actionsPadding: const EdgeInsets.only(right: 16),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}