import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../../common/widgets/CustomSearchField.dart';
import '../../../common/widgets/Custom_filter.dart';
import '../../../common/widgets/alertDialog.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/custom_statuschip.dart';
import '../../../common/widgets/cutom_TransactionTile.dart';

import '../../../common/widgets/emptyfilter.dart';
import '../../../common/widgets/product_shimmer.dart';
import '../../../controllers/purchase_controller.dart';
import '../../../controllers/loginController.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final PurchaseController controller = Get.find<PurchaseController>();

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: Text(AppConstants.purchaseTitle),
        actions: [
          IconButton(onPressed: (){
            Get.dialog(
              CustomConfirmDialog(
                title: AppConstants.logout,
                subtitle: AppConstants.logoutAlertSubTitle,
                confirmText: AppConstants.logout,
                onConfirm: () {
                  Get.back();
                  Get.find<LoginController>().logout();
                },
              ),
            );
          },
            icon: Material(
              color: Colors.transparent,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red
                        .withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.logout,
                  size: 20,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
              ),
            ),),
        ],
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSearchField(
                controller: controller.searchController,
                hintText: AppConstants.searchHint2,
                showScanner: false,
                onChanged: controller.searchPurchases,
              ),
              const SizedBox(height: 14),

              Obx(
                () => CustomFilterTabs(
                  items: controller.filters,
                  selectedIndex: controller.selectedFilter.value,
                  onChanged: controller.changeFilter,
                ),
              ),
            ],
          ),

          Expanded(
            child: Obx(() {
              if (controller.isPurchasesLoading.value) {
                return Padding(
                  padding: const EdgeInsets.only(top:12),
                  child: const ProductListShimmer(),
                );
              }
              final purchases = controller.filteredPurchases;
              if (purchases.isEmpty) {
                final bool isSearching =
                    controller.searchQuery.value.isNotEmpty ||
                    controller.selectedFilter.value != 0;
                return Padding(
                  padding: const EdgeInsets.only(
                  top:12
                  ),
                  child: EmptyStateWidget(
                    isSearching: isSearching,
                    title: isSearching
                        ? AppConstants.noPurchasesFoundTitle
                        : AppConstants.noPurchasesYetTitle,
                    subtitle: isSearching
                        ? AppConstants.noPurchasesFoundSubtitle
                        : AppConstants.noPurchasesYetSubtitle,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchPurchases,
                child: ListView.separated(
                  padding: const EdgeInsets.only(top:12),
                  itemCount: purchases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final purchase = purchases[index];

                    return CustomTransactionTile(
                      reference: purchase.purchaseNo,

                      dateTime: _formatPurchaseDate(purchase.purchaseDate),

                      amount:
                          'Rs. ${purchase.totalAmount.toStringAsFixed(2)}',

                      status: _statusLabel(purchase.status),

                      statusType: _statusType(purchase.status),

                      onTap: () {
                        Get.toNamed(Routes.purchaseDetail, arguments: purchase);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),

      /// Floating Action Button
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 12,right: AppConstants.spaceSM),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.addPurchase),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add),
          label: const Text(
            AppConstants.addPurchase,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppConstants.completedLabel;

      case 'void':
        return AppConstants.cancelledLabel;

      default:
        return status;
    }
  }

  StatusType _statusType(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.completedLabel:
        return StatusType.success;

      case 'void':
        return StatusType.error;

      default:
        return StatusType.info;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatPurchaseDate(DateTime date) {
    final localDate = date.toLocal();

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final purchaseDay = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    final yesterday = today.subtract(const Duration(days: 1));

    String day;

    if (purchaseDay == today) {
      day = 'Today';
    } else if (purchaseDay == yesterday) {
      day = 'Yesterday';
    } else {
      day =
          '${localDate.day.toString().padLeft(2, '0')}/'
          '${localDate.month.toString().padLeft(2, '0')}/'
          '${localDate.year}';
    }

    final hour12 = localDate.hour == 0
        ? 12
        : localDate.hour > 12
        ? localDate.hour - 12
        : localDate.hour;

    final minute = localDate.minute.toString().padLeft(2, '0');

    final period = localDate.hour >= 12 ? 'PM' : 'AM';

    return '$day, '
        '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }
}
