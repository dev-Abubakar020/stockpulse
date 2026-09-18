import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/cutom_TransactionTile.dart';
import '../../models/TransactionItemModel.dart';

class SaleView extends StatelessWidget {
  SaleView({super.key});

  final transactions = [
    const TransactionItem(
      reference: 'INV-1048',
      name: 'Muhammad Ali',
      dateTime: 'Today, 10:42 AM',
      amount: 'Rs. 2,450',
      status: 'Completed',
      statusType: StatusType.success,
    ),

    const TransactionItem(
      reference: 'INV-1047',
      name: 'Muhammad Ali',
      dateTime: 'Today, 10:21 AM',
      amount: 'Rs. 12,960',
      status: 'Processing',
      statusType: StatusType.info,
    ),

    const TransactionItem(
      reference: 'INV-1046',
      name: 'Muhammad Ali',
      dateTime: 'Today, 09:55 AM',
      amount: 'Rs. 3,850',
      status: 'Pending',
      statusType: StatusType.warning,
    ),

    const TransactionItem(
      reference: 'INV-1045',
      name: 'Muhammad Ali',
      dateTime: 'Yesterday, 06:30 PM',
      amount: 'Rs. 1,250',
      status: 'Cancelled',
      statusType: StatusType.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                title: AppConstants.saleTitle,
                actions: [
                  Expanded(
                    child: AppButton(
                      text: AppConstants.addSale,
                      onPressed: () => Get.toNamed(Routes.addSale),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomSearchField(
                // controller: controller.searchController,
                hintText: AppConstants.searchHint,
                showScanner: true,
                // onChanged: controller.searchProducts,
                // onScannerTap: controller.scanBarcode,
              ),
              const SizedBox(height: 24),
              CustomFilterTabs(
                items: const ['All', 'Processing', 'Completed', 'Cancelled'],
                // selectedIndex: controller.selectedFilter.value,
                // onChanged: controller.changeFilter,
              ),
              SizedBox(height: 10),

              // --- Recent Sales List ---
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = transactions[index];

                  return CustomTransactionTile(
                    reference: item.reference,
                    dateTime: item.dateTime,
                    amount: item.amount,
                    status: item.status,
                    statusType: item.statusType,
                    onTap: () {
                      // Get.toNamed(...)
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
