import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/purchasemodel.dart';
import '../repositories/purchase_repo.dart';


class PurchaseReportController extends GetxController {
  final PurchaseRepository _purchaseRepository;

  PurchaseReportController({
    PurchaseRepository? purchaseRepository,
  }) : _purchaseRepository =
      purchaseRepository ?? PurchaseRepository();

  // ============================================================
  // LOADING
  // ============================================================

  final isLoading = false.obs;

  // ============================================================
  // FILTER
  // ============================================================

  final selectedFilter = 'Daily'.obs;
  final selectedDate = DateTime.now().obs;
  DateTimeRange? customRange;

  // ============================================================
  // SUMMARY
  // ============================================================

  final totalPurchases = 0.0.obs;
  final totalInvoices = 0.obs;
  final averagePurchase = 0.0.obs;
  final itemsPurchased = 0.0.obs;

  // ============================================================
  // PERCENTAGE COMPARISON
  // ============================================================

  final purchasesPercentage = 0.0.obs;
  final invoicesPercentage = 0.0.obs;
  final averagePurchasePercentage = 0.0.obs;
  final itemsPurchasedPercentage = 0.0.obs;

  // ============================================================
  // DATA
  // ============================================================

  final allPurchases = <PurchaseModel>[].obs;
  final filteredPurchases = <PurchaseModel>[].obs;
  final recentPurchases = <PurchaseModel>[].obs;

  final productPurchases =
      <ProductPurchaseReport>[].obs;

  final chartData =
      <PurchaseChartData>[].obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  // ============================================================
  // FETCH REPORT
  // ============================================================

