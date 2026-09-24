import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale_model.dart';
import 'allProductsController.dart';

class HomeController extends GetxController {
  final productController = Get.find<ProductController>();
  late final userName = productController.getUserName();
  final dashboardFilter = 'today'.obs;
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxList<SaleModel> recentSales = <SaleModel>[].obs;
  final RxBool isLoading = false.obs;
  DateTimeRange? _customRange;

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

      final results = await Future.wait([
        _fetchTotalSales(range.start, range.end),
        _fetchTotalPurchases(range.start, range.end),
        _fetchRecentSales(range.start, range.end),
      ]);

      totalSales.value = results[0] as double;
      totalPurchases.value = results[1] as double;
      recentSales.assignAll(results[2] as List<SaleModel>);

      // Calculate low stock from product controller
      lowStockCount.value = productController.products
          .where((p) => p.isLowStock || p.isOutOfStock)
          .length;
    } catch (e) {
      debugPrint('Error fetching home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<double> _fetchTotalPurchases(DateTime start, DateTime end) async {
    final data = await Supabase.instance.client
        .from('purchases')
        .select('total_amount')
        .gte('purchase_date', start.toIso8601String())
        .lte('purchase_date', end.toIso8601String());

    return (data as List).fold<double>(
      0,
      (sum, item) => sum + (item['total_amount'] as num).toDouble(),
    );
  }

  Future<double> _fetchTotalSales(DateTime start, DateTime end) async {
    final data = await Supabase.instance.client
        .from('sales')
        .select('total_amount')
        .gte('sale_date', start.toIso8601String())
        .lte('sale_date', end.toIso8601String());

    return (data as List).fold<double>(
      0,
      (sum, item) => sum + (item['total_amount'] as num).toDouble(),
    );
  }

  Future<List<SaleModel>> _fetchRecentSales(DateTime start, DateTime end) async {
    final response = await Supabase.instance.client
        .from('sales')
        .select()
        .gte('sale_date', start.toIso8601String())
        .lte('sale_date', end.toIso8601String())
        .order('sale_date', ascending: false)
        .limit(3);

    return (response as List)
        .map((json) => SaleModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
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
