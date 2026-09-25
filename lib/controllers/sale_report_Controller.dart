import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../repositories/sale_repository.dart';
import '../utils/app_constants.dart';

class SaleReportController extends GetxController {
  final SaleRepository _saleRepository;

  SaleReportController({
    SaleRepository? saleRepository,
  }) : _saleRepository = saleRepository ?? SaleRepository();


  final isLoading = false.obs;
  final selectedFilter = 'Daily'.obs;
  final selectedDate = DateTime.now().obs;
  DateTimeRange? customRange;

  final totalSales = 0.0.obs;
  final totalInvoices = 0.obs;
  final averageSale = 0.0.obs;
  final itemsSold = 0.0.obs;
  final salesPercentage = 0.0.obs;
  final invoicesPercentage = 0.0.obs;
  final averageSalePercentage = 0.0.obs;
  final itemsSoldPercentage = 0.0.obs;
  final allSales = <SaleModel>[].obs;
  final filteredSales = <SaleModel>[].obs;
  final recentSales = <SaleModel>[].obs;
  final categorySales = <CategorySaleReport>[].obs;
  final chartData = <SaleChartData>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }



  Future<void> fetchReport() async {
    try {
      isLoading.value = true;

      final sales = await _saleRepository.getSales();
      allSales.assignAll(sales);
      await _generateReport();
    } catch (e) {
      Get.snackbar(
        'Report Error',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GENERATE REPORT
  // ============================================================

  Future<void> _generateReport() async {
    final currentRange = _getDateRange(
      selectedDate.value,
      selectedFilter.value,
    );

    final previousRange = _getPreviousDateRange(
      selectedDate.value,
      selectedFilter.value,
    );

    final currentSales = allSales.where((sale) {
      return _isInsideRange(
        sale.saleDate,
        currentRange.start,
        currentRange.end,
      );
    }).toList();

    final previousSales = allSales.where((sale) {
      return _isInsideRange(
        sale.saleDate,
        previousRange.start,
        previousRange.end,
      );
    }).toList();

    filteredSales.assignAll(currentSales);

    // Most recent first
    currentSales.sort(
          (a, b) => b.saleDate.compareTo(a.saleDate),
    );

    recentSales.assignAll(
      currentSales.take(5),
    );

    await _calculateSummary(
      currentSales,
      previousSales,
    );

    await generateCategoryReport(
      currentSales,
    );

    _generateChartData(
      currentSales,
      currentRange,
    );
  }

  Future<void> _calculateSummary(
      List<SaleModel> currentSales,
      List<SaleModel> previousSales,
      ) async 
  {
    final currentTotal = currentSales.fold<double>(
      0,
          (sum, sale) => sum + sale.totalAmount,
    );

    final previousTotal = previousSales.fold<double>(
      0,
          (sum, sale) => sum + sale.totalAmount,
    );

    totalSales.value = currentTotal;

    totalInvoices.value = currentSales.length;

    averageSale.value = currentSales.isEmpty
        ? 0
        : currentTotal / currentSales.length;

    final previousAverage = previousSales.isEmpty
        ? 0.0
        : previousTotal / previousSales.length;

    // ----------------------------------------------------------
    // ITEMS SOLD
    // ----------------------------------------------------------

    double currentItems = 0;
    double previousItems = 0;

    for (final sale in currentSales) {
      final items = await _saleRepository.getSaleItems(
        sale.id,
      );

      currentItems += _calculateItemQuantity(items);
    }

    for (final sale in previousSales) {
      final items = await _saleRepository.getSaleItems(
        sale.id,
      );

      previousItems += _calculateItemQuantity(items);
    }

    itemsSold.value = currentItems;

    itemsSoldPercentage.value = _percentageChange(
      currentItems,
      previousItems,
    );

    // ----------------------------------------------------------
    // PERCENTAGES
    // ----------------------------------------------------------

    salesPercentage.value = _percentageChange(
      currentTotal,
      previousTotal,
    );

    invoicesPercentage.value = _percentageChange(
      currentSales.length.toDouble(),
      previousSales.length.toDouble(),
    );

    averageSalePercentage.value = _percentageChange(
      averageSale.value,
      previousAverage,
    );

    itemsSoldPercentage.value = _percentageChange(
      currentItems.toDouble(),
      previousItems.toDouble(),
    );
  }

  // ============================================================
  // CATEGORY REPORT
  // ============================================================

  Future<void> generateCategoryReport(
      List<SaleModel> sales,
      ) async {
    final Map<String, double> productTotals = {};

    double grandTotal = 0;

    for (final sale in sales) {
      final items = await _saleRepository.getSaleItems(
        sale.id,
      );

      for (final item in items) {
        final productName = item.article.trim().isEmpty
            ? AppConstants.others
            : item.article.trim();

        final amount = item.lineTotal;

        productTotals.update(
          productName,
              (value) => value + amount,
          ifAbsent: () => amount,
        );

        grandTotal += amount;
      }
    }

    final reports = productTotals.entries.map(
          (entry) {
        final percentage = grandTotal == 0
            ? 0.0
            : (entry.value / grandTotal) * 100;

        return CategorySaleReport(
          name: entry.key,
          amount: entry.value,
          percentage: percentage,
        );
      },
    ).toList();

    reports.sort(
          (a, b) => b.amount.compareTo(a.amount),
    );

    categorySales.assignAll(
      reports.take(5),
    );
  }

  // ============================================================
  // CHART
  // ============================================================

  void _generateChartData(
      List<SaleModel> sales,
      DateTimeRangeData range,
      ) {
    final Map<DateTime, double> dailyTotals = {};

    for (final sale in sales) {
      final day = DateTime(
        sale.saleDate.year,
        sale.saleDate.month,
        sale.saleDate.day,
      );

      dailyTotals.update(
        day,
            (value) => value + sale.totalAmount,
        ifAbsent: () => sale.totalAmount,
      );
    }

    final data = <SaleChartData>[];

    var currentDate = range.start;

    while (!currentDate.isAfter(range.end)) {
      final date = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      data.add(
        SaleChartData(
          date: date,
          amount: dailyTotals[date] ?? 0,
        ),
      );

      currentDate = currentDate.add(
        const Duration(days: 1),
      );
    }

    chartData.assignAll(data);
  }

  // ============================================================
  // FILTER CHANGE
  // ============================================================

  Future<void> changeFilter(
      String filter,
      ) async {
    if (filter == 'Custom') {
      final picked = await showDateRangePicker(
        context: Get.context!,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: customRange ??
            DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            ),
      );

      if (picked != null) {
        customRange = picked;
        selectedFilter.value = 'Custom';
        await _generateReport();
      }
      return;
    }

    if (selectedFilter.value == filter) {
      return;
    }

    selectedFilter.value = filter;
    selectedDate.value = DateTime.now();

    await _generateReport();
  }

  // ============================================================
  // PREVIOUS PERIOD
  // ============================================================

  Future<void> previousPeriod() async {
    if (selectedFilter.value == 'Custom') return;
    final date = selectedDate.value;

    switch (selectedFilter.value) {
      case 'Daily':
        selectedDate.value = date.subtract(
          const Duration(days: 1),
        );
        break;

      case 'Monthly':
        selectedDate.value = DateTime(
          date.year,
          date.month - 1,
          1,
        );
        break;

      default:
        return;
    }

    await _generateReport();
  }

  // ============================================================
  // NEXT PERIOD
  // ============================================================

  Future<void> nextPeriod() async {
    if (selectedFilter.value == 'Custom') return;
    if (!hasNextPeriod) return;
    final date = selectedDate.value;

    DateTime nextDate;

    switch (selectedFilter.value) {
      case 'Daily':
        nextDate = date.add(
          const Duration(days: 1),
        );
        break;

      case 'Monthly':
        nextDate = DateTime(
          date.year,
          date.month + 1,
          1,
        );
        break;

      default:
        return;
    }

    // Don't move into future periods
    if (nextDate.isAfter(DateTime.now())) {
      return;
    }

    selectedDate.value = nextDate;

    await _generateReport();
  }

  bool get hasNextPeriod {
    if (selectedFilter.value == 'Custom') return false;
    final now = DateTime.now();
    final date = selectedDate.value;

    if (selectedFilter.value == 'Daily') {
      final selectedDay = DateTime(date.year, date.month, date.day);
      final today = DateTime(now.year, now.month, now.day);
      return selectedDay.isBefore(today);
    } else if (selectedFilter.value == 'Monthly') {
      final selectedMonth = DateTime(date.year, date.month, 1);
      final currentMonth = DateTime(now.year, now.month, 1);
      return selectedMonth.isBefore(currentMonth);
    }
    return false;
  }

  // ============================================================
  // DISPLAY PERIOD
  // ============================================================

  String get periodTitle {
    if (selectedFilter.value == 'Custom') {
      if (customRange != null) {
        return '${DateFormat('dd MMM').format(customRange!.start)} - ${DateFormat('dd MMM yyyy').format(customRange!.end)}';
      }
      return 'Custom Range';
    }

    final date = selectedDate.value;

    switch (selectedFilter.value) {
      case 'Daily':
        return DateFormat(
          'dd MMMM yyyy',
        ).format(date);

      case 'Monthly':
        return DateFormat(
          'MMMM yyyy',
        ).format(date);

      default:
        return DateFormat(
          'MMMM yyyy',
        ).format(date);
    }
  }

  String get periodSubtitle {
    if (selectedFilter.value == 'Custom') {
      if (customRange != null) {
        final days = customRange!.duration.inDays + 1;
        return '$days Days Selected';
      }
      return 'Custom Range Filter';
    }

    final range = _getDateRange(
      selectedDate.value,
      selectedFilter.value,
    );

    if (selectedFilter.value == 'Daily') {
      return DateFormat(
        'EEEE',
      ).format(range.start);
    }

    return '${DateFormat('dd MMM').format(range.start)}'
        ' - '
        '${DateFormat('dd MMM').format(range.end)}';
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  DateTimeRangeData _getDateRange(
      DateTime date,
      String filter,
      ) {
    switch (filter) {
      case 'Daily':
        final start = DateTime(
          date.year,
          date.month,
          date.day,
        );

        return DateTimeRangeData(
          start: start,
          end: DateTime(
            date.year,
            date.month,
            date.day,
            23,
            59,
            59,
            999,
          ),
        );

      case 'Custom':
        if (customRange != null) {
          final start = DateTime(
            customRange!.start.year,
            customRange!.start.month,
            customRange!.start.day,
            0,
            0,
            0,
          );
          final end = DateTime(
            customRange!.end.year,
            customRange!.end.month,
            customRange!.end.day,
            23,
            59,
            59,
            999,
          );
          return DateTimeRangeData(start: start, end: end);
        }
        final now = DateTime.now();
        return DateTimeRangeData(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
        );

      case 'Monthly':
      default:
        final start = DateTime(
          date.year,
          date.month,
          1,
        );

        final end = DateTime(
          date.year,
          date.month + 1,
          0,
          23,
          59,
          59,
          999,
        );

        return DateTimeRangeData(
          start: start,
          end: end,
        );
    }
  }

  // ============================================================
  // PREVIOUS DATE RANGE
  // ============================================================

  DateTimeRangeData _getPreviousDateRange(
      DateTime date,
      String filter,
      ) {
    switch (filter) {
      case 'Daily':
        final previous = date.subtract(
          const Duration(days: 1),
        );

        return _getDateRange(
          previous,
          filter,
        );

      case 'Monthly':
      default:
        final previous = DateTime(
          date.year,
          date.month - 1,
          1,
        );

        return _getDateRange(
          previous,
          filter,
        );
    }
  }

  // ============================================================
  // DATE CHECK
  // ============================================================

  bool _isInsideRange(
      DateTime date,
      DateTime start,
      DateTime end,
      ) {
    return !date.isBefore(start) &&
        !date.isAfter(end);
  }

  // ============================================================
  // PERCENTAGE
  // ============================================================

  double _percentageChange(
      double current,
      double previous,
      ) {
    if (previous == 0) {
      return current > 0 ? 100 : 0;
    }

    return ((current - previous) / previous) * 100;
  }

  // ============================================================
  // ITEM QUANTITY
  // ============================================================

  double _calculateItemQuantity(
      List<SaleItemModel> items,
      ) {
    return items.fold<double>(
      0.0,
          (sum, item) => sum + item.quantity,
    );
  }
}

// ============================================================
// REPORT UI MODELS
// ============================================================

class CategorySaleReport {
  final String name;
  final double amount;
  final double percentage;

  const CategorySaleReport({
    required this.name,
    required this.amount,
    required this.percentage,
  });
}

class SaleChartData {
  final DateTime date;
  final double amount;

  const SaleChartData({
    required this.date,
    required this.amount,
  });
}

class DateTimeRangeData {
  final DateTime start;
  final DateTime end;

  const DateTimeRangeData({
    required this.start,
    required this.end,
  });
}
