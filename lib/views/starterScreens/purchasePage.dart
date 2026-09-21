import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../common/widgets/custom_statuschip.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/cutom_TransactionTile.dart';

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
              vertical: 16,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // APP BAR
                // =================================================

                CustomAppBar(
                  title: AppConstants.purchaseTitle,

                  actions: [
                    Expanded(
                      child: AppButton(
                        text: '+ Add',

                        onPressed: () {
                          Get.toNamed(
                            Routes.addPurchase,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // =================================================
                // SEARCH
                // =================================================

                CustomSearchField(
                  controller: controller.searchController,

                  hintText: 'Search purchase number...',

                  showScanner: false,

                  onChanged: controller.searchPurchases,
                ),

                const SizedBox(height: 24),

                // =================================================
                // FILTERS
                // =================================================

                Obx(
                      () => CustomFilterTabs(
                    items: controller.filters,

                    selectedIndex:
                    controller.selectedFilter.value,

                    onChanged: controller.changeFilter,
                  ),
                ),

                const SizedBox(height: 14),

                // =================================================
                // PURCHASE LIST
                // =================================================

                Obx(
                      () {
                    if (controller.isPurchasesLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final purchases =
                        controller.filteredPurchases;

                    if (purchases.isEmpty) {
                      return _EmptyPurchases(
                        isSearching:
                        controller.searchQuery.value.isNotEmpty ||
                            controller.selectedFilter.value != 0,
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
        return 'Completed';

      case 'void':
        return 'Cancelled';

      default:
        return status;
    }
  }

  StatusType _statusType(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
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

// ================================================================
// EMPTY STATE
// ================================================================

class _EmptyPurchases extends StatelessWidget {
  final bool isSearching;

  const _EmptyPurchases({
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(top: 30),

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),

      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF131D2E)
            : Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: context.isDark
              ? const Color(0xFF1E2D44)
              : const Color(0xFFE2E8F0),
        ),
      ),

      child: Column(
        children: [
          Icon(
            isSearching
                ? Icons.search_off_rounded
                : Icons.shopping_cart_outlined,

            size: 55,

            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 14),

          Text(
            isSearching
                ? 'No purchases found'
                : 'No purchases yet',

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isSearching
                ? 'Try changing your search or filter.'
                : 'Your completed purchases will appear here.',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}