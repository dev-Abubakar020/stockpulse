import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../models/productItemModel.dart';
import '../repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository repository;

  ProductController(this.repository);

  final products = <ProductItemModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  final selectedFilterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    fetchProducts();
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
  // =========================
  // FETCH PRODUCTS
  // =========================

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      debugPrint('Fetching products from Supabase...');
      final fetched = await repository.getProducts();
      debugPrint('Successfully fetched ${fetched.length} products.');
      products.assignAll(fetched);
    } catch (e) {
      debugPrint('EXCEPTION CAUGHT IN fetchProducts: $e');
      Get.snackbar(
        'Error',
        'Unable to load products: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // FILTERED PRODUCTS
  // =========================

  List<ProductItemModel> get filteredProducts {
    final allProducts = products.toList();
    switch (selectedFilterIndex.value) {
      case 1:
        return allProducts
            .where((product) => product.isLowStock)
            .toList();

      case 2:
        return allProducts
            .where((product) => product.isOutOfStock)
            .toList();

      default:
        return allProducts;
    }
  }

  void changeFilter(int index) {
    selectedFilterIndex.value = index;
  }

  // =========================
  // DELETE / DEACTIVATE
  // =========================

  Future<void> deleteProduct(
      ProductItemModel product,
      ) async {
    try {
      await repository.deleteProduct(product.id);

      products.removeWhere(
            (item) => item.id == product.id,
      );

      Get.snackbar(
        'Success',
        'Product removed successfully',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to remove product',
      );
    }
  }
}