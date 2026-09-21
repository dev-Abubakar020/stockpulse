import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/route/app_routes.dart';
import '../utils/app_constants.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isChecking = false.obs;
  DateTime? _lastPressedAt;


  void changePage(int index) {
    selectedIndex.value = index;
  }

  bool handleBackPress() {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      Get.snackbar(
        AppConstants.exitAppTitle,
        AppConstants.exitAppSnackBarMsg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xE61E293B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }
}