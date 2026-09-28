// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import '../printingview.dart';
// import '../models/sale_model.dart';
// import 'package:flutter/material.dart';
// import '../models/sale_item_model.dart';
// import 'package:printing/printing.dart' as printing;
// import 'package:stockpulse/services/sale_pdf_service.dart';
// import 'package:flutter_thermal_printer/flutter_thermal_printer.dart' as thermal;
// import 'package:flutter_thermal_printer/utils/printer.dart' as thermal_model;
//
//
// class SalePrintPreviewScreen extends StatefulWidget {
//   final SaleModel sale;
//   final List<SaleItemModel> items;
//   final String creatorName;
//
//   const SalePrintPreviewScreen({
//     super.key,
//     required this.sale,
//     required this.items,
//     required this.creatorName,
//   });
//
//   // ============================================================
//   // PAPER SIZES
//   // ============================================================
//
//   static final thermal80 = PdfPageFormat(
//     80 * PdfPageFormat.mm,
//     200 * PdfPageFormat.mm,
//     marginAll: 4 * PdfPageFormat.mm,
//   );
//
//   static final thermal58 = PdfPageFormat(
//     58 * PdfPageFormat.mm,
//     200 * PdfPageFormat.mm,
//     marginAll: 3 * PdfPageFormat.mm,
//   );
//
//   @override
//   State<SalePrintPreviewScreen> createState() => _SalePrintPreviewScreenState();
// }
//
// class _SalePrintPreviewScreenState extends State<SalePrintPreviewScreen> {
//   // ============================================================
//   // HANDLE PRINT
//   // ============================================================
//
//   Future<void> _handlePrint(PdfPageFormat format) async {
//     final isThermal = format.width < 100 * PdfPageFormat.mm;
//
//     if (isThermal) {
//       Get.to(
//             () => PrinterSettingsView(
//           onPrinterSelected: (printer) async {
//             await _printToPOS(printer);
//           },
//         ),
//       );
//     } else {
//       // A4 / PDF
//       await printing.Printing.layoutPdf(
//         name: '${widget.sale.saleNo}.pdf',
//         format: PdfPageFormat.a4,
//         onLayout: (format) {
//           return SalePdfService.generateSale(
//             format: format,
//             sale: widget.sale,
//             items: widget.items,
//             creatorName: widget.creatorName,
//           );
//         },
//       );
//     }
//   }
//
//   // ============================================================
//   // UI
//   // ============================================================
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Print Preview')),
//
//       body: printing.PdfPreview(
//         // Default paper
//         initialPageFormat: SalePrintPreviewScreen.thermal80,
//
//         // Available sizes
//         pageFormats: {
//           'POS 80mm': SalePrintPreviewScreen.thermal80,
//           'POS 58mm': SalePrintPreviewScreen.thermal58,
//           'A4': PdfPageFormat.a4,
//         },
//
//         canChangePageFormat: true,
//         canChangeOrientation: false,
//
//         // We are handling print ourselves.
//         allowPrinting: false,
//         // Keep PDF share/save option.
//         allowSharing: true,
//
//         build: (format) {
//           return SalePdfService.generateSale(
//             format: format,
//             sale: widget.sale,
//             items: widget.items,
//             creatorName: widget.creatorName,
//           );
//         },
//
//         actions: [
//           printing.PdfPreviewAction(
//             icon: const Icon(Icons.print_rounded),
//             onPressed: (context, build, format) {
//               _handlePrint(format);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // PRINT THERMAL RECEIPT
//   // ============================================================
//
//   Future<void> _printToPOS(thermal_model.Printer printer) async {
//     await thermal.FlutterThermalPrinter.instance.printWidget(
//       context,
//       printer: printer,
//       widget: ThermalSaleReceipt(
//         sale: widget.sale,
//         items: widget.items,
//         creatorName: widget.creatorName,
//       ),
//     );
//   }
// }
//
// // ================================================================
// // THERMAL RECEIPT
// // ================================================================
//
// class ThermalSaleReceipt extends StatelessWidget {
//   final SaleModel sale;
//   final List<SaleItemModel> items;
//   final String creatorName;
//
//   const ThermalSaleReceipt({
//     super.key,
//     required this.sale,
//     required this.items,
//     required this.creatorName,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final date = DateFormat('dd-MM-yyyy').format(sale.saleDate.toLocal());
//
//     final time = DateFormat('hh:mm:ss a').format(sale.saleDate.toLocal());
//
//     final totalQty = items.fold<double>(0, (sum, item) => sum + item.quantity);
//
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       child: DefaultTextStyle(
//         style: const TextStyle(color: Colors.black, fontSize: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // --------------------------------------------------
//             // HEADER
//             // --------------------------------------------------
//
//             const Text(
//               'STOCKPULSE',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 2),
//
//             const Text(
//               'GENERAL STORE',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//
//             const SizedBox(height: 2),
//
//             const Text(
//               'Powered by StockPulse POS',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.black, fontSize: 10),
//             ),
//
//             const SizedBox(height: 10),
//
//             _divider(),
//
//             const SizedBox(height: 6),
//
//             const Text(
//               'SALE RECEIPT',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1,
//               ),
//             ),
//
//             const SizedBox(height: 6),
//
//             _divider(),
//
//             const SizedBox(height: 8),
//
//             // --------------------------------------------------
//             // SALE INFORMATION
//             // --------------------------------------------------
//             _row('INVOICE:', sale.saleNo),
//
//             const SizedBox(height: 4),
//
//             _row('DATE:', '$date $time'),
//
//             const SizedBox(height: 4),
//
//             _row('TERMINAL:', 'POS-TERMINAL-01'),
//
//             const SizedBox(height: 4),
//
//             _row(
//               'OPERATOR:',
//               creatorName.trim().isEmpty ? 'Auth-User' : creatorName,
//             ),
//
//             const SizedBox(height: 4),
//
//             _row('PAYMENT:', sale.paymentMethod.toUpperCase()),
//
//             const SizedBox(height: 8),
//
//             _divider(),
//
//             const SizedBox(height: 8),
//
//             // --------------------------------------------------
//             // ITEMS HEADER
//             // --------------------------------------------------
//             const Row(
//               children: [
//                 Expanded(
//                   flex: 4,
//                   child: Text(
//                     'ITEM',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//
//                 Expanded(
//                   flex: 1,
//                   child: Text(
//                     'QTY',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     'PRICE',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     'TOTAL',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 5),
//
//             _divider(),
//
//             // --------------------------------------------------
//             // ITEMS
//             // --------------------------------------------------
//             ...items.map(
//               (item) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           flex: 4,
//                           child: Text(
//                             item.article,
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//
//                         Expanded(
//                           flex: 1,
//                           child: Text(
//                             _formatQty(item.quantity),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ),
//
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             _formatMoney(item.salePrice),
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ),
//
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             _formatMoney(item.lineTotal),
//                             textAlign: TextAlign.right,
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 2),
//
//                     Text(
//                       'UNIT: ${item.unit.toUpperCase()}',
//                       style: const TextStyle(color: Colors.black, fontSize: 9),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             _divider(),
//
//             const SizedBox(height: 7),
//
//             // --------------------------------------------------
//             // SUMMARY
//             // --------------------------------------------------
//             _row(
//               'TOTAL ITEMS:',
//               '${items.length} SKU'
//                   ' (${_formatQty(totalQty)} Units)',
//               bold: true,
//             ),
//
//             const SizedBox(height: 7),
//
//             _divider(),
//
//             const SizedBox(height: 7),
//
//             _row('SUBTOTAL', 'Rs. ${_formatMoney(sale.subtotal)}'),
//
//             if (sale.discount > 0) ...[
//               const SizedBox(height: 5),
//
//               _row('DISCOUNT', '- Rs. ${_formatMoney(sale.discount)}'),
//             ],
//
//             const SizedBox(height: 7),
//
//             _divider(),
//
//             const SizedBox(height: 7),
//
//             _row(
//               'NET TOTAL',
//               'Rs. ${_formatMoney(sale.totalAmount)}',
//               bold: true,
//               fontSize: 14,
//             ),
//
//             const SizedBox(height: 7),
//
//             _divider(),
//
//             // --------------------------------------------------
//             // NOTES
//             // --------------------------------------------------
//             if (sale.notes != null && sale.notes!.trim().isNotEmpty) ...[
//               const SizedBox(height: 10),
//
//               const Text(
//                 'NOTES',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 10,
//                 ),
//               ),
//
//               const SizedBox(height: 3),
//
//               Text(
//                 sale.notes!.trim(),
//                 style: const TextStyle(color: Colors.black, fontSize: 10),
//               ),
//
//               const SizedBox(height: 10),
//
//               _divider(),
//             ],
//
//             // --------------------------------------------------
//             // FOOTER
//             // --------------------------------------------------
//             const SizedBox(height: 15),
//
//             const Text(
//               'Thank you for your business!',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//
//             const SizedBox(height: 4),
//
//             const Text(
//               'Generated by StockPulse',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.black, fontSize: 9),
//             ),
//
//             const SizedBox(height: 8),
//
//             Text(
//               sale.saleNo,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.black,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             // Feed space after receipt
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // ROW
//   // ============================================================
//
//   Widget _row(
//     String title,
//     String value, {
//     bool bold = false,
//     double fontSize = 11,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: fontSize,
//               fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ),
//
//         const SizedBox(width: 8),
//
//         Flexible(
//           child: Text(
//             value,
//             textAlign: TextAlign.right,
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: fontSize,
//               fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // DIVIDER
//   // ============================================================
//
//   Widget _divider() {
//     return Container(height: 1, color: Colors.black);
//   }
//
//   // ============================================================
//   // FORMAT QTY
//   // ============================================================
//
//   static String _formatQty(double value) {
//     if (value == value.roundToDouble()) {
//       return value.toInt().toString();
//     }
//
//     return value.toStringAsFixed(2);
//   }
//
//   // ============================================================
//   // FORMAT MONEY
//   // ============================================================
//
//   static String _formatMoney(num value) {
//     return NumberFormat('#,##0.##').format(value.toDouble());
//   }
// }


