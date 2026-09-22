import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/Custom_card.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/common/widgets/custom_header.dart';
import 'package:stockpulse/controllers/homecontroller.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../controllers/dashboardController.dart';
import '../../controllers/allProductsController.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final double nameFontSize = controller.userName.length > 16 ? 14 : 18;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchHomeData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.getGreetingMessage(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  controller.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.sora(
                                    fontSize: nameFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '👋',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.find<DashboardController>().changePage(1);
                              },
                              child: CardSummary(
                                title: AppConstants.saleTitle,
                                value: 'Rs. ${controller.totalSales.value.toInt()}',
                                icon: Icons.receipt_long_outlined,
                                iconColor: const Color(0xFF00796B),
                                iconBackgroundColor: const Color(0xFFE0F2F1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.find<DashboardController>().changePage(3);
                              },
                              child: CardSummary(
                                title: AppConstants.purchaseTitle,
                                value: 'Rs. ${controller.totalPurchases.value.toInt()}',
                                icon: Icons.trending_up_rounded,
                                iconColor: const Color(0xFF2E7D32),
                                iconBackgroundColor: const Color(0xFFE8F5E9),
                              ),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.find<DashboardController>().changePage(2);
                              },
                              child: Obx(() => CardSummary(
                                    title: AppConstants.totalProduct,
                                    value: controller.productController.products.length.toString(),
                                    icon: Icons.grid_view_rounded,
                                    iconColor: const Color(0xFF1565C0),
                                    iconBackgroundColor: const Color(0xFFE3F2FD),
                                  )),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Obx(() => CardSummary(
                              title: AppConstants.lowStockTitle,
                              value: '${controller.lowStockCount.value} Items',
                              icon: Icons.warning_amber_rounded,
                              iconColor: const Color(0xFFC62828),
                              iconBackgroundColor: const Color(0xFFFFEBEE),
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // --- Quick Actions Section ---
                      CustomHeading(
                        title: AppConstants.quickAction,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionItem(
                              title: AppConstants.newSale,
                              icon: Icons.add_shopping_cart_rounded,
                              color: const Color(0xFF2E7D32),
                              onTap: () async {
                                await Get.toNamed(Routes.addSale);
                                controller.fetchHomeData();
                              },
                            ),
                          ),
                          Expanded(
                            child: _QuickActionItem(
                              title: AppConstants.addPurchase,
                              icon: Icons.assignment_turned_in_outlined,
                              color: const Color(0xFF00796B),
                              onTap: () async {
                                await Get.toNamed(Routes.addPurchase);
                                controller.fetchHomeData();
                              },
                            ),
                          ),
                          Expanded(
                            child: _QuickActionItem(
                              title: AppConstants.addProducts,
                              icon: Icons.add_box_outlined,
                              color: const Color(0xFF1565C0),
                              onTap: () async {
                                await Get.toNamed(Routes.addProductWizard);
                                controller.fetchHomeData();
                              },
                            ),
                          ),
                          Expanded(
                            child: _QuickActionItem(
                              title: AppConstants.addExpenses,
                              icon: Icons.account_balance_wallet_outlined,
                              color: const Color(0xFFEF6C00),
                              onTap: () {
                                Get.toNamed(Routes.addExpense);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- Recent Sales Section ---
                      CustomHeading(
                        title: AppConstants.recentSales,
                        actionText: AppConstants.seeAll,
                        onPressed: () {
                          Get.find<DashboardController>().changePage(1);
                        },
                      ),
                      const SizedBox(height: 12),

                      // --- Recent Sales List ---
                      Obx(() {
                        if (controller.recentSales.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                AppConstants.noProductsAvailable,
                                style: GoogleFonts.plusJakartaSans(
                                  color: theme.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.recentSales.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final sale = controller.recentSales[index];
                            final dateStr = "${sale.saleDate.day}/${sale.saleDate.month} ${sale.saleDate.hour}:${sale.saleDate.minute.toString().padLeft(2, '0')}";

                            StatusType statusType = StatusType.neutral;
                            if (sale.status.toLowerCase() == 'completed') {
                              statusType = StatusType.success;
                            } else if (sale.status.toLowerCase() == 'void' || sale.status.toLowerCase() == 'cancelled') {
                              statusType = StatusType.error;
                            }

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: statusType == StatusType.success
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFFFF1F0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.assignment_outlined,
                                      color: statusType == StatusType.success
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFC62828),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sale.saleNo,
                                        style: GoogleFonts.sora(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        dateStr,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: theme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rs. ${sale.totalAmount.toInt()}',
                                        style: GoogleFonts.sora(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      CustomStatusChip(
                                        textTitle: sale.status.capitalizeFirst!,
                                        type: statusType,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.12)),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
