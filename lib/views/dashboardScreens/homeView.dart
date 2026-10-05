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
import 'package:fl_chart/fl_chart.dart';
import '../../common/widgets/StandardScreen.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/premiumdial.dart';
import '../../controllers/dashboardController.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    final theme = context.appTheme;
    final double nameFontSize = controller.userName.length > AppConstants.spaceLG ? AppConstants.spaceMLG : AppConstants.spaceLXL;
    if (!Get.isRegistered<HomeController>()) {
      return const SizedBox.shrink();
    }

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
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
          Material(
            color: Colors.transparent,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(AppConstants.splashImage),
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
                        AppConstants.overview,
                        style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppConstants.trackYourPerformanceSubtitle,
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
                        _filterItem(
                          'today',
                          AppConstants.today,
                          Icons.today_rounded,
                        ),
                        _filterItem(
                          'yesterday',
                          AppConstants.yesterday,
                          Icons.history_rounded,
                        ),
                        _filterItem(
                          'week',
                          AppConstants.thisWeek,
                          Icons.date_range_rounded,
                        ),
                        _filterItem(
                          'month',
                          AppConstants.thisMonth,
                          Icons.calendar_month_rounded,
                        ),
                        _filterItem(
                          'custom',
                          AppConstants.customRange,
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
                                        Get.find<DashboardController>()
                                            .changePage(2);
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
                                      Get.find<DashboardController>()
                                          .changePage(2);
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
                                      AppConstants.saleSummary,
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
                                ],
                              ),
                              const SizedBox(height: AppConstants.spaceXL),
                              Obx(() {
                                if (controller.isLoading.value) {
                                  return Container(
                                    height: AppConstants.reportChartHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.47),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  height: AppConstants.reportChartHeight,
                                  child: _HomeSalesChart(
                                    controller: controller,
                                    theme: theme,
                                  ),
                                );
                              }),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
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
                                separatorBuilder: (
                                  BuildContext context,
                                  int index,
                                ) => const SizedBox(height: 10),
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
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                                value: (sale.percentage / 100)
                                                    .clamp(0.0, 1.0),
                                                minHeight: AppConstants
                                                    .reportProgressHeight,
                                                backgroundColor:
                                                    theme.surfaceMuted,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.primary),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
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
                                              style:
                                                  GoogleFonts.plusJakartaSans(
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
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

PopupMenuItem<String> _filterItem(String value, String label, IconData icon) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [Icon(icon, size: 18), const SizedBox(width: 10), Text(label)],
    ),
  );
}

class _SectionContainer extends StatelessWidget {
  final Widget child;
  final dynamic theme;

