import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/Custom_filter.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/appbar.dart';
import 'package:stockpulse/controllers/dashboardController.dart';
import 'package:stockpulse/controllers/sale_report_Controller.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../common/widgets/Custom_card.dart';

class SaleReport extends GetView<SaleReportController> {
  const SaleReport({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return CustomScreen(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppConstants.salesReport,
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.fetchReport(),
            icon: const Icon(
              CupertinoIcons.refresh,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppConstants.spaceMD,
                  bottom: AppConstants.spaceXXL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFilterTabs(
                      items: const ['Daily', 'Monthly', 'Custom'],
                      selectedIndex: controller.selectedFilter.value == 'Daily'
                          ? 0
                          : controller.selectedFilter.value == 'Monthly'
                              ? 1
                              : 2,
                      onChanged: (index) {
                        final filter = index == 0
                            ? 'Daily'
                            : index == 1
                                ? 'Monthly'
                                : 'Custom';
                        controller.changeFilter(filter);
                      },
                    ),

                    const SizedBox(height: AppConstants.spaceLG),

                    _PeriodSelector(theme: theme, controller: controller),

                    const SizedBox(height: AppConstants.spaceLG),

                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: AppConstants.totalSales,
                            value: 'Rs ${controller.totalSales.value.toStringAsFixed(0)}',
                            percentage: '${controller.salesPercentage.value >= 0 ? '+' : ''}${controller.salesPercentage.value.toStringAsFixed(1)}%',
                            positive: controller.salesPercentage.value >= 0,
                            icon: Icons.payments_outlined,
                            iconColor: theme.sales,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMD),
                        Expanded(
                          child: SummaryCard(
                            title: AppConstants.totalInvoices,
                            value: '${controller.totalInvoices.value}',
                            percentage: '${controller.invoicesPercentage.value >= 0 ? '+' : ''}${controller.invoicesPercentage.value.toStringAsFixed(1)}%',
                            positive: controller.invoicesPercentage.value >= 0,
                            icon: Icons.receipt_long_outlined,
                            iconColor: theme.primary,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spaceMD),

                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: AppConstants.averageSale,
                            value: 'Rs ${controller.averageSale.value.toStringAsFixed(2)}',
                            percentage: '${controller.averageSalePercentage.value >= 0 ? '+' : ''}${controller.averageSalePercentage.value.toStringAsFixed(1)}%',
                            positive: controller.averageSalePercentage.value >= 0,
                            icon: Icons.trending_up_rounded,
                            iconColor: theme.profit,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMD),
                        Expanded(
                          child: SummaryCard(
                            title: AppConstants.itemsSold,
                            value: '${controller.itemsSold.value.toStringAsFixed(0)}',
                            percentage: '${controller.itemsSoldPercentage.value >= 0 ? '+' : ''}${controller.itemsSoldPercentage.value.toStringAsFixed(1)}%',
                            positive: controller.itemsSoldPercentage.value >= 0,
                            icon: Icons.inventory_2_outlined,
                            iconColor: theme.purchases,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spaceLG),

                    _ReportSection(
                      theme: theme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: AppConstants.salesOverview,
                            theme: theme,
                          ),
                          const SizedBox(height: AppConstants.spaceXS),
                          Text(
                            AppConstants.salesPerformanceSubtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXL),
                          SizedBox(
                            height: AppConstants.reportChartHeight,
                            width: double.infinity,
                            child: _SalesChart(
                              theme: theme,
                              chartData: controller.chartData,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceLG),

                    _ReportSection(
                      theme: theme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: AppConstants.salesByCategory,
                            theme: theme,
                          ),
                          const SizedBox(height: AppConstants.spaceLG),
                          if (controller.categorySales.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'No category data available',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: theme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...controller.categorySales.map((catReport) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppConstants.spaceLG),
                                child: _CategoryProgress(
                                  title: catReport.name,
                                  amount: 'Rs ${catReport.amount.toStringAsFixed(0)}',
                                  percentage: catReport.percentage.round(),
                                  color: theme.sales,
                                  theme: theme,
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceLG),

                    _ReportSection(
                      theme: theme,
                      child: Column(
                        children: [
                          _SectionHeader(
                            title: AppConstants.recentSales,
                            actionText: AppConstants.viewAll,
                            onViewAll: () {
                              Get.back();
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>().changePage(1);
                              }
                            },
                            theme: theme,
                          ),
                          const SizedBox(height: AppConstants.spaceMD),
                          if (controller.recentSales.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'No recent sales found',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: theme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...controller.recentSales.map((sale) {
                              return Column(
                                children: [
                                  _SaleItem(
                                    invoice: sale.saleNo.isNotEmpty ? sale.saleNo : 'INV-${sale.id.substring(0, 6)}',
                                    customer: 'Payment: ${sale.paymentMethod.capitalizeFirst}',
                                    date: DateFormat('dd MMM, hh:mm a').format(sale.saleDate),
                                    items: sale.status.capitalizeFirst ?? 'Completed',
                                    amount: 'Rs ${sale.totalAmount.toStringAsFixed(0)}',
                                    theme: theme,
                                  ),
                                  Divider(
                                    height: AppConstants.spaceXXL,
                                    color: theme.divider,
                                  ),
                                ],
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final AppThemeHelper theme;
  final SaleReportController controller;

  const _PeriodSelector({
    required this.theme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSM,
        vertical: AppConstants.spaceXS,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(
          AppConstants.radiusMD,
        ),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Row(
        children: [
          if (controller.selectedFilter.value != 'Custom')
            IconButton(
              onPressed: () => controller.previousPeriod(),
              icon: Icon(
                CupertinoIcons.chevron_left,
                size: AppConstants.iconSM,
                color: theme.textPrimary,
              ),
            )
          else
            const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  controller.periodTitle,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXXS),
                Text(
                  controller.periodSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (controller.selectedFilter.value != 'Custom' && controller.hasNextPeriod)
            IconButton(
              onPressed: () => controller.nextPeriod(),
              icon: Icon(
                CupertinoIcons.chevron_right,
                size: AppConstants.iconSM,
                color: theme.textPrimary,
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final Widget child;
  final AppThemeHelper theme;

  const _ReportSection({
    required this.child,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppConstants.spaceLG,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(
          AppConstants.radiusLG,
        ),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onViewAll;
  final AppThemeHelper theme;

  const _SectionHeader({
    required this.title,
    required this.theme,
    this.actionText,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
        ),
        if (actionText != null && onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(
              AppConstants.radiusSM,
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                AppConstants.spaceXS,
              ),
              child: Text(
                actionText!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  final String title;
  final String amount;
  final int percentage;
  final Color color;
  final AppThemeHelper theme;

  const _CategoryProgress({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: AppConstants.spaceSM,
              height: AppConstants.spaceSM,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            SizedBox(
              width: 35,
              child: Text(
                '$percentage%',
                textAlign: TextAlign.end,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceSM),
        ClipRRect(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusXL,
          ),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: AppConstants.reportProgressHeight,
            backgroundColor: theme.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaleItem extends StatelessWidget {
  final String invoice;
  final String customer;
  final String date;
  final String items;
  final String amount;
  final AppThemeHelper theme;

  const _SaleItem({
    required this.invoice,
    required this.customer,
    required this.date,
    required this.items,
    required this.amount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppConstants.reportIconBoxSize,
          height: AppConstants.reportIconBoxSize,
          decoration: BoxDecoration(
            color: theme.sales.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(
              AppConstants.radiusMD,
            ),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: theme.sales,
            size: AppConstants.iconMD,
          ),
        ),
        const SizedBox(width: AppConstants.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice,
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXXS),
              Text(
                customer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXXS),
              Text(
                date,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spaceSM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXXS),
            Text(
              items,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// class _SalesChart extends StatelessWidget {
//   final AppThemeHelper theme;
//   final List<SaleChartData> chartData;
//
//   const _SalesChart({
//     required this.theme,
//     required this.chartData,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _SalesChartPainter(
//         chartData: chartData,
//         lineColor: theme.sales,
//         gridColor: theme.divider,
//         fillColor: theme.sales.withValues(
//           alpha: 0.08,
//         ),
//       ),
//     );
//   }
// }
//
// class _SalesChartPainter extends CustomPainter {
//   final List<SaleChartData> chartData;
//   final Color lineColor;
//   final Color gridColor;
//   final Color fillColor;
//
//   _SalesChartPainter({
//     required this.chartData,
//     required this.lineColor,
//     required this.gridColor,
//     required this.fillColor,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final gridPaint = Paint()
//       ..color = gridColor
//       ..strokeWidth = 1;
//
//     const gridCount = 4;
//
//     for (int i = 0; i <= gridCount; i++) {
//       final y = size.height / gridCount * i;
//       canvas.drawLine(
//         Offset(0, y),
//         Offset(size.width, y),
//         gridPaint,
//       );
//     }
//
//     if (chartData.isEmpty) return;
//
//     final maxAmount = chartData
//         .map((e) => e.amount)
//         .fold<double>(0, (prev, element) => element > prev ? element : prev);
//     final effectiveMax = maxAmount == 0 ? 1.0 : maxAmount;
//
//     final points = <Offset>[];
//     for (int i = 0; i < chartData.length; i++) {
//       final x = chartData.length == 1
//           ? size.width / 2
//           : size.width / (chartData.length - 1) * i;
//       final y = size.height -
//           (chartData[i].amount / effectiveMax * size.height * 0.85) -
//           10;
//       points.add(Offset(x, y));
//     }
//
//     if (points.isEmpty) return;
//
//     final linePath = Path()..moveTo(points.first.dx, points.first.dy);
//     for (int i = 1; i < points.length; i++) {
//       linePath.lineTo(points[i].dx, points[i].dy);
//     }
//
//     final fillPath = Path.from(linePath)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//
//     canvas.drawPath(
//       fillPath,
//       Paint()
//         ..color = fillColor
//         ..style = PaintingStyle.fill,
//     );
//
//     canvas.drawPath(
//       linePath,
//       Paint()
//         ..color = lineColor
//         ..strokeWidth = 2.5
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round
//         ..style = PaintingStyle.stroke,
//     );
//
//     final dotPaint = Paint()
//       ..color = lineColor
//       ..style = PaintingStyle.fill;
//
//     for (final point in points) {
//       canvas.drawCircle(point, 3, dotPaint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
//     return oldDelegate.chartData != chartData;
//   }
// }

class _SalesChart extends StatelessWidget {
  final AppThemeHelper theme;
  final List<SaleChartData> chartData;

  const _SalesChart({
    required this.theme,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SalesChartPainter(
        chartData: chartData,
        lineColor: theme.sales,
        gridColor: theme.divider,
        fillColor: theme.sales.withValues(alpha: 0.08),
        textColor: theme.textSecondary,
      ),
      size: const Size(
        double.infinity,
        AppConstants.reportChartHeight,
      ),
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  final List<SaleChartData> chartData;
  final Color lineColor;
  final Color gridColor;
  final Color fillColor;
  final Color textColor;

  _SalesChartPainter({
    required this.chartData,
    required this.lineColor,
    required this.gridColor,
    required this.fillColor,
    required this.textColor,
  });

  static const double leftPadding = 48;
  static const double rightPadding = 8;
  static const double topPadding = 10;
  static const double bottomPadding = 28;

  static const int ySections = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.isEmpty) return;

    // ============================================================
    // CHART AREA
    // ============================================================

    final chartWidth =
        size.width - leftPadding - rightPadding;

    final chartHeight =
        size.height - topPadding - bottomPadding;

    // ============================================================
    // MAX VALUE
    // ============================================================

    final rawMax = chartData
        .map((e) => e.amount)
        .fold<double>(
      0,
          (previous, value) =>
      value > previous ? value : previous,
    );

    final maxY = _calculateNiceMax(rawMax);

    // ============================================================
    // PAINTS
    // ============================================================

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // ============================================================
    // Y AXIS + GRID
    // ============================================================

    for (int i = 0; i <= ySections; i++) {
      final ratio = i / ySections;

      final y =
          topPadding + (chartHeight * ratio);

      final value =
          maxY - (maxY * ratio);

      // Grid line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(
          size.width - rightPadding,
          y,
        ),
        gridPaint,
      );

      // Y-axis text
      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatAmount(value),
          style: TextStyle(
            color: textColor,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.textDirection = ui.TextDirection.ltr;
      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          leftPadding -
              textPainter.width -
              7,
          y - textPainter.height / 2,
        ),
      );
    }

    // ============================================================
    // GENERATE POINTS
    // ============================================================

    final points = <Offset>[];

    for (int i = 0; i < chartData.length; i++) {
      final x = chartData.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding +
          (chartWidth /
              (chartData.length - 1)) *
              i;

      final normalizedValue =
      maxY == 0
          ? 0
          : chartData[i].amount / maxY;

      final y =
          topPadding +
              chartHeight -
              (normalizedValue * chartHeight);

      points.add(
        Offset(x, y),
      );
    }

    if (points.isEmpty) return;

    // ============================================================
    // LINE PATH
    // ============================================================

    final linePath = Path()
      ..moveTo(
        points.first.dx,
        points.first.dy,
      );

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    // ============================================================
    // FILL PATH
    // ============================================================

    final bottomY =
        topPadding + chartHeight;

    final fillPath =
    Path.from(linePath)
      ..lineTo(
        points.last.dx,
        bottomY,
      )
      ..lineTo(
        points.first.dx,
        bottomY,
      )
      ..close();

    canvas.drawPath(
      fillPath,
      fillPaint,
    );

    // ============================================================
    // LINE
    // ============================================================

    canvas.drawPath(
      linePath,
      linePaint,
    );

    // ============================================================
    // DOTS
    // ============================================================

    for (final point in points) {
      canvas.drawCircle(
        point,
        3,
        dotPaint,
      );
    }

    // ============================================================
    // X AXIS
    // ============================================================

    _drawXAxis(
      canvas,
      size,
      chartWidth,
      chartHeight,
    );
  }

  // ============================================================
  // X AXIS
  // ============================================================

  void _drawXAxis(
      Canvas canvas,
      Size size,
      double chartWidth,
      double chartHeight,
      ) {
    if (chartData.isEmpty) return;

    /*
     * Don't print all 30/31 dates because labels will overlap.
     *
     * Monthly example:
     * 01  06  11  16  21  26  30
     */

    const maxLabels = 6;

    final step = chartData.length <= maxLabels
        ? 1
        : (chartData.length / maxLabels).ceil();

    final indexes = <int>[];

    for (
    int i = 0;
    i < chartData.length;
    i += step
    ) {
      indexes.add(i);
    }

    // Always show last date
    final lastIndex =
        chartData.length - 1;

    if (!indexes.contains(lastIndex)) {
      indexes.add(lastIndex);
    }

    for (final index in indexes) {
      final data = chartData[index];

      final x = chartData.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding +
          (chartWidth /
              (chartData.length - 1)) *
              index;

      final label =
      data.date.day.toString().padLeft(
        2,
        '0',
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: textColor,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.textDirection = ui.TextDirection.ltr;
      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          topPadding +
              chartHeight +
              8,
        ),
      );
    }
  }

  // ============================================================
  // NICE MAX Y VALUE
  // ============================================================

  double _calculateNiceMax(
      double value,
      ) {
    if (value <= 0) {
      return 100;
    }

    double interval;

    if (value <= 100) {
      interval = 25;
    } else if (value <= 500) {
      interval = 100;
    } else if (value <= 1000) {
      interval = 250;
    } else if (value <= 5000) {
      interval = 1000;
    } else if (value <= 10000) {
      interval = 2500;
    } else if (value <= 50000) {
      interval = 10000;
    } else if (value <= 100000) {
      interval = 25000;
    } else if (value <= 500000) {
      interval = 100000;
    } else {
      interval = 250000;
    }

    return (value / interval).ceil() *
        interval;
  }

  // ============================================================
  // FORMAT Y VALUE
  // ============================================================

  String _formatAmount(
      double value,
      ) {
    if (value >= 1000000) {
      final result =
          value / 1000000;

      return '${_removeZero(result)}M';
    }

    if (value >= 1000) {
      final result =
          value / 1000;

      return '${_removeZero(result)}K';
    }

    return value.toStringAsFixed(0);
  }

  String _removeZero(
      double value,
      ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(1);
  }

  // ============================================================
  // REPAINT
  // ============================================================

  @override
  bool shouldRepaint(
      covariant _SalesChartPainter oldDelegate,
      ) {
    return oldDelegate.chartData != chartData ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor;
  }
}