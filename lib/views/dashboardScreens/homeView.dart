import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/Custom_card.dart';
import 'package:stockpulse/common/widgets/custom_header.dart';
import 'package:stockpulse/controllers/homecontroller.dart';
import 'package:stockpulse/services/role_service.dart';
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
    if (!Get.isRegistered<HomeController>()) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<HomeController>();
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
                        final roleService = Get.isRegistered<RoleService>()
                            ? Get.find<RoleService>()
                            : Get.put(RoleService(), permanent: true);

                        if (controller.isLoading.value) {
                          return _buildShimmerCards();
                        }

                        if (!roleService.canManagePurchases) {
                          // Staff view: Hide purchases card & chart
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: roleService.canViewReports
                                          ? () => Get.toNamed(Routes.saleReport)
                                          : null,
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
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
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
                        }

                        // Owner view: Show all cards and chart
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
                      const SizedBox(height: 18),
                      Obx(() {
                        final roleService = Get.isRegistered<RoleService>()
                            ? Get.find<RoleService>()
                            : Get.put(RoleService(), permanent: true);

                        if (!roleService.canManagePurchases) {
                          return const SizedBox.shrink();
                        }

                        return _SectionContainer(
                          theme: theme,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
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
                                child: _SalesPurchaseChart(
                                  controller: controller,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

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
                                    itemCount: controller.categorySales.length,
                                    separatorBuilder: (BuildContext context, int index) =>
                                    const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final sale = controller.categorySales[index];
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
                                                color:  const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.assignment_outlined,
                                                color: const Color(0xFF2E7D32),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sale.name,
                                                  style: GoogleFonts.sora(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                SizedBox(
                                                  width: 140,
                                                  child: LinearProgressIndicator(
                                                    value: (sale.percentage / 100).clamp(0.0, 1.0),
                                                    minHeight: AppConstants.reportProgressHeight,
                                                    backgroundColor: theme.surfaceMuted,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Rs. ${sale.amount.toInt()}',
                                                  style: GoogleFonts.sora(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: theme.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                    '${sale.percentage.toInt()} %',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 12,
                                                    color: theme.textSecondary,
                                                  ),
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
      floatingActionButton: Obx(() {
        final roleService = Get.find<RoleService>();

        return roleService.isOwner
            ? Container(
          margin: EdgeInsets.only(
            bottom: 12,
            right: AppConstants.spaceSM,
          ),
          child: PremiumSpeedDial(
            onRefresh: () async {
              await controller.fetchHomeData();
            },
          ),
        )
            : Container(
          margin: EdgeInsets.only(
            bottom: 12,
            right: AppConstants.spaceSM,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F766E),
                Color(0xFF14B8A6),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: FloatingActionButton.extended(
            heroTag: 'staffAddSaleFab',
            onPressed: () => Get.toNamed(Routes.addSale),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add),
            label: const Text(
              AppConstants.addSale,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
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


class _SalesPurchaseChart extends StatefulWidget {
  final HomeController controller;
  final dynamic theme;

  const _SalesPurchaseChart({
    required this.controller,
    required this.theme,
  });

  @override
  State<_SalesPurchaseChart> createState() =>
      _SalesPurchaseChartState();
}

class _SalesPurchaseChartState extends State<_SalesPurchaseChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = widget.controller.chartData;

      if (data.isEmpty) {
        return Center(
          child: Text(
            'No chart data available',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: widget.theme.textSecondary,
            ),
          ),
        );
      }

      final rawMax = data.fold<double>(0, (prev, item) {
        final value = item.salesAmount > item.purchaseAmount
            ? item.salesAmount
            : item.purchaseAmount;

        return value > prev ? value : prev;
      });

      final maxVal = _getNiceMax(rawMax);

      const ySteps = 4;

      final filter = widget.controller.dashboardFilter.value.toLowerCase();

      final showXAxis =
          filter == 'today' ||
          filter == 'yesterday' ||
          filter == 'week';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =============================
          // Y AXIS
          // =============================
          SizedBox(
            width: 42,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: showXAxis ? 28 : 0,
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: List.generate(
                  ySteps + 1,
                      (index) {
                    final value =
                        maxVal -
                            ((maxVal / ySteps) * index);

                    return Text(
                      _formatAmount(value),
                      style:
                      GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: widget.theme.textHint,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // =============================
          // CHART
          // =============================
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // =========================
                      // GRID LINES
                      // =========================
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: List.generate(
                            ySteps + 1,
                                (_) => Container(
                              height: 1,
                              color: widget.theme.border
                                  .withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // =========================
                      // BARS
                      // =========================
                      Positioned.fill(
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: List.generate(
                            data.length,
                                (index) {
                              final item =
                              data[index];

                              final salesHeight =
                              maxVal == 0
                                  ? 0.0
                                  : item.salesAmount /
                                  maxVal;

                              final purchaseHeight =
                              maxVal == 0
                                  ? 0.0
                                  : item.purchaseAmount /
                                  maxVal;

                              final isSelected =
                                  selectedIndex == index;

                              return Expanded(
                                child: GestureDetector(
                                  behavior:
                                  HitTestBehavior
                                      .translucent,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex =
                                      selectedIndex ==
                                          index
                                          ? null
                                          : index;
                                    });
                                  },
                                  child: Stack(
                                    clipBehavior:
                                    Clip.none,
                                    alignment:
                                    Alignment
                                        .bottomCenter,
                                    children: [
                                      // =================
                                      // BAR GROUP
                                      // =================
                                      Positioned.fill(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                            horizontal:
                                            1.5,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .end,
                                            children: [
                                              // SALES
                                              Expanded(
                                                child:
                                                FractionallySizedBox(
                                                  heightFactor:
                                                  salesHeight
                                                      .clamp(
                                                    0.02,
                                                    1.0,
                                                  ),
                                                  alignment:
                                                  Alignment
                                                      .bottomCenter,
                                                  child:
                                                  Container(
                                                    decoration:
                                                    BoxDecoration(
                                                      color: widget
                                                          .theme
                                                          .success,
                                                      borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                        top: Radius.circular(
                                                          AppConstants
                                                              .radiusXS,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(
                                                width: 1,
                                              ),

                                              // PURCHASE
                                              Expanded(
                                                child:
                                                FractionallySizedBox(
                                                  heightFactor:
                                                  purchaseHeight
                                                      .clamp(
                                                    0.02,
                                                    1.0,
                                                  ),
                                                  alignment:
                                                  Alignment
                                                      .bottomCenter,
                                                  child:
                                                  Container(
                                                    decoration:
                                                    BoxDecoration(
                                                      color: widget
                                                          .theme
                                                          .primary,
                                                      borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                        top: Radius.circular(
                                                          AppConstants
                                                              .radiusXS,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // =================
                                      // TOOLTIP
                                      // =================
                                      if (isSelected)
                                        Positioned(
                                          bottom:
                                          _tooltipBottom(
                                            salesHeight,
                                            purchaseHeight,
                                            context,
                                          ),
                                          child:
                                          _ChartTooltip(
                                            item: item,
                                            theme:
                                            widget.theme,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =============================
                // X AXIS
                // =============================
                if (showXAxis) ...[
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 20,
                    child: Row(
                      children: List.generate(
                        data.length,
                        (index) {
                          final item = data[index];

                          return Expanded(
                            child: Center(
                              child: Text(
                                _formatXAxisDate(item.date),
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: widget.theme.textHint,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  double _tooltipBottom(
      double salesHeight,
      double purchaseHeight,
      BuildContext context,
      ) {
    final highest = salesHeight > purchaseHeight
        ? salesHeight
        : purchaseHeight;

    // Approximate chart height minus X axis.
    final chartHeight =
        AppConstants.reportChartHeight - 30;

    return (highest * chartHeight) + 8;
  }

  String _formatXAxisDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day}-${months[date.month - 1]}';
  }

  double _getNiceMax(double value) {
    if (value <= 0) return 100;

    if (value <= 100) {
      return (value / 20).ceil() * 20.0;
    }

    if (value <= 1000) {
      return (value / 100).ceil() * 100.0;
    }

    if (value <= 10000) {
      return (value / 1000).ceil() * 1000.0;
    }

    if (value <= 100000) {
      return (value / 10000).ceil() * 10000.0;
    }

    if (value <= 1000000) {
      return (value / 100000).ceil() * 100000.0;
    }

    return (value / 1000000)
        .ceil() *
        1000000.0;
  }

  String _formatAmount(double value) {
    if (value >= 1000000) {
      final result = value / 1000000;

      return result ==
          result.roundToDouble()
          ? '${result.toInt()}M'
          : '${result.toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      final result = value / 1000;

      return result ==
          result.roundToDouble()
          ? '${result.toInt()}K'
          : '${result.toStringAsFixed(1)}K';
    }

    return value.toInt().toString();
  }
}

class _ChartTooltip extends StatelessWidget {
  final dynamic item;
  final dynamic theme;

  const _ChartTooltip({
    required this.item,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            '${item.date.day} ${_month(item.date.month)} ${item.date.year}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          _TooltipValue(
            color: theme.success,
            label: 'Sales',
            value:
            'Rs ${item.salesAmount.toStringAsFixed(0)}',
            theme: theme,
          ),

          const SizedBox(height: 4),

          _TooltipValue(
            color: theme.primary,
            label: 'Purchases',
            value:
            'Rs ${item.purchaseAmount.toStringAsFixed(0)}',
            theme: theme,
          ),
        ],
      ),
    );
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}
class _TooltipValue extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final dynamic theme;

  const _TooltipValue({
    required this.color,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              color: theme.textSecondary,
            ),
          ),
        ),

        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }
}