  const _SectionContainer({required this.child, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        bottom: AppConstants.spaceLG,
        left: AppConstants.spaceLG,
        right: AppConstants.spaceLG,
      ),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

class _HomeSalesChart extends StatelessWidget {
  final HomeController controller;
  final dynamic theme;

  const _HomeSalesChart({
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.chartData;

      if (data.isEmpty) {
        return Center(
          child: Text(
            'No sales data available',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: theme.textSecondary,
            ),
          ),
        );
      }

      final bool isSinglePoint = data.length == 1;

      final maxSales = data.fold<double>(
        0,
        (max, item) => item.salesAmount > max ? item.salesAmount : max,
      );

      final maxY = _niceMax(maxSales);
      final interval = maxY / 4;
      final filter = controller.dashboardFilter.value.toLowerCase();

      // Single day: show hourly bar chart
      if (isSinglePoint && (filter == 'today' || filter == 'yesterday')) {
        return _SingleDayChart(
          controller: controller,
          theme: theme,
          totalAmount: data.first.salesAmount,
          date: data.first.date,
          filter: filter,
        );
      }

      final List<FlSpot> spots;
      if (isSinglePoint) {
        spots = [FlSpot(1, data.first.salesAmount)];
      } else {
        spots = List.generate(
          data.length,
          (index) => FlSpot(index.toDouble(), data[index].salesAmount),
        );
      }

      return LineChart(
        LineChartData(
          minX: 0,
          maxX: isSinglePoint ? 2 : (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.border.withValues(alpha: 0.6),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _formatAmount(value),
                      style: GoogleFonts.plusJakartaSans(fontSize: 9, color: theme.textHint),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (isSinglePoint) {
                    if (value != 1) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        _formatDate(data.first.date),
                        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w500, color: theme.textHint),
                      ),
                    );
                  }

                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox.shrink();
                  final isLastIndex = index == data.length - 1;

                  if (filter == 'today' || filter == 'yesterday' || filter == 'week') {
                    return SideTitleWidget(
                      meta: meta,
                      child: Padding(
                        padding: EdgeInsets.only(right: isLastIndex ? 24.0 : 0.0),
                        child: Text(
                          _formatDate(data[index].date),
                          style: GoogleFonts.plusJakartaSans(fontSize: 9, color: theme.textHint),
                        ),
                      ),
                    );
                  }

                  if (_isMonthCenter(data, index)) {
                    return SideTitleWidget(
                      meta: meta,
                      child: Padding(
                        padding: EdgeInsets.only(right: isLastIndex ? 24.0 : 0.0),
                        child: Text(
                          _month(data[index].date.month),
                          style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w500, color: theme.textHint),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final int index = isSinglePoint ? 0 : spot.x.round();
                  if (index < 0 || index >= data.length) return null;
                  final item = data[index];
                  return LineTooltipItem(
                    '${_formatDate(item.date)}\n',
                    GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: 'Rs ${_formatAmount(item.salesAmount)}',
                        style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: theme.success,
              barWidth: 2.5,
              dotData: FlDotData(show: isSinglePoint),
              belowBarData: BarAreaData(
                show: !isSinglePoint,
                color: theme.success.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _month(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  bool _isMonthCenter(List<dynamic> data, int index) {
    final date = data[index].date;
    final indexes = <int>[];
    for (int i = 0; i < data.length; i++) {
      final d = data[i].date;
      if (d.year == date.year && d.month == date.month) indexes.add(i);
    }
    if (indexes.isEmpty) return false;
    return index == indexes[indexes.length ~/ 2];
  }

  double _niceMax(double value) {
    if (value <= 0)      return 100;
    if (value <= 100)    return (value / 20).ceil() * 20.0;
    if (value <= 1000)   return (value / 100).ceil() * 100.0;
    if (value <= 10000)  return (value / 1000).ceil() * 1000.0;
    if (value <= 100000) return (value / 10000).ceil() * 10000.0;
    return (value / 100000).ceil() * 100000.0;
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day}-${months[date.month - 1]}';
  }

  String _formatAmount(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000)    return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

// =============================================================
// SINGLE-DAY HOURLY BAR CHART
// =============================================================

class _TimeSlot {
  final String label;
  final int startHour;
  final int endHour;
  const _TimeSlot({required this.label, required this.startHour, required this.endHour});
}

class _SingleDayChart extends StatefulWidget {
  final HomeController controller;
  final dynamic theme;
  final double totalAmount;
  final DateTime date;
  final String filter;

  const _SingleDayChart({
    required this.controller,
    required this.theme,
    required this.totalAmount,
    required this.date,
    required this.filter,
  });

  @override
  State<_SingleDayChart> createState() => _SingleDayChartState();
}

class _SingleDayChartState extends State<_SingleDayChart> {
  static const _slots = [
    _TimeSlot(label: '12 AM', startHour: 0,  endHour: 4),
    _TimeSlot(label: '4 AM',  startHour: 4,  endHour: 8),
    _TimeSlot(label: '8 AM',  startHour: 8,  endHour: 12),
    _TimeSlot(label: '12 PM', startHour: 12, endHour: 16),
    _TimeSlot(label: '4 PM',  startHour: 16, endHour: 20),
    _TimeSlot(label: '8 PM',  startHour: 20, endHour: 24),
  ];

  int? _touchedIndex;

  List<double> _buildSlotAmounts(List sales) {
    final totals = List<double>.filled(_slots.length, 0.0);
    for (final sale in sales) {
      final hour = (sale.saleDate as DateTime).hour;
      for (int i = 0; i < _slots.length; i++) {
        if (hour >= _slots[i].startHour && hour < _slots[i].endHour) {
          totals[i] += (sale.totalAmount as double);
          break;
        }
      }
    }
    return totals;
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sales = widget.controller.daySales;
      final slotAmounts = _buildSlotAmounts(sales);
      final maxSlot = slotAmounts.reduce((a, b) => a > b ? a : b);
      final noSales = widget.totalAmount == 0;

      int peakIndex = 0;
      for (int i = 1; i < slotAmounts.length; i++) {
        if (slotAmounts[i] > slotAmounts[peakIndex]) peakIndex = i;
      }

      final dynamic theme = widget.theme;
      final Color barColor = theme.success as Color;

      if (noSales) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: (theme.textHint as Color).withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              'No sales recorded for ${widget.filter == 'today' ? 'today' : 'yesterday'}',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: theme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Sales will appear here once recorded',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textHint),
            ),
          ],
        );
      }

      final barGroups = List.generate(_slots.length, (i) {
        final isTouched = i == _touchedIndex;
        final isPeak = i == peakIndex && slotAmounts[i] > 0;

        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: slotAmounts[i],
              width: 22,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              color: isTouched
                  ? barColor
                  : isPeak
                      ? barColor.withValues(alpha: 0.9)
                      : barColor.withValues(alpha: 0.45),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxSlot > 0 ? maxSlot : 100,
                color: (theme.border as Color).withValues(alpha: 0.18),
              ),
            ),
          ],
        );
      });

      final touchedSlotLabel = _touchedIndex != null ? _slots[_touchedIndex!].label : null;
      final touchedAmount = _touchedIndex != null ? slotAmounts[_touchedIndex!] : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Sales', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textHint)),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${_fmt(widget.totalAmount)}',
                    style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: theme.textPrimary),
                  ),
                ],
              ),
              const Spacer(),
              if (touchedSlotLabel != null && touchedAmount != null && touchedAmount > 0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: barColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(touchedSlotLabel, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: theme.textSecondary)),
                      Text('Rs. ${_fmt(touchedAmount)}', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: barColor)),
                    ],
                  ),
                )
              else if (slotAmounts[peakIndex] > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: barColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, size: 13, color: barColor),
                      const SizedBox(width: 4),
                      Text('Peak: ${_slots[peakIndex].label}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: barColor)),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxSlot > 0 ? maxSlot * 1.25 : 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final amount = rod.toY;
                      if (amount <= 0) return null;
                      return BarTooltipItem(
                        'Rs ${_fmt(amount)}',
                        GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      if (response == null || response.spot == null || event is FlTapUpEvent || event is FlPanEndEvent) {
                        _touchedIndex = null;
                      } else {
                        _touchedIndex = response.spot!.touchedBarGroupIndex;
                      }
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(_fmt(value), style: GoogleFonts.plusJakartaSans(fontSize: 9, color: theme.textHint)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= _slots.length) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _slots[i].label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              color: i == _touchedIndex ? barColor : theme.textHint,
                              fontWeight: i == _touchedIndex ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxSlot > 0 ? maxSlot / 4 : 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: (theme.border as Color).withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
                groupsSpace: 8,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              _StatChip(icon: Icons.receipt_long_rounded, label: '${sales.length} sale${sales.length == 1 ? '' : 's'}', theme: theme),
              const SizedBox(width: 8),
              if (sales.isNotEmpty)
                _StatChip(icon: Icons.calculate_outlined, label: 'Avg Rs. ${_fmt(widget.totalAmount / sales.length)}', theme: theme),
            ],
          ),
        ],
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic theme;

  const _StatChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: (theme.border as Color).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textSecondary)),
        ],
      ),
    );
  }
}