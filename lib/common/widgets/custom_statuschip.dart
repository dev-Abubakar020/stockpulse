import 'package:flutter/material.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  neutral,
}

class CustomStatusChip extends StatelessWidget {
  const CustomStatusChip({
    super.key,
    required this.textTitle,
    this.type = StatusType.success,
  });

  final String textTitle;
  final StatusType type;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;

    switch (type) {
      case StatusType.success:
        color = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case StatusType.warning:
        color = const Color(0xFFEF6C00);
        bgColor = const Color(0xFFFFF3E0);
        break;
      case StatusType.error:
        color = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        break;
      case StatusType.info:
        color = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case StatusType.neutral:
        color = const Color(0xFF616161);
        bgColor = const Color(0xFFF5F5F5);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        textTitle,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
