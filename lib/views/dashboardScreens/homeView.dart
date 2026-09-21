import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/Custom_card.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/common/widgets/custom_header.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../controllers/dashboardController.dart';
import '../../controllers/allProductsController.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final productController = Get.find<ProductController>();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Fixed Greeting Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productController.getGreetingMessage(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Abubakar',
                            style: GoogleFonts.sora(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Today',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: theme.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Scrollable Content ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // --- Today's Sales (Main Full-Width Card Summary) ---
                    InkWell(
                      onTap: () {
                        Get.find<DashboardController>().changePage(1);
                      },
                      child: CardSummary(
                        title: AppConstants.todayCardSummary,
                        value: "Rs. 48,250",
                        subtitle: "32 sales today",
                        badgeText: "+12%",
                        icon: Icons.arrow_upward_rounded,
                        iconColor: const Color(0xFF2E7D32),
                        iconBackgroundColor: const Color(0xFFE8F5E9),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Summary Grid Layout (2 Columns) ---
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.find<DashboardController>().changePage(3);
                            },
                            child: CardSummary(
                              title: AppConstants.purchaseTitle,
                              value: 'Rs. 19,300',
                              subtitle: 'Today',
                              icon: Icons.receipt_long_outlined,
                              iconColor: const Color(0xFF00796B),
                              iconBackgroundColor: const Color(0xFFE0F2F1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CardSummary(
                            title: AppConstants.profitTitle,
                            value: 'Rs. 8,420',
                            subtitle: 'Today',
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xFF2E7D32),
                            iconBackgroundColor: const Color(0xFFE8F5E9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.find<DashboardController>().changePage(2);
                            },
                            child: Obx(() => CardSummary(
                                  title: AppConstants.totalProduct,
                                  value: productController.products.length.toString(),
                                  subtitle: 'In inventory',
                                  icon: Icons.grid_view_rounded,
                                  iconColor: const Color(0xFF1565C0),
                                  iconBackgroundColor: const Color(0xFFE3F2FD),
                                )),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CardSummary(
                            title: 'Low Stock',
                            value: '8 Items',
                            subtitle: 'Needs attention',
                            icon: Icons.warning_amber_rounded,
                            iconColor: const Color(0xFFC62828),
                            iconBackgroundColor: const Color(0xFFFFEBEE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // --- Quick Actions Section ---
                    CustomHeading(
                      title: AppConstants.quickAction,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionItem(
                            title: 'New Sale',
                            icon: Icons.add_shopping_cart_rounded,
                            color: const Color(0xFF2E7D32),
                            onTap: () {
                              Get.toNamed(Routes.addSale);
                            },
                          ),
                        ),
                        Expanded(
                          child: _QuickActionItem(
                            title: 'Add Purchase',
                            icon: Icons.assignment_turned_in_outlined,
                            color: const Color(0xFF00796B),
                            onTap: () {
                              Get.toNamed(Routes.addPurchase);
                            },
                          ),
                        ),
                        Expanded(
                          child: _QuickActionItem(
                            title: 'Add Product',
                            icon: Icons.add_box_outlined,
                            color: const Color(0xFF1565C0),
                            onTap: () {
                              Get.toNamed(Routes.addProductWizard);
                            },
                          ),
                        ),
                        Expanded(
                          child: _QuickActionItem(
                            title: 'Add Expense',
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
                      actionText: 'See All',
                      onPressed: () {
                        Get.find<DashboardController>().changePage(1);
                      },
                    ),
                    const SizedBox(height: 12),

                    // --- Recent Sales List ---
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final invoices = ['INV-1048', 'INV-1047', 'INV-1046'];
                        final times = ['Today, 10:42 AM', 'Today, 10:21 AM', 'Today, 9:55 AM'];
                        final amounts = ['Rs. 2,450', 'Rs. 12,960', 'Rs. 3,850'];

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
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.assignment_outlined,
                                  color: Color(0xFF2E7D32),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    invoices[index],
                                    style: GoogleFonts.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    times[index],
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
                                    amounts[index],
                                    style: GoogleFonts.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const CustomStatusChip(
                                    textTitle: 'Completed',
                                    type: StatusType.success,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
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
