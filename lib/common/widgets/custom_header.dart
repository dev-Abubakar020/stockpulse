import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  const CustomHeading({
    super.key,
    required this.title,
     this.actionText,
     this.onPressed,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onPressed;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:12,bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme
                .of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          if (actionText != null)
            InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}




//SectionHeader(
//   title: 'Recent Sales',
//   actionText: 'See All',
//   onActionTap: () {},
// )