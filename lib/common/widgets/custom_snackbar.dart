import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  CustomSnackBar._();

  // Hide current snackbar
  static void hideSnackBar() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  // Custom Toast
  static void customToast({required String message}) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withValues(alpha: 0.9),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  // Success
  static void successSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    hideSnackBar();
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      colorText: Colors.white,
      backgroundColor: const Color(0xFF4B68FF),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(20),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  // Warning
  static void warningSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    hideSnackBar();
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      colorText: Colors.white,
      backgroundColor: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(20),
      borderRadius: 12,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  // Error
  static void errorSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    hideSnackBar();
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      colorText: Colors.white,
      backgroundColor: Colors.red.shade600,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(20),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
