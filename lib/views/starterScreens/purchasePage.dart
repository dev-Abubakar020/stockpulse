import 'package:flutter/material.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custome_appbar.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../common/widgets/custom_statuschip.dart';
import '../../common/widgets/custome_button.dart';
import '../../common/widgets/cutom_TransactionTile.dart';
import '../../models/TransactionItemModel.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final transactions = [
      const TransactionItem(
        reference: 'PUR-0024',
        name:'Muhammad Ali',
        dateTime: 'Today, 10:42 AM',
        amount: 'Rs. 2,450',
        status: 'Completed',
        statusType: StatusType.success,
      ),

      const TransactionItem(
        reference: 'PUR-0025',
        name:'Muhammad Ali',
        dateTime: 'Today, 10:21 AM',
        amount: 'Rs. 12,960',
        status: 'Processing',
        statusType: StatusType.info,
      ),

      const TransactionItem(
        reference: 'PUR-0026',
        name:'Muhammad Ali',
        dateTime: 'Today, 09:55 AM',
        amount: 'Rs. 3,850',
        status: 'Pending',
        statusType: StatusType.warning,
      ),

      const TransactionItem(
        reference: 'PUR-0027',
        name:'Muhammad Ali',
        dateTime: 'Yesterday, 06:30 PM',
        amount: 'Rs. 1,250',
        status: 'Cancelled',
        statusType: StatusType.error,
      ),
    ];
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomeAppBar(
                title: AppConstants.purchaseTitle,
                actions: [
                  Expanded(child: AppButton(text: '+ Add', onPressed: () {  },))
                ],
              ),
              SizedBox(height: 15,),
              CustomSearchField(
                // controller: controller.searchController,
                hintText: AppConstants.searchHint1,
                showScanner: false,
                // onChanged: controller.searchProducts,
                // onScannerTap: controller.scanBarcode,
              ),
              const SizedBox(height: 24),
              CustomFilterTabs(
                items: const [
                  'All',
                  'Completed',
                  'Cancelled',
                ],
                // selectedIndex: controller.selectedFilter.value,
                // onChanged: controller.changeFilter,
              ),
              SizedBox(height: 10,),

              _buildCardGroup([
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                )
              ])
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }
}

