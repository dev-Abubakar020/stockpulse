import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar{
  static void hideSnackBar() => ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static void customToast({required message}){
    ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
            elevation: 0,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.transparent,
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.9),
              ),
              child: Center(
                child: Text(message,style: Theme.of(Get.context!).textTheme.labelLarge,),
              ),
            ))
    );
  }

  static void successSnackBar({required title, message='', duration=3}){
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Color(0xFF4b68ff),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(30),
      icon: const Icon(Icons.check, color: Colors.white,),

    );
  }
  static void warningSnackBar({required title, message=''}){
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(30),
      icon: const Icon(Icons.warning, color: Colors.white,),
    );
  }

  static void errorSnackBar({required title, message=''}){
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.red.shade600,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning, color: Colors.white,),
    );
  }
}