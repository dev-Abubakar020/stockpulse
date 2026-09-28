import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/sale_model.dart';
import '../../models/sale_item_model.dart';

class ThermalSaleReceipt extends StatelessWidget {
  final SaleModel sale;
  final List<SaleItemModel> items;
  final String creatorName;

  const ThermalSaleReceipt({
    super.key,
    required this.sale,
    required this.items,
    required this.creatorName,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd-MM-yyyy hh:mm a',
    ).format(sale.saleDate.toLocal());

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
              'STOCKPULSE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            const Text(
              'SALE RECEIPT',
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
              'INVOICE:',
              sale.saleNo,
            ),

            _row(
              'DATE:',
              date,
            ),

            _row(
              'TERMINAL:',
              'POS-TERMINAL-01',
            ),

            _row(
              'OPERATOR:',
              creatorName.trim().isEmpty
                  ? 'Auth-User'
                  : creatorName,
            ),

            _row(
              'PAYMENT:',
              sale.paymentMethod.toUpperCase(),
            ),

            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 8),

            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'ITEM',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'QTY',
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
                    'TOTAL',
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
              'TOTAL ITEMS:',
              '${items.length} SKU (${_qty(totalQty)} Units)',
            ),

            const SizedBox(height: 7),

            _row(
              'SUBTOTAL:',
              'Rs. ${_money(sale.subtotal)}',
            ),

            if (sale.discount > 0)
              _row(
                'DISCOUNT:',
                '- Rs. ${_money(sale.discount)}',
              ),

            const SizedBox(height: 6),
            _divider(),
            const SizedBox(height: 6),

            _row(
              'NET TOTAL:',
              'Rs. ${_money(sale.totalAmount)}',
              bold: true,
            ),

            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 15),

            const Text(
              'Thank you for your business!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
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