import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sale_model.dart';
import 'allProductsController.dart';

class HomeController extends GetxController {
  final productController = Get.find<ProductController>();
  late final userName = productController.getUserName();

  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxList<SaleModel> recentSales = <SaleModel>[].obs;
  final RxBool isLoading = false.obs;

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

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      

      final results = await Future.wait([
        _fetchTotalSales(),
        _fetchTotalPurchases(),
        _fetchRecentSales(),
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

  Future<double> _fetchTotalPurchases() async {
    final data = await Supabase.instance.client
        .from('purchases')
        .select('total_amount');

    return (data as List).fold<double>(
      0,
      (sum, item) => sum + (item['total_amount'] as num).toDouble(),
    );
  }

  Future<double> _fetchTotalSales() async {
    final data = await Supabase.instance.client
        .from('sales')
        .select('total_amount');

    return (data as List).fold<double>(
      0,
      (sum, item) => sum + (item['total_amount'] as num).toDouble(),
    );
  }

  Future<List<SaleModel>> _fetchRecentSales() async {
    final response = await Supabase.instance.client
        .from('sales')
        .select()
        .order('sale_date', ascending: false)
        .limit(5);

    return (response as List)
        .map((json) => SaleModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening 🌇';
    } else {
      return 'Good Night 🌙';
    }
  }
}