import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart'
as thermal;
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart' as printing;

import '../printingview.dart';
import '../services/thermal_printer_service.dart';

class PrintPreviewScreen extends StatefulWidget {
  final String documentName;

  /// PDF generator
  final Future<Uint8List> Function(
      PdfPageFormat format,
      ) buildPdf;

  /// Widget sent to thermal printer
  final Widget thermalWidget;

  const PrintPreviewScreen({
    super.key,
    required this.documentName,
    required this.buildPdf,
    required this.thermalWidget,
  });

  static final thermal80 = PdfPageFormat(
    80 * PdfPageFormat.mm,
    200 * PdfPageFormat.mm,
    marginAll: 4 * PdfPageFormat.mm,
  );

  static final thermal58 = PdfPageFormat(
    58 * PdfPageFormat.mm,
    200 * PdfPageFormat.mm,
    marginAll: 3 * PdfPageFormat.mm,
  );

  @override
  State<PrintPreviewScreen> createState() =>
      _PrintPreviewScreenState();
}

class _PrintPreviewScreenState
    extends State<PrintPreviewScreen> {

  // ============================================================
  // HANDLE PRINT
  // ============================================================

  Future<void> _handlePrint(
      PdfPageFormat format,
      ) async {
    final isThermal =
        format.width < 100 * PdfPageFormat.mm;

    // ----------------------------------------------------------
    // POS / THERMAL
    // ----------------------------------------------------------

    if (isThermal) {
      final service =
      Get.find<ThermalPrinterService>();

      // Already connected?
      final printer =
          service.selectedPrinter.value;

      if (printer != null) {
        await _printToPOS(printer);
        return;
      }

      // No printer connected -> select printer
      Get.to(
            () => PrinterSettingsView(
          onPrinterSelected: (printer) async {
            await _printToPOS(printer);
          },
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // A4 / PDF
    // ----------------------------------------------------------

    await printing.Printing.layoutPdf(
      name: '${widget.documentName}.pdf',
      format: PdfPageFormat.a4,
      onLayout: widget.buildPdf,
    );
  }

  // ============================================================
  // POS PRINT
  // ============================================================

  Future<void> _printToPOS(
      Printer printer,
      ) async {
    await thermal.FlutterThermalPrinter.instance
        .printWidget(
      context,
      printer: printer,
      widget: widget.thermalWidget,
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Print Preview',
        ),
      ),

      body: printing.PdfPreview(
        initialPageFormat:
        PrintPreviewScreen.thermal80,

        pageFormats: {
          'POS 80mm':
          PrintPreviewScreen.thermal80,

          'POS 58mm':
          PrintPreviewScreen.thermal58,

          'A4':
          PdfPageFormat.a4,
        },

        canChangePageFormat: true,
        canChangeOrientation: false,

        allowPrinting: false,
        allowSharing: true,

        build: widget.buildPdf,

        actions: [
          printing.PdfPreviewAction(
            icon: const Icon(
              Icons.print_rounded,
            ),
            onPressed: (
                context,
                build,
                format,
                ) {
              _handlePrint(format);
            },
          ),
        ],
      ),
    );
  }
}