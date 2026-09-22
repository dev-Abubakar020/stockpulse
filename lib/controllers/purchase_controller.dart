import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/controllers/homecontroller.dart';

import '../common/exceptional/platform_exceptions.dart';
import '../common/widgets/custom_snackbar.dart';
import '../models/productItemModel.dart';
import '../models/purchasemodel.dart';
import '../repositories/purchase_repo.dart';
import '../services/networkManager.dart';
import '../utils/app_constants.dart';
import 'allProductsController.dart';

class PurchaseController extends GetxController {
  final PurchaseRepository repository;
  final ProductController productController;

  PurchaseController({
    required this.repository,
    required this.productController,
  });

  // =========================
  // State
  // =========================

  final RxBool isLoading = false.obs;
  final RxList<PurchaseModel> purchases = <PurchaseModel>[].obs;

  final RxBool isPurchasesLoading = false.obs;

  final RxString searchQuery = ''.obs;

  final RxInt selectedFilter = 0.obs;

  final TextEditingController searchController = TextEditingController();

  final List<String> filters = const ['All', 'Completed', 'Cancelled'];

  /// productId -> quantity
  final RxMap<String, double> quantities = <String, double>{}.obs;

  /// productId -> current purchase price for THIS purchase
  final RxMap<String, double> purchasePrices = <String, double>{}.obs;

  final RxDouble discount = 0.0.obs;

  final TextEditingController noteController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  // =========================
  // Products
  // =========================

  List<ProductItemModel> get products => productController.products;

  // =========================
  // Cart
  // =========================

  bool isSelected(String productId) {
    return quantities.containsKey(productId);
  }

  double quantityOf(String productId) {
    return quantities[productId] ?? 0;
  }

  double purchasePriceOf(ProductItemModel product) {
    return purchasePrices[product.id] ?? product.purchasePrice;
  }

  void addProduct(ProductItemModel product) {
    final currentQty = quantities[product.id] ?? 0;

    quantities[product.id] = currentQty + 1;

    // First time product is selected:
    // initialize today's purchase price from existing product price.
    purchasePrices.putIfAbsent(product.id, () => product.purchasePrice);
  }

  void decrementProduct(ProductItemModel product) {
    final currentQty = quantities[product.id] ?? 0;

    if (currentQty <= 1) {
      removeProduct(product.id);
      return;
    }

    quantities[product.id] = currentQty - 1;
  }

  void removeProduct(String productId) {
    quantities.remove(productId);
    purchasePrices.remove(productId);
  }

  void clearCart() {
    quantities.clear();
    purchasePrices.clear();

    discount.value = 0;

    discountController.clear();
    noteController.clear();
  }

  // =========================
  // Purchase Price
  // =========================

  void updatePurchasePrice(String productId, String value) {
    final price = double.tryParse(value);

    if (price == null || price < 0) {
      return;
    }

    purchasePrices[productId] = price;
  }

  // =========================
  // Discount
  // =========================

  void updateDiscount(String value) {
    discount.value = double.tryParse(value) ?? 0;
  }

  // =========================
  // Totals
  // =========================

  double get subtotal {
    double total = 0;

    quantities.forEach((productId, quantity) {
      final product = products.firstWhereOrNull(
        (product) => product.id == productId,
      );

      if (product == null) return;

      final price = purchasePriceOf(product);

      total += price * quantity;
    });

    return total;
  }

  double get totalAmount {
    final total = subtotal - discount.value;

    return total < 0 ? 0 : total;
  }

  double lineTotal(ProductItemModel product) {
    return quantityOf(product.id) * purchasePriceOf(product);
  }

  // =========================
  // Build RPC Items
  // =========================

  List<PurchaseItemModel> buildPurchaseItems() {
    final List<PurchaseItemModel> items = [];

    quantities.forEach((productId, quantity) {
      final product = products.firstWhereOrNull(
        (product) => product.id == productId,
      );

      if (product == null) return;

      items.add(
        PurchaseItemModel(
          productId: product.id,
          article: product.article,
          color: product.color,
          size: product.size,
          unit: product.unit,
          quantity: quantity,
          purchasePrice: purchasePriceOf(product),
        ),
      );
    });

    return items;
  }

  // =========================
  // Create Purchase
  // =========================

  Future<String?> createPurchase() async {
    if (quantities.isEmpty) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: AppConstants.noProductsSelected,
      );

      return null;
    }

    if (discount.value < 0) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.invalidDiscount,
        message: AppConstants.discountNegative,
      );

      return null;
    }

    if (discount.value > subtotal) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.invalidDiscount,
        message: AppConstants.discountExceedSubtotal,
      );

      return null;
    }

    if (!await NetworkManager.instance.checkInternet()) {
      return null;
    }

    try {
      isLoading.value = true;

      final items = buildPurchaseItems();

      final purchaseId = await repository.createPurchase(
        items: items,
        discount: discount.value,
        notes: noteController.text,
      );

      // Refresh products because database stock
      // and purchase prices have changed.
      await productController.fetchProducts();

      clearCart();

      // Refresh Home Dashboard Data
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomeData();
      }

      return purchaseId;
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.purchaseFailed,
        message: exception.message,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // PURCHASE LIST
  // ============================================================

  Future<void> fetchPurchases() async {
    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isPurchasesLoading.value = true;
      final result = await repository.getPurchases();

      purchases.assignAll(result);
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isPurchasesLoading.value = false;
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void searchPurchases(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  // ============================================================
  // FILTER
  // ============================================================

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  // ============================================================
  // FILTERED PURCHASES
  // ============================================================

  List<PurchaseModel> get filteredPurchases {
    Iterable<PurchaseModel> result = purchases;

    // Search
    if (searchQuery.value.isNotEmpty) {
      result = result.where((purchase) {
        final query = searchQuery.value;

        return purchase.purchaseNo.toLowerCase().contains(query) ||
            purchase.totalAmount.toString().contains(query);
      });
    }

    // Status Filter
    switch (selectedFilter.value) {
      case 1:
        result = result.where(
          (purchase) => purchase.status.toLowerCase() == 'completed',
        );
        break;

      case 2:
        result = result.where(
          (purchase) => purchase.status.toLowerCase() == 'void',
        );
        break;
    }

    return result.toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }
}
