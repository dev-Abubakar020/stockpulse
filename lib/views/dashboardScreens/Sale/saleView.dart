import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/controllers/sale_controller.dart';
import 'package:stockpulse/controllers/loginController.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../../common/widgets/CustomSearchField.dart';
import '../../../common/widgets/Custom_filter.dart';
import '../../../common/widgets/alertDialog.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/cutom_TransactionTile.dart';
import '../../../common/widgets/emptyfilter.dart';
import '../../../common/widgets/product_shimmer.dart';

class SaleView extends StatelessWidget {
  SaleView({super.key});
  final SaleController controller = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: Text(AppConstants.saleTitle),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchField(
                    controller: controller.searchController,
                    hintText: AppConstants.searchHint3,
                    showScanner: false,
                    onChanged: controller.searchSales,
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
            ),
            Expanded(
              child: Obx(() {
                if (controller.isSalesLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: const ProductListShimmer(),
                  );
                }
                final salesList = controller.filteredSales;

                if (salesList.isEmpty) {
                  final bool isSearching =
                      controller.searchQuery.value.isNotEmpty ||
                      controller.selectedFilter.value != 0;
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 6,
                    ),
                    child: EmptyStateWidget(
                      isSearching: isSearching,
                      title: isSearching
                          ? AppConstants.noSalesFound
                          : AppConstants.noSalesYet,
                      subtitle: isSearching
                          ? AppConstants.changeSearchOrFilter
                          : AppConstants.completedSalesAppearHere,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchSales,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: salesList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sale = salesList[index];

                      StatusType statusType = StatusType.neutral;
                      if (sale.status.toLowerCase() == 'completed') {
                        statusType = StatusType.success;
                      } else if (sale.status.toLowerCase() == 'void' ||
                          sale.status.toLowerCase() == 'cancelled') {
                        statusType = StatusType.error;
                      }

                      final dateStr =
                          "${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}";

                      return CustomTransactionTile(
                        reference: sale.saleNo,
                        dateTime: dateStr,
                        amount: 'Rs. ${sale.totalAmount.toInt()}',
                        status: sale.status,
                        statusType: statusType,
                        onTap: () {
                          Get.toNamed(Routes.saleDetail, arguments: sale);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      /// Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 12,right: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.addSale),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add),
          label: const Text(
            AppConstants.addSale,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
