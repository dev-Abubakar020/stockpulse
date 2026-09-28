
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/sale_model.dart';
import '../models/sale_item_model.dart';

class SalePdfService {
  // ============================================================
  // PREVIEW / PRINT
  // ============================================================
  static Future<Uint8List> generateSale({
    required PdfPageFormat format,
    required SaleModel sale,
    required List<SaleItemModel> items,
    required String creatorName,
  }) async {
    final pdf = pw.Document();

    final isThermal =
        format.width < 100 * PdfPageFormat.mm;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: isThermal
            ? pw.EdgeInsets.all(3 * PdfPageFormat.mm)
            : const pw.EdgeInsets.all(32),

        build: (context) => [
          _buildReceipt(
            sale: sale,
            items: items,
            creatorName: creatorName,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> previewSale({
    required SaleModel sale,
    required List<SaleItemModel> items,
    required String creatorName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 28,
        ),
        build: (context) => [
          _buildReceipt(
            sale: sale,
            items: items,
            creatorName: creatorName,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      name: '${sale.saleNo}.pdf',
      onLayout: (_) async => pdf.save(),
    );
  }

  // ============================================================
  // COMPLETE RECEIPT
  // ============================================================

  static pw.Widget _buildReceipt({
    required SaleModel sale,
    required List<SaleItemModel> items,
    required String creatorName,
  }) {
    final date = DateFormat(
      'dd-MM-yyyy',
    ).format(sale.saleDate.toLocal());

    final time = DateFormat(
      'hh:mm:ss a',
    ).format(sale.saleDate.toLocal());

    final totalQty = items.fold<double>(
      0,
          (sum, item) => sum + item.quantity,
    );

    return pw.Center(
      child: pw.Container(
        // Keeps terminal-style receipt compact even on A4.
        width: 360,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // --------------------------------------------------
            // SHOP HEADER
            // --------------------------------------------------

            pw.Center(
              child: pw.Text(
                'STOCKPULSE',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            pw.SizedBox(height: 3),

            pw.Center(
              child: pw.Text(
                'GENERAL STORE',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 2),

            pw.Center(
              child: pw.Text(
                'Powered by StockPulse POS',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey700,
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            _doubleDivider(),

            pw.SizedBox(height: 5),

            pw.Center(
              child: pw.Text(
                'SALE RECEIPT',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            pw.SizedBox(height: 5),

            _doubleDivider(),

            pw.SizedBox(height: 8),

            // --------------------------------------------------
            // SALE INFORMATION
            // --------------------------------------------------

            _infoLine(
              'INVOICE:',
              sale.saleNo,
            ),

            pw.SizedBox(height: 3),

            _infoLine(
              'DATE:',
              '$date   $time',
            ),

            pw.SizedBox(height: 3),

            _infoLine(
              'TERMINAL:',
              'POS-TERMINAL-01',
            ),

            pw.SizedBox(height: 3),

            _infoLine(
              'OPERATOR:',
              creatorName.trim().isEmpty
                  ? 'Auth-User'
                  : creatorName,
            ),

            pw.SizedBox(height: 3),

            _infoLine(
              'PAYMENT:',
              sale.paymentMethod.toUpperCase(),
            ),

            pw.SizedBox(height: 8),

            _dashedDivider(),

            pw.SizedBox(height: 7),

            // --------------------------------------------------
            // ITEMS HEADER
            // --------------------------------------------------

            pw.Row(
              children: [
                pw.Expanded(
                  flex: 5,
                  child: _headerText(
                    'ITEM / SKU',
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: _headerText(
                    'QTY',
                    align: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _headerText(
                    'PRICE',
                    align: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _headerText(
                    'TOTAL',
                    align: pw.TextAlign.right,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 5),

            _dashedDivider(),

            pw.SizedBox(height: 2),

            // --------------------------------------------------
            // ITEMS
            // --------------------------------------------------

            if (items.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 15,
                ),
                child: pw.Center(
                  child: pw.Text(
                    'No items found',
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
              )
            else
              ...items.map(
                    (item) => _buildItem(item),
              ),

            pw.SizedBox(height: 3),

            _dashedDivider(),

            pw.SizedBox(height: 7),

            // --------------------------------------------------
            // SUMMARY
            // --------------------------------------------------

            _infoLine(
              'TOTAL ITEMS:',
              '${items.length} SKU${items.length == 1 ? '' : 's'}'
                  ' (${_formatQty(totalQty)} Units)',
              boldValue: true,
            ),

            pw.SizedBox(height: 7),

            _dashedDivider(),

            pw.SizedBox(height: 6),

            _amountRow(
              'SUBTOTAL',
              'Rs. ${_formatMoney(sale.subtotal)}',
            ),

            if (sale.discount > 0) ...[
              pw.SizedBox(height: 4),
              _amountRow(
                'DISCOUNT',
                '- Rs. ${_formatMoney(sale.discount)}',
              ),
            ],

            pw.SizedBox(height: 6),

            _doubleDivider(),

            pw.SizedBox(height: 6),

            _amountRow(
              'NET TOTAL',
              'Rs. ${_formatMoney(sale.totalAmount)}',
              bold: true,
              fontSize: 11,
            ),

            pw.SizedBox(height: 6),

            _doubleDivider(),

            // --------------------------------------------------
            // NOTES
            // --------------------------------------------------

            if (sale.notes != null &&
                sale.notes!.trim().isNotEmpty) ...[
              pw.SizedBox(height: 10),

              pw.Text(
                'NOTES',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 3),

              pw.Text(
                sale.notes!.trim(),
                style: const pw.TextStyle(
                  fontSize: 8,
                ),
              ),

              pw.SizedBox(height: 10),

              _dashedDivider(),
            ],

            // --------------------------------------------------
            // FOOTER
            // --------------------------------------------------

            pw.SizedBox(height: 14),

            pw.Center(
              child: pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 4),

            pw.Center(
              child: pw.Text(
                'Generated by StockPulse',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey700,
                ),
              ),
            ),

            pw.SizedBox(height: 12),

            pw.Center(
              child: pw.Text(
                sale.saleNo,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            pw.SizedBox(height: 4),

            pw.Center(
              child: pw.Text(
                'Verified Sale Receipt',
                style: const pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ITEM
  // ============================================================

  static pw.Widget _buildItem(
      SaleItemModel item,
      ) {
    final variants = <String>[];

    if (item.color != null &&
        item.color!.trim().isNotEmpty) {
      variants.add(item.color!.trim());
    }

    if (item.size != null &&
        item.size!.trim().isNotEmpty) {
      variants.add('Size: ${item.size!.trim()}');
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Product
              pw.Expanded(
                flex: 5,
                child: pw.Text(
                  item.article,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Qty
              pw.Expanded(
                flex: 1,
                child: pw.Text(
                  _formatQty(item.quantity),
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 8,
                  ),
                ),
              ),

              // Price
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  _formatMoney(item.salePrice),
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(
                    fontSize: 8,
                  ),
                ),
              ),

              // Total
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  _formatMoney(item.lineTotal),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 2),

          // Unit / variants
          pw.Text(
            [
              'UNIT: ${item.unit.toUpperCase()}',
              if (variants.isNotEmpty) variants.join(' | '),
            ].join('   '),
            style: const pw.TextStyle(
              fontSize: 6.5,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO LINE
  // ============================================================

  static pw.Widget _infoLine(
      String label,
      String value, {
        bool boldValue = false,
      }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 75,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: boldValue
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AMOUNT ROW
  // ============================================================

  static pw.Widget _amountRow(
      String label,
      String amount, {
        bool bold = false,
        double fontSize = 8.5,
      }) {
    return pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: bold
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),

        pw.Text(
          amount,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  static pw.Widget _headerText(
      String text, {
        pw.TextAlign align = pw.TextAlign.left,
      }) {
    return pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // DIVIDERS
  // ============================================================

  static pw.Widget _dashedDivider() {
    return pw.Text(
      '--------------------------------------------------------------------------',
      maxLines: 1,
      style: const pw.TextStyle(
        fontSize: 6,
        color: PdfColors.grey700,
      ),
    );
  }

  static pw.Widget _doubleDivider() {
    return pw.Text(
      '====================================================================================================================',
      maxLines: 1,
      style: const pw.TextStyle(
        fontSize: 6,
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _formatMoney(num value) {
    final number = value.toDouble();

    return NumberFormat('#,##0.##').format(number);
  }
}