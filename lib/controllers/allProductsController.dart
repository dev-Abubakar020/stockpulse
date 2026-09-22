import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stockpulse/controllers/homecontroller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/productItemModel.dart';
import '../common/exceptional/platform_exceptions.dart';
import '../common/widgets/custom_snackbar.dart';
import '../repositories/product_repository.dart';
import '../services/networkManager.dart';
import '../utils/app_constants.dart';

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
    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('Fetching products from Supabase...');
      final fetched = await repository.getProducts();
      debugPrint('Successfully fetched ${fetched.length} products.');
      products.assignAll(fetched);
    } catch (e) {
      debugPrint('EXCEPTION CAUGHT IN fetchProducts: $e');
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
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
        allProducts = allProducts
            .where((product) => product.isLowStock)
            .toList();
        break;
      case 2:
        allProducts = allProducts
            .where((product) => product.isOutOfStock)
            .toList();
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
        return title.contains(query) ||
            cat.contains(query) ||
            barcode.contains(query);
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

  Future<void> deleteProduct(ProductItemModel product) async {
    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      await repository.deleteProduct(product.id);

      products.removeWhere((item) => item.id == product.id);

      // Refresh Home Dashboard Data
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomeData();
      }

      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: AppConstants.productRemovedSuccess,
      );
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    }
  }
}
