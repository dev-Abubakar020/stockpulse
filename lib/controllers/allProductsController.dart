import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stockpulse/controllers/home_controller.dart';
import 'package:stockpulse/services/role_service.dart';
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

  Future<ProductItemModel?> findProductByBarcode(String barcode) async {
    final code = barcode.trim().toUpperCase();

    // First check already loaded products
    final localProduct = products.firstWhereOrNull(
      (product) =>
          product.barcode?.trim().toUpperCase() == code && product.isActive,
    );

    if (localProduct != null) {
      return localProduct;
    }

    // Otherwise fetch from DB
    try {
      final roleService = Get.find<RoleService>();

      if (roleService.shopId.value.isEmpty) {
        return null;
      }

      final product = await repository.getProductByBarcode(
        barcode: code,
        shopId: int.parse(roleService.shopId.value),
      );

      if (product != null) {
        // Important because SaleController uses this list.
        final existingIndex = products.indexWhere((p) => p.id == product.id);

        if (existingIndex == -1) {
          products.add(product);
        }
      }

      return product;
    } catch (e) {
      debugPrint('findProductByBarcode error: $e');
      return null;
    }
  }

  Future<void> fetchProducts() async {
    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('Fetching products from Supabase...');
      final roleService = Get.isRegistered<RoleService>()
          ? Get.find<RoleService>()
          : Get.put(RoleService(), permanent: true);

      final fetched = roleService.isStaff
          ? await repository.getStaffProducts()
          : await repository.getProducts();

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
    if (isSaving.value) return;
    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isSaving.value = true;
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
    } finally {
      isSaving.value = false;
    }
  }
}
