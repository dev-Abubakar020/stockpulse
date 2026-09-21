import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/widgets/custom_snackbar.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  final RxList<ConnectivityResult> _connectionStatus =
      <ConnectivityResult>[].obs;

  @override
  void onInit() {
    super.onInit();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(
          _updateConnectionStatus,
        );
  }

  Future<void> _updateConnectionStatus(
      List<ConnectivityResult> results,
      ) async {
    _connectionStatus.assignAll(results);

    if (results.contains(ConnectivityResult.none)) {
      CustomSnackBar.warningSnackBar(
        title: 'No Internet Connection',
      );
    }
  }

  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();

      return !results.contains(ConnectivityResult.none);
    } on PlatformException {
      return false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}