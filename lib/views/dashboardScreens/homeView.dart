import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/Custom_card.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/common/widgets/custom_header.dart';
import 'package:stockpulse/controllers/homecontroller.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/StandardScreen.dart';
import '../../common/widgets/alertDialog.dart';
import '../../common/widgets/premiumdial.dart';
import '../../controllers/dashboardController.dart';
import '../../controllers/loginController.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final double nameFontSize = controller.userName.length > AppConstants.spaceLG ? AppConstants.spaceMLG : AppConstants.spaceLXL;

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: AppColors.onboardingLight,
        elevation: 5,
        title: Column(
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
                const Text('👋', style: TextStyle(fontSize: 20)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
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
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.logout,
                  size: 20,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchHomeData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Track your performance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Filter here
                  Obx(
                    () => PopupMenuButton<String>(
                      onSelected: controller.changeDashboardFilter,
                      offset: const Offset(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: theme.card,

                      itemBuilder: (context) => [
                        _filterItem('today', 'Today', Icons.today_rounded),
                        _filterItem('yesterday', 'Yesterday', Icons.history_rounded),
                        _filterItem('week', 'This Week', Icons.date_range_rounded),
                        _filterItem('month', 'This Month', Icons.calendar_month_rounded),
                        _filterItem(
                          'custom',
                          'Custom Range',
                          Icons.tune_rounded,
                        ),
                      ],

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: theme.primary,
                            ),

                            const SizedBox(width: 7),

                            Text(
                              controller.dashboardFilterLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),

                            const SizedBox(width: 4),

                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: theme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return _buildShimmerCards();
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.toNamed(Routes.saleReport);
                                    },
                                    child: SummaryCard(
                                      title: AppConstants.saleTitle,
                                      value:
                                          'Rs. ${controller.totalSales.value.toInt()}',
                                      icon: CupertinoIcons.cart,
                                      iconColor: const Color(0xFF00796B),
                                      percentage: '',
                                      theme: theme,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.toNamed(Routes.purchaseReport);
                                    },
                                    child: SummaryCard(
                                      title: AppConstants.purchaseTitle,
                                      value:
                                          'Rs. ${controller.totalPurchases.value.toInt()}',
                                      icon: CupertinoIcons.cube_box,
                                      iconColor: const Color(0xFF2E7D32),
                                      percentage: '',
                                      theme: theme,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.find<DashboardController>().changePage(2);
                                    },
                                    child: SummaryCard(
                                      title: AppConstants.totalProduct,
                                      value: controller
                                          .productController
                                          .products
                                          .length
                                          .toString(),
                                      icon: Icons.grid_view_rounded,
                                      iconColor: const Color(0xFF1565C0),
                                      percentage: '',
                                      theme: theme,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: SummaryCard(
                                    title: AppConstants.lowStockTitle,
                                    value:
                                        '${controller.lowStockCount.value} Items',
                                    icon: CupertinoIcons.cube_box,
                                    iconColor: const Color(0xFFC62828),
                                    percentage: '',
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 18,),
                      _SectionContainer(
                        theme: theme,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(height: 12,),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppConstants.salesVsPurchases,
                                    style: GoogleFonts.sora(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                ),


                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceLG),

                            Row(
                              children: [
                                _Legend(
                                  title: AppConstants.saleTitle,
                                  color: theme.success,
                                  theme: theme,
                                ),
                                const SizedBox(width: AppConstants.spaceLG),
                                _Legend(
                                  title: AppConstants.purchaseTitle,
                                  color: theme.primary,
                                  theme: theme,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceXL),

                            SizedBox(
                              height: AppConstants.reportChartHeight,
                              child: _SalesPurchaseChart(theme: theme),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceLG),
                      const SizedBox(height: 18),


                      // --- Recent Sales Section ---
                      _SectionContainer(
                        theme: theme,
                        child: Column(
                              children: [
                                CustomHeading(
                                  title: AppConstants.topSellingProducts,
                                  actionText: AppConstants.seeAll,
                                  onPressed: () {
                                    Get.find<DashboardController>().changePage(2);
                                  },
                                ),
                                const SizedBox(height: 12),

                                // --- Recent Sales List ---
                                Obx(() {
                                  if (controller.isLoading.value) {
                                    return _buildShimmerRecentSales();
                                  }

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
                                    separatorBuilder: (BuildContext context, int index) =>
                                    const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final sale = controller.recentSales[index];
                                      final dateStr =
                                          "${sale.saleDate.day}/${sale.saleDate.month} ${sale.saleDate.hour}:${sale.saleDate.minute.toString().padLeft(2, '0')}";

                                      StatusType statusType = StatusType.neutral;
                                      if (sale.status.toLowerCase() == 'completed') {
                                        statusType = StatusType.success;
                                      } else if (sale.status.toLowerCase() == 'void' ||
                                          sale.status.toLowerCase() == 'cancelled') {
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
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 12,right: AppConstants.spaceSM),
        child: PremiumSpeedDial(
          onRefresh: () async {
            await controller.fetchHomeData();
          },
        ),
      ),
    );
  }

  Widget _buildShimmerCards() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerRecentSales() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

PopupMenuItem<String> _filterItem(
    String value,
    String label,
    IconData icon,
    ) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(label),
      ],
    ),
  );
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
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
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

class _SectionContainer extends StatelessWidget {
  final Widget child;
  final dynamic theme;

  const _SectionContainer({
    required this.child,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom:AppConstants.spaceLG,left: AppConstants.spaceLG,right: AppConstants.spaceLG,),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: theme.border),
      ),
      child: child,
    );
  }
}
class _Legend extends StatelessWidget {
  final String title;
  final Color color;
  final dynamic theme;

  const _Legend({
    required this.title,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppConstants.spaceMD,
          height: AppConstants.spaceMD,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spaceXS),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SalesPurchaseChart extends StatelessWidget {
  final dynamic theme;

  const _SalesPurchaseChart({
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    const salesValues = [
      0.45,
      0.60,
      0.78,
      0.55,
      0.70,
      0.92,
      0.66,
      0.83,
    ];

    const purchaseValues = [
      0.30,
      0.72,
      0.48,
      0.63,
      0.57,
      0.76,
      0.40,
      0.61,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        salesValues.length,
            (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceXXS,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: salesValues[index],
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.success,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppConstants.radiusXS),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppConstants.spaceXXS),

                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: purchaseValues[index],
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppConstants.radiusXS),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}