import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../models/purchasemodel.dart';

class ThermalPurchaseReceipt
    extends StatelessWidget {
  final PurchaseModel purchase;
  final List<PurchaseItemModel> items;
  final String creatorName;

  const ThermalPurchaseReceipt({
    super.key,
    required this.purchase,
    required this.items,
    required this.creatorName,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      AppConstants.dateFormat2,
    ).format(
      purchase.purchaseDate.toLocal(),
    );

    final totalQty = items.fold<double>(
      0,
          (sum, item) => sum + item.quantity,
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            const Text(
              AppConstants.receiptStoreName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            const Text(
              AppConstants.receiptTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 8),

            _row(
              AppConstants.receiptLabelPurchase,
              purchase.purchaseNo,
            ),

            _row(
              AppConstants.receiptLabelDate,
              date,
            ),

            _row(
              AppConstants.receiptLabelTerminal,
              AppConstants.receiptDefaultTerminal,
            ),

            _row(
              AppConstants.receiptLabelOperator,
              creatorName.trim().isEmpty
                  ? AppConstants.receiptDefaultOperator
                  : creatorName,
            ),

            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 8),

            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    AppConstants.receiptHeaderItem,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppConstants.receiptHeaderQty,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    AppConstants.receiptHeaderTotal,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
            _divider(),

            ...items.map(
                  (item) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.article,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _qty(item.quantity),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _money(item.lineTotal),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _divider(),

            const SizedBox(height: 7),

            _row(
              AppConstants.receiptLabelTotalItems,
              '${items.length} ${AppConstants.unitSku} (${_qty(totalQty)} ${AppConstants.unit})',
            ),

            const SizedBox(height: 7),

            _row(
              AppConstants.receiptLabelSubtotal,
              '${AppConstants.defaultCurrency} ${_money(purchase.subtotal)}',
            ),

            if (purchase.discount > 0)
              _row(
                AppConstants.receiptLabelDiscount,
                '- ${AppConstants.defaultCurrency} ${_money(purchase.discount)}',
              ),

            const SizedBox(height: 6),
            _divider(),
            const SizedBox(height: 6),

            _row(
              AppConstants.receiptLabelNetTotal,
              '${AppConstants.defaultCurrency} ${_money(purchase.totalAmount)}',
              bold: true,
            ),

            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 15),

            const Text(
              AppConstants.receiptFooterTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              AppConstants.receiptFooterGeneratedBy,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 9,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(
      String label,
      String value, {
        bool bold = false,
      }) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.black,
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: Colors.black,
    );
  }

  static String _qty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _money(num value) {
    return NumberFormat(
      '#,##0.##',
    ).format(value);
  }
}