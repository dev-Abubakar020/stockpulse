import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/productItemModel.dart';
import '../repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository repository;

  ProductController(this.repository);

  final products = <ProductItemModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  final selectedFilterIndex = 0.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();

    fetchProducts();
  }

  String getUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    return (metadata['name'] ??
            metadata['full_name'] ??
            metadata['display_name'] ??
            user?.email?.split('@').first ??
            'User')
        .toString();
  }


  // =========================
  // FETCH PRODUCTS
  // =========================

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final startTime = DateTime.now();
      debugPrint('Fetching products from Supabase...');
      await Future.delayed(const Duration(seconds: 1));
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
    var allProducts = products.toList();
    switch (selectedFilterIndex.value) {
      case 1:
        allProducts = allProducts.where((product) => product.isLowStock).toList();
        break;
      case 2:
        allProducts = allProducts.where((product) => product.isOutOfStock).toList();
        break;
      default:
        break;
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      allProducts = allProducts.where((product) {
        final title = product.article.toLowerCase();
        final cat = (product.categoryName ?? '').toLowerCase();
        final barcode = (product.barcode ?? '').toLowerCase();
        return title.contains(query) || cat.contains(query) || barcode.contains(query);
      }).toList();
    }

    return allProducts;
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