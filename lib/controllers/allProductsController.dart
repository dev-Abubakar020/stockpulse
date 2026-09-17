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

  Future<void> deactivateProduct(
      ProductItemModel product,
      ) async {
    try {
      await repository.deactivateProduct(product.id);

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