  Future<void> fetchReport() async {
    try {
      isLoading.value = true;

      final purchases =
      await _purchaseRepository.getPurchases();

      allPurchases.assignAll(purchases);

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

    final previousRange =
    _getPreviousDateRange(
      selectedDate.value,
      selectedFilter.value,
    );

    final currentPurchases =
    allPurchases.where((purchase) {
      return _isInsideRange(
        purchase.purchaseDate,
        currentRange.start,
        currentRange.end,
      );
    }).toList();

    final previousPurchases =
    allPurchases.where((purchase) {
      return _isInsideRange(
        purchase.purchaseDate,
        previousRange.start,
        previousRange.end,
      );
    }).toList();

    currentPurchases.sort(
          (a, b) => b.purchaseDate.compareTo(
        a.purchaseDate,
      ),
    );

    filteredPurchases.assignAll(
      currentPurchases,
    );

    recentPurchases.assignAll(
      currentPurchases.take(5),
    );

    await _calculateSummary(
      currentPurchases,
      previousPurchases,
    );

    await _generateProductReport(
      currentPurchases,
    );

    _generateChartData(
      currentPurchases,
      currentRange,
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Future<void> _calculateSummary(
      List<PurchaseModel> currentPurchases,
      List<PurchaseModel> previousPurchases,
      ) async {
    final currentTotal =
    currentPurchases.fold<double>(
      0.0,
          (sum, purchase) =>
      sum + purchase.totalAmount,
    );

    final previousTotal =
    previousPurchases.fold<double>(
      0.0,
          (sum, purchase) =>
      sum + purchase.totalAmount,
    );

    // ----------------------------------------------------------
    // TOTAL PURCHASE
    // ----------------------------------------------------------

    totalPurchases.value = currentTotal;

    // ----------------------------------------------------------
    // TOTAL INVOICES
    // ----------------------------------------------------------

    totalInvoices.value =
        currentPurchases.length;

    // ----------------------------------------------------------
    // AVERAGE PURCHASE
    // ----------------------------------------------------------

    averagePurchase.value =
    currentPurchases.isEmpty
        ? 0.0
        : currentTotal /
        currentPurchases.length;

    final previousAverage =
    previousPurchases.isEmpty
        ? 0.0
        : previousTotal /
        previousPurchases.length;

    // ----------------------------------------------------------
    // ITEMS PURCHASED
    // ----------------------------------------------------------

    double currentItems = 0.0;
    double previousItems = 0.0;

    for (final purchase
    in currentPurchases) {
      final items =
      await _purchaseRepository
          .getPurchaseItems(
        purchase.id,
      );

      currentItems +=
          _calculateItemQuantity(items);
    }

    for (final purchase
    in previousPurchases) {
      final items =
      await _purchaseRepository
          .getPurchaseItems(
        purchase.id,
      );

      previousItems +=
          _calculateItemQuantity(items);
    }

    itemsPurchased.value =
        currentItems;

    // ----------------------------------------------------------
    // PERCENTAGES
    // ----------------------------------------------------------

    purchasesPercentage.value =
        _percentageChange(
          currentTotal,
          previousTotal,
        );

    invoicesPercentage.value =
        _percentageChange(
          currentPurchases.length.toDouble(),
          previousPurchases.length.toDouble(),
        );

    averagePurchasePercentage.value =
        _percentageChange(
          averagePurchase.value,
          previousAverage,
        );

    itemsPurchasedPercentage.value =
        _percentageChange(
          currentItems,
          previousItems,
        );
  }

  // ============================================================
  // PRODUCT PURCHASE REPORT
  // ============================================================

  Future<void> _generateProductReport(
      List<PurchaseModel> purchases,
      ) async {
    final Map<String, double>
    productTotals = {};

    double grandTotal = 0.0;

    for (final purchase in purchases) {
      final items =
      await _purchaseRepository
          .getPurchaseItems(
        purchase.id,
      );

      for (final item in items) {
        final productName =
        item.article.trim().isEmpty
            ? 'Others'
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

    final reports =
    productTotals.entries.map(
          (entry) {
        final percentage =
        grandTotal == 0
            ? 0.0
            : (entry.value /
            grandTotal) *
            100;

        return ProductPurchaseReport(
          name: entry.key,
          amount: entry.value,
          percentage: percentage,
        );
      },
    ).toList();

    reports.sort(
          (a, b) =>
          b.amount.compareTo(a.amount),
    );

    productPurchases.assignAll(
      reports.take(5),
    );
  }

  // ============================================================
  // CHART
  // ============================================================

  void _generateChartData(
      List<PurchaseModel> purchases,
      PurchaseDateRange range,
      ) {
    final Map<DateTime, double>
    dailyTotals = {};

    for (final purchase in purchases) {
      final day = DateTime(
        purchase.purchaseDate.year,
        purchase.purchaseDate.month,
        purchase.purchaseDate.day,
      );

      dailyTotals.update(
        day,
            (value) =>
        value + purchase.totalAmount,
        ifAbsent: () =>
        purchase.totalAmount,
      );
    }

    final data =
    <PurchaseChartData>[];

    var currentDate = range.start;

    while (!currentDate.isAfter(
      range.end,
    )) {
      final date = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      data.add(
        PurchaseChartData(
          date: date,
          amount:
          dailyTotals[date] ?? 0.0,
        ),
      );

      currentDate = currentDate.add(
        const Duration(days: 1),
      );
    }

    chartData.assignAll(data);
  }

  // ============================================================
  // CHANGE FILTER
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
        selectedDate.value =
            date.subtract(
              const Duration(days: 1),
            );
        break;

      case 'Monthly':
        selectedDate.value =
            DateTime(
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

    if (_isFuturePeriod(nextDate)) {
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
  // FUTURE PERIOD CHECK
  // ============================================================

  bool _isFuturePeriod(
      DateTime date,
      ) {
    final now = DateTime.now();

    if (selectedFilter.value == 'Daily') {
      final selected = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      return selected.isAfter(today);
    }

    final selectedMonth = DateTime(
      date.year,
      date.month,
    );

    final currentMonth = DateTime(
      now.year,
      now.month,
    );

    return selectedMonth.isAfter(
      currentMonth,
    );
  }

  // ============================================================
  // PERIOD TITLE
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
      default:
        return DateFormat(
          'MMMM yyyy',
        ).format(date);
    }
  }

  // ============================================================
  // PERIOD SUBTITLE
  // ============================================================

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
  // CURRENT DATE RANGE
  // ============================================================

  PurchaseDateRange _getDateRange(
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

        final end = DateTime(
          date.year,
          date.month,
          date.day,
          23,
          59,
          59,
          999,
        );

        return PurchaseDateRange(
          start: start,
          end: end,
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
          return PurchaseDateRange(start: start, end: end);
        }
        final now = DateTime.now();
        return PurchaseDateRange(
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

        return PurchaseDateRange(
          start: start,
          end: end,
        );
    }
  }

  // ============================================================
  // PREVIOUS DATE RANGE
  // ============================================================

  PurchaseDateRange
  _getPreviousDateRange(
      DateTime date,
      String filter,
      ) {
    switch (filter) {
      case 'Daily':
        return _getDateRange(
          date.subtract(
            const Duration(days: 1),
          ),
          filter,
        );

      case 'Monthly':
      default:
        return _getDateRange(
          DateTime(
            date.year,
            date.month - 1,
            1,
          ),
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
  // PERCENTAGE CHANGE
  // ============================================================

  double _percentageChange(
      double current,
      double previous,
      ) {
    if (previous == 0) {
      return current > 0 ? 100.0 : 0.0;
    }

    return ((current - previous) /
        previous) *
        100;
  }

  // ============================================================
  // ITEM QUANTITY
  // ============================================================

  double _calculateItemQuantity(
      List<PurchaseItemModel> items,
      ) {
    return items.fold<double>(
      0.0,
          (sum, item) =>
      sum + item.quantity,
    );
  }

  // ============================================================
  // QUANTITY FORMATTER
  // ============================================================

  String formatQuantity(
      double value,
      ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

// ============================================================
// PRODUCT PURCHASE REPORT
// ============================================================

class ProductPurchaseReport {
  final String name;
  final double amount;
  final double percentage;

  const ProductPurchaseReport({
    required this.name,
    required this.amount,
    required this.percentage,
  });
}

// ============================================================
// CHART MODEL
// ============================================================

class PurchaseChartData {
  final DateTime date;
  final double amount;

  const PurchaseChartData({
    required this.date,
    required this.amount,
  });
}

// ============================================================
// DATE RANGE
// ============================================================

class PurchaseDateRange {
  final DateTime start;
  final DateTime end;

  const PurchaseDateRange({
    required this.start,
    required this.end,
  });
}
