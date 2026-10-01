import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:get/get.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../services/thermal_printer_service.dart';
import 'common/widgets/StandardScreen.dart';
import 'common/widgets/appbar.dart';
import 'common/widgets/custom_snackbar.dart';

class PrinterSettingsView extends StatelessWidget {
  PrinterSettingsView({
    super.key,
    this.onPrinterSelected,
  });

  /// If provided:
  /// connect hone ke baad selected printer callback mein milega.
  final Future<void> Function(Printer printer)? onPrinterSelected;

  final ThermalPrinterService printerService =
  Get.find<ThermalPrinterService>();

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: const Text(AppConstants.printerSettingsTitle),
      ),
      body: Obx(() {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: printerService.isScanning.value
                    ? null
                    : printerService.startScan,
                icon: const Icon(Icons.search),
                label: Text(
                  printerService.isScanning.value
                      ? AppConstants.btnScanning
                      : AppConstants.btnScanPrinters,
                ),
              ),
            ),
            Expanded(
              child: printerService.printers.isEmpty
                  ? const Center(
                child: Text(
                  AppConstants.txtNoPrintersFound,
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: printerService.printers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final printer = printerService.printers[index];

                  final selected =
                      printerService.selectedPrinter.value == printer;

                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.print_outlined,
                      ),
                    ),
                    title: Text(
                      printer.name ?? AppConstants.defaultPrinterName,
                    ),
                    subtitle: Text(
                      printer.address ?? AppConstants.defaultDeviceAddress,
                    ),
                    trailing: selected
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () async {
                      final connected =
                      await printerService.connectPrinter(
                        printer,
                      );

                      if (connected) {
                        CustomSnackBar.successSnackBar(
                          title: AppConstants.snackbarTitleConnected,
                          message: printer.name ??
                              AppConstants.msgPrinterConnected,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}