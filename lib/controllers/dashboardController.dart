import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/widgets/custom_snackbar.dart';
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
      CustomSnackBar.warningSnackBar(
        title: AppConstants.exitAppTitle,
        message: AppConstants.exitAppSnackBarMsg,
      );
      return false;
    }
    return true;
  }
}
