import 'dart:async';

import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../common/exceptional/platform_exceptions.dart';
import '../common/widgets/custom_snackbar.dart';
import '../utils/app_constants.dart';


Future<bool> requestPrinterPermissions() async {
  try {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final scanGranted =
        statuses[Permission.bluetoothScan]
            ?.isGranted ==
            true;

    final connectGranted =
        statuses[Permission.bluetoothConnect]
            ?.isGranted ==
            true;

    return scanGranted &&
        connectGranted;
  } catch (e) {
    throw AppException.fromException(e);
  }
}

// THERMAL PRINTER SERVICE

class ThermalPrinterService
    extends GetxService {
  final FlutterThermalPrinter
  _thermalPrinter =
      FlutterThermalPrinter.instance;

  final printers =
      <Printer>[].obs;

  final selectedPrinter =
  Rxn<Printer>();

  final isScanning =
      false.obs;

  final isConnecting =
      false.obs;

  StreamSubscription<List<Printer>>?
  _devicesSubscription;

  Future<void> startScan() async {
    // Prevent multiple scans
    if (isScanning.value) return;

    try {
      final allowed =
      await requestPrinterPermissions();

      if (!allowed) {
        throw const AppException(
          AppConstants
              .bluetoothPermissionDenied,
        );
      }

      isScanning.value = true;
      printers.clear();

      await _devicesSubscription
          ?.cancel();

      _devicesSubscription =
          _thermalPrinter
              .devicesStream
              .listen(
                (devices) {
              printers.assignAll(
                devices,
              );
            },

            // Stream errors need their own handler.
            onError: (error) {
              final appError =
              AppException.fromException(
                error,
              );

              CustomSnackBar
                  .errorSnackBar(
                title: 'Printer Error',
                message:
                appError.message,
              );
            },
          );

      // --------------------------------------------------------
      // SEARCH
      // --------------------------------------------------------

      await _thermalPrinter
          .getPrinters(
        connectionTypes: [
          ConnectionType.BLE,
          ConnectionType.USB,
        ],
      );
    } catch (e) {
      final error =
      AppException.fromException(
        e,
      );

      CustomSnackBar.errorSnackBar(
        title: 'Printer Error',
        message: error.message,
      );
    } finally {
      isScanning.value = false;
    }
  }

  // CONNECT PRINTER

  Future<bool> connectPrinter(
      Printer printer,
      ) async {
    // Prevent double tap
    if (isConnecting.value) {
      return false;
    }

    try {
      isConnecting.value = true;

      // ALREADY SELECTED

      if (selectedPrinter.value ==
          printer) {
        return true;
      }

      // DISCONNECT PREVIOUS PRINTER

      final current =
          selectedPrinter.value;

      if (current != null &&
          current != printer) {
        try {
          await _thermalPrinter
              .disconnect(current);
        } catch (_) {
          // Ignore old printer disconnect failure.
          // We still attempt the new connection.
        }

        selectedPrinter.value =
        null;
      }

      // --------------------------------------------------------
      // CONNECT
      // --------------------------------------------------------

      await _thermalPrinter.connect(
        printer,
      );

      selectedPrinter.value =
          printer;

      return true;
    } catch (e) {
      selectedPrinter.value = null;

      final error =
      AppException.fromException(
        e,
      );

      CustomSnackBar.errorSnackBar(
        title: 'Connection Failed',
        message: error.message,
      );

      return false;
    } finally {
      isConnecting.value = false;
    }
  }

  // ============================================================
  // DISCONNECT PRINTER
  // ============================================================

  Future<void>
  disconnectPrinter() async {
    final printer =
        selectedPrinter.value;

    if (printer == null) {
      return;
    }

    try {
      await _thermalPrinter
          .disconnect(
        printer,
      );

      selectedPrinter.value =
      null;
    } catch (e) {
      final error =
      AppException.fromException(
        e,
      );

      CustomSnackBar.errorSnackBar(
        title: 'Disconnect Failed',
        message: error.message,
      );
    }
  }

  // ============================================================
  // CLEAR DISCOVERED PRINTERS
  // ============================================================

  void clearPrinters() {
    printers.clear();
  }

  // ============================================================
  // STOP SCAN / LISTENER
  // ============================================================

  Future<void> stopScan() async {
    try {
      await _devicesSubscription
          ?.cancel();

      _devicesSubscription = null;

      isScanning.value = false;
    } catch (e) {
      final error =
      AppException.fromException(
        e,
      );

      CustomSnackBar.errorSnackBar(
        title: 'Printer Error',
        message: error.message,
      );
    }
  }

  // ============================================================
  // SERVICE DISPOSE
  // ============================================================

  @override
  void onClose() {
    _devicesSubscription?.cancel();

    super.onClose();
  }
}