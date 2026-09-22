import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/widgets/custom_snackbar.dart';
import 'package:stockpulse/utils/app_constants.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final RxList<ConnectivityResult> _connectionStatus =
      <ConnectivityResult>[].obs;

  @override
  void onInit() {
    super.onInit();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    _connectionStatus.assignAll(results);

    if (results.contains(ConnectivityResult.none)) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
      );
    }
  }

  /// Checks if internet connectivity is available.
  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();

      return !results.contains(ConnectivityResult.none);
    } on PlatformException {
      return false;
    }
  }

  /// Reusable method called before backend operations on buttons.
  /// Returns `true` if connected, or shows a warning snackbar and returns `false` if disconnected.
  Future<bool> checkInternet() async {
    final connected = await isConnected();
    if (!connected) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
      );
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
