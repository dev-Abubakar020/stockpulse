import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/controllers/sale_report_Controller.dart';
import 'package:stockpulse/models/purchasemodel.dart';
import 'package:stockpulse/repositories/purchase_repo.dart';
import 'package:stockpulse/repositories/sale_repository.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../models/sale_model.dart';
import 'allProductsController.dart';

class HomeController extends GetxController {
  final productController = Get.find<ProductController>();
  final SaleRepository _saleRepository = SaleRepository();
  final PurchaseRepository _purchaseRepository = PurchaseRepository();

  late final userName = productController.getUserName();
  final dashboardFilter = 'today'.obs;
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxList<SaleModel> recentSales = <SaleModel>[].obs;
  final RxBool isLoading = false.obs;
  DateTimeRange? _customRange;

  final categorySales = <CategorySaleReport>[].obs;
  final chartData = <HomeChartData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();

    // Automatically re-calculate low stock whenever products list changes
    ever(productController.products, (_) {
      lowStockCount.value = productController.products
          .where((p) => p.isLowStock || p.isOutOfStock)
          .length;
    });
  }

  String get dashboardFilterLabel {
    switch (dashboardFilter.value) {
      case 'yesterday':
        return 'Yesterday';

      case 'week':
        return 'This Week';

      case 'month':
        return 'This Month';

      case 'custom':
        if (_customRange != null) {
          final startStr =
              "${_customRange!.start.day}/${_customRange!.start.month}";
          final endStr = "${_customRange!.end.day}/${_customRange!.end.month}";
          return "$startStr - $endStr";
        }
        return 'Custom Range';

      default:
        return 'Today';
    }
  }

  DateTimeRange _getDateRangeForFilter(String filter) {
    final now = DateTime.now();

    switch (filter) {
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        final start =
            DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0);
        final end = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);

      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(
            startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);

      case 'month':
        final start = DateTime(now.year, now.month, 1, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);

      case 'custom':
        if (_customRange != null) {
          final start = DateTime(
              _customRange!.start.year,
              _customRange!.start.month,
              _customRange!.start.day,
              0,
              0,
              0);
          final end = DateTime(
              _customRange!.end.year,
              _customRange!.end.month,
              _customRange!.end.day,
              23,
              59,
              59);
          return DateTimeRange(start: start, end: end);
        }
        final startToday = DateTime(now.year, now.month, now.day, 0, 0, 0);
        final endToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: startToday, end: endToday);

      default: // 'today'
        final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
    }
  }

  Future<void> changeDashboardFilter(String filter) async {
    if (filter == 'custom') {
      final picked = await showDateRangePicker(
        context: Get.context!,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: _customRange ??
            DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            ),
      );

      if (picked != null) {
        _customRange = picked;
        dashboardFilter.value = 'custom';
        await fetchHomeData();
      }
      return;
    }

    dashboardFilter.value = filter;
    await fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;

      final range = _getDateRangeForFilter(dashboardFilter.value);

      final sales = await _saleRepository.getSales();
      final purchases = await _purchaseRepository.getPurchases();

      final currentSales = sales.where((s) => !s.saleDate.isBefore(range.start) && !s.saleDate.isAfter(range.end)).toList();
      final currentPurchases = purchases.where((p) => !p.purchaseDate.isBefore(range.start) && !p.purchaseDate.isAfter(range.end)).toList();

      final totalS = currentSales.fold<double>(0, (sum, s) => sum + s.totalAmount);
      final totalP = currentPurchases.fold<double>(0, (sum, p) => sum + p.totalAmount);

      totalSales.value = totalS;
      totalPurchases.value = totalP;

      currentSales.sort((a, b) => b.saleDate.compareTo(a.saleDate));
      recentSales.assignAll(currentSales.take(3));

      // Calculate low stock from product controller
      lowStockCount.value = productController.products
          .where((p) => p.isLowStock || p.isOutOfStock)
          .length;

      await _computeCategorySales(currentSales);
      _computeChartData(currentSales, currentPurchases, range);
    } catch (e) {
      debugPrint('Error fetching home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _computeCategorySales(List<SaleModel> sales) async {
    final Map<String, double> productTotals = {};
    double grandTotal = 0;

    for (final sale in sales) {
      final items = await _saleRepository.getSaleItems(sale.id);
      for (final item in items) {
        final productName = item.article.trim().isEmpty ? AppConstants.others : item.article.trim();
        final amount = item.lineTotal;
        productTotals.update(productName, (value) => value + amount, ifAbsent: () => amount);
        grandTotal += amount;
      }
    }

    final reports = productTotals.entries.map((entry) {
      final percentage = grandTotal == 0 ? 0.0 : (entry.value / grandTotal) * 100;
      return CategorySaleReport(name: entry.key, amount: entry.value, percentage: percentage);
    }).toList();

    reports.sort((a, b) => b.amount.compareTo(a.amount));
    categorySales.assignAll(reports.take(5));
  }

  void _computeChartData(List<SaleModel> sales, List<PurchaseModel> purchases, DateTimeRange range) {
    final Map<DateTime, double> dailySales = {};
    final Map<DateTime, double> dailyPurchases = {};

    for (final sale in sales) {
      final day = DateTime(sale.saleDate.year, sale.saleDate.month, sale.saleDate.day);
      dailySales.update(day, (v) => v + sale.totalAmount, ifAbsent: () => sale.totalAmount);
    }

    for (final purchase in purchases) {
      final day = DateTime(purchase.purchaseDate.year, purchase.purchaseDate.month, purchase.purchaseDate.day);
      dailyPurchases.update(day, (v) => v + purchase.totalAmount, ifAbsent: () => purchase.totalAmount);
    }

    final data = <HomeChartData>[];
    var curr = range.start;
    while (!curr.isAfter(range.end)) {
      final day = DateTime(curr.year, curr.month, curr.day);
      data.add(HomeChartData(
        date: day,
        salesAmount: dailySales[day] ?? 0.0,
        purchaseAmount: dailyPurchases[day] ?? 0.0,
      ));
      curr = curr.add(const Duration(days: 1));
    }
    chartData.assignAll(data);
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return AppConstants.morningGreeting;
    } else if (hour >= 12 && hour < 17) {
      return AppConstants.afternoonGreeting;
    } else if (hour >= 17 && hour < 21) {
      return AppConstants.eveningGreeting;
    } else {
      return AppConstants.nightGreeting;
    }
  }
}

class HomeChartData {
  final DateTime date;
  final double salesAmount;
  final double purchaseAmount;

  const HomeChartData({
    required this.date,
    required this.salesAmount,
    required this.purchaseAmount,
  });
}
