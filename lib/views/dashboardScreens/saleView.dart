import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/controllers/sale_controller.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/cutom_TransactionTile.dart';
import '../../common/widgets/emptyfilter.dart';
import '../../common/widgets/product_shimmer.dart';


class SaleView extends StatelessWidget {
  SaleView({super.key});
  final SaleController controller = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchSales,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  title: AppConstants.saleTitle,
                  actions: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () => Get.toNamed(Routes.addSale),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          AppConstants.addSale,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 15),
              CustomSearchField(
                controller: controller.searchController,
                hintText: AppConstants.searchHint3,
                showScanner: false,
                onChanged: controller.searchSales,
              ),
              const SizedBox(height: 24),
              Obx(
                () => CustomFilterTabs(
                  items: controller.filters,
                  selectedIndex: controller.selectedFilter.value,
                  onChanged: controller.changeFilter,
                ),
              ),
              const SizedBox(height: 10),

              // --- Dynamic Sales List ---
              Obx(() {
                if (controller.isSalesLoading.value) {
                  return const ProductListShimmer(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  );
                }
                final salesList = controller.filteredSales;

                if (salesList.isEmpty) {
                  final bool isSearching = controller.searchQuery.value.isNotEmpty || controller.selectedFilter.value != 0;
                  return EmptyStateWidget(
                    isSearching: isSearching,
                    title: isSearching ? AppConstants.noSalesFound : AppConstants.noSalesYet,
                    subtitle: isSearching
                        ? AppConstants.changeSearchOrFilter
                        : AppConstants.completedSalesAppearHere,
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: salesList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final sale = salesList[index];

                    StatusType statusType = StatusType.neutral;
                    if (sale.status.toLowerCase() == 'completed') {
                      statusType = StatusType.success;
                    } else if (sale.status.toLowerCase() == 'void' || sale.status.toLowerCase() == 'cancelled') {
                      statusType = StatusType.error;
                    }

                    final dateStr = "${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}";

                    return CustomTransactionTile(
                      reference: sale.saleNo,
                      dateTime: dateStr,
                      amount: 'Rs. ${sale.totalAmount.toInt()}',
                      status: sale.status,
                      statusType: statusType,
                      onTap: () {
                        // Optional: Navigate to detail view
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    ));
  }
}
