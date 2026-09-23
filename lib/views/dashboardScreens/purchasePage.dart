import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/custom_statuschip.dart';
import '../../common/widgets/cutom_TransactionTile.dart';

import '../../common/widgets/emptyfilter.dart';
import '../../common/widgets/product_shimmer.dart';
import '../../controllers/purchase_controller.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final PurchaseController controller =
    Get.find<PurchaseController>();

    return Scaffold(
      backgroundColor: theme.background,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchPurchases,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  title: Text(AppConstants.purchaseTitle),
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
                        onPressed: () => Get.toNamed(Routes.addPurchase),
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
                          AppConstants.addPurchase,
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
                  hintText: AppConstants.searchHint2,
                  showScanner: false,
                  onChanged: controller.searchPurchases,
                ),
                const SizedBox(height: 24),

                Obx(
                      () => CustomFilterTabs(
                    items: controller.filters,
                    selectedIndex:
                    controller.selectedFilter.value,
                    onChanged: controller.changeFilter,
                  ),
                ),

                const SizedBox(height: 14),
                Obx(
                      () {
                        if (controller.isPurchasesLoading.value) {
                          return const ProductListShimmer(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                          );
                        }
                    final purchases =
                        controller.filteredPurchases;

                    if (purchases.isEmpty) {
                      final bool isSearching = controller.searchQuery.value.isNotEmpty || controller.selectedFilter.value != 0;
                      return EmptyStateWidget(
                        isSearching: isSearching,
                        title: isSearching ? AppConstants.noPurchasesFoundTitle : AppConstants.noPurchasesYetTitle,
                        subtitle: isSearching
                            ? AppConstants.noPurchasesFoundSubtitle
                            : AppConstants.noPurchasesYetSubtitle,
                      );
                    }

                    return _buildCardGroup(
                      context,
                      [
                        ListView.separated(
                          shrinkWrap: true,

                          physics:
                          const NeverScrollableScrollPhysics(),

                          itemCount: purchases.length,

                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),

                          itemBuilder: (context, index) {
                            final purchase =
                            purchases[index];

                            return CustomTransactionTile(
                              reference:
                              purchase.purchaseNo,

                              dateTime:
                              _formatPurchaseDate(
                                purchase.purchaseDate,
                              ),

                              amount:
                              'Rs. ${purchase.totalAmount.toStringAsFixed(2)}',

                              status:
                              _statusLabel(
                                purchase.status,
                              ),

                              statusType:
                              _statusType(
                                purchase.status,
                              ),

                              onTap: () {
                                // Purchase details will be
                                // implemented next.
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCardGroup(
      BuildContext context,
      List<Widget> children,
      ) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF131D2E)
            : Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: isDark
              ? const Color(0xFF1E2D44)
              : const Color(0xFFE2E8F0),
        ),
      ),

      child: Column(
        children: children,
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

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final purchaseDay = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    final yesterday =
    today.subtract(const Duration(days: 1));

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

    final hour12 =
    localDate.hour == 0
        ? 12
        : localDate.hour > 12
        ? localDate.hour - 12
        : localDate.hour;

    final minute =
    localDate.minute.toString().padLeft(2, '0');

    final period =
    localDate.hour >= 12 ? 'PM' : 'AM';

    return '$day, '
        '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }
}

