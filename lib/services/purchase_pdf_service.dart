import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/purchasemodel.dart';

class PurchasePdfService {
  static Future<Uint8List> generatePurchase({
    required PdfPageFormat format,
    required PurchaseModel purchase,
    required List<PurchaseItemModel> items,
    required String creatorName,
  }) async {
    final pdf = pw.Document();

    final isThermal =
        format.width < 100 * PdfPageFormat.mm;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,

        margin: isThermal
            ? pw.EdgeInsets.all(
          3 * PdfPageFormat.mm,
        )
            : const pw.EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 28,
        ),

        build: (_) => [
          _buildReceipt(
            purchase: purchase,
            items: items,
            creatorName: creatorName,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildReceipt({
    required PurchaseModel purchase,
    required List<PurchaseItemModel> items,
    required String creatorName,
  }) {
    final date = DateFormat(
      'dd-MM-yyyy',
    ).format(
      purchase.purchaseDate.toLocal(),
    );

    final time = DateFormat(
      'hh:mm:ss a',
    ).format(
      purchase.purchaseDate.toLocal(),
    );

    final totalQty = items.fold<double>(
      0,
          (sum, item) => sum + item.quantity,
    );

    return pw.Center(
      child: pw.Container(
        width: 360,
        child: pw.Column(
          crossAxisAlignment:
          pw.CrossAxisAlignment.stretch,
          children: [
            // HEADER
            pw.Center(
              child: pw.Text(
                'STOCKPULSE',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight:
                  pw.FontWeight.bold,
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
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            _doubleDivider(),

            pw.SizedBox(height: 5),

            pw.Center(
              child: pw.Text(
                'PURCHASE RECEIPT',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight:
                  pw.FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            pw.SizedBox(height: 5),

            _doubleDivider(),

            pw.SizedBox(height: 8),

            // INFO
            _infoLine(
              'PURCHASE:',
              purchase.purchaseNo,
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

            pw.SizedBox(height: 8),

            _dashedDivider(),

            pw.SizedBox(height: 7),

            // TABLE HEADER
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
                    align:
                    pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _headerText(
                    'PRICE',
                    align:
                    pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _headerText(
                    'TOTAL',
                    align:
                    pw.TextAlign.right,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 5),

            _dashedDivider(),

            ...items.map(
                  (item) => _buildItem(item),
            ),

            _dashedDivider(),

            pw.SizedBox(height: 7),

            _infoLine(
              'TOTAL ITEMS:',
              '${items.length} SKU (${_formatQty(totalQty)} Units)',
              boldValue: true,
            ),

            pw.SizedBox(height: 7),

            _dashedDivider(),

            pw.SizedBox(height: 6),

            _amountRow(
              'SUBTOTAL',
              'Rs. ${_formatMoney(purchase.subtotal)}',
            ),

            if (purchase.discount > 0) ...[
              pw.SizedBox(height: 4),
              _amountRow(
                'DISCOUNT',
                '- Rs. ${_formatMoney(purchase.discount)}',
              ),
            ],

            pw.SizedBox(height: 6),

            _doubleDivider(),

            pw.SizedBox(height: 6),

            _amountRow(
              'NET TOTAL',
              'Rs. ${_formatMoney(purchase.totalAmount)}',
              bold: true,
              fontSize: 11,
            ),

            pw.SizedBox(height: 6),

            _doubleDivider(),

            pw.SizedBox(height: 14),

            pw.Center(
              child: pw.Text(
                'Purchase Receipt',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight:
                  pw.FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildItem(
      PurchaseItemModel item,
      ) {
    return pw.Padding(
      padding:
      const pw.EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              item.article,
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Expanded(
            flex: 1,
            child: pw.Text(
              _formatQty(item.quantity),
              textAlign:
              pw.TextAlign.center,
              style: const pw.TextStyle(
                fontSize: 8,
              ),
            ),
          ),

          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _formatMoney(
                item.purchasePrice,
              ),
              textAlign:
              pw.TextAlign.right,
              style: const pw.TextStyle(
                fontSize: 8,
              ),
            ),
          ),

          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _formatMoney(
                item.lineTotal,
              ),
              textAlign:
              pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoLine(
      String label,
      String value, {
        bool boldValue = false,
      }) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 75,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight:
              pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            value,
            textAlign:
            pw.TextAlign.right,
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

  static pw.Widget _amountRow(
      String label,
      String amount, {
        bool bold = false,
        double fontSize = 8.5,
      }) {
    return pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment
          .spaceBetween,
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
            fontWeight:
            pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _headerText(
      String text, {
        pw.TextAlign align =
            pw.TextAlign.left,
      }) {
    return pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: 7,
        fontWeight:
        pw.FontWeight.bold,
      ),
    );
  }

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
      '==========================================================================',
      maxLines: 1,
      style: const pw.TextStyle(
        fontSize: 6,
      ),
    );
  }

  static String _formatQty(
      double value,
      ) {
    if (value ==
        value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _formatMoney(
      num value,
      ) {
    return NumberFormat(
      '#,##0.##',
    ).format(value);
  }
}