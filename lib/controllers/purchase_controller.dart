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
  final RxBool isPurchaseItemsLoading = false.obs;
  final RxList<PurchaseItemModel> currentPurchaseItems = <PurchaseItemModel>[].obs;
  final RxString creatorName = ''.obs;

  Future<void> fetchCreatorName(String userId) async {
    creatorName.value = 'Loading...';
    creatorName.value = await repository.getUserName(userId);
  }

  final RxString searchQuery = ''.obs;

  final RxInt selectedFilter = 0.obs;

  final TextEditingController searchController = TextEditingController();

  final List<String> filters = const ['All', 'Completed', 'Cancelled'];

  /// productId -> quantity
  final RxMap<String, double> quantities = <String, double>{}.obs;

  /// productId -> current purchase price for THIS purchase
  // final RxMap<String, double> purchasePrices = <String, double>{}.obs;

  final RxMap<String, double> lineTotals = <String, double>{}.obs;
  final RxDouble discount = 0.0.obs;

  final TextEditingController noteController = TextEditingController();

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

  double quantityOf(String productId) {return quantities[productId] ?? 0;}
  bool isDecimalUnit(ProductItemModel product) {
    return product.unit == 'Kilogram (kg)' ||
        product.unit == 'Litre (L)' ||
        product.unit == 'Meter (m)';
  }
  double quantityStep(ProductItemModel product) {
    return isDecimalUnit(product) ? 0.1 : 1.0;
  }

  double normalizeQuantity(double value) {
    return double.parse(value.toStringAsFixed(3));
  }
  // double purchasePriceOf(ProductItemModel product) {
  //   return purchasePrices[product.id] ?? product.purchasePrice;
  // }

  void addProduct(ProductItemModel product) {
    // final currentQty = quantities[product.id];
    final currentQty = quantityOf(product.id);
    if (product.currentStock <= 0) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.outOfStock,
        message: '${product.article} is currently out of stock.',
      );
      return;
    }
    double newQty;
    if (!isSelected(product.id) || currentQty <= 0) {
      newQty = isDecimalUnit(product) ? 0.5 : 1.0;
    } else {
      final step = quantityStep(product);
      newQty = normalizeQuantity(currentQty + step);
    }

    if (newQty > product.currentStock) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.insufficientStock,
        message:
        'Only ${_formatQty(product.currentStock)} ${product.unit} available.',
      );
      return;
    }

    quantities[product.id] = newQty;
    lineTotals.remove(product.id);

    // First time product is selected:
    // initialize today's purchase price from existing product price.
    // purchasePrices.putIfAbsent(product.id, () => product.purchasePrice);
  }

  void decrementProduct(ProductItemModel product) {
    final currentQty = quantities[product.id] ?? 0;

    if (currentQty <= 1) {
      removeProduct(product.id);
      return;
    }

    quantities[product.id] = currentQty - 1;
  }

  void updateQuantity(ProductItemModel product, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      // Do not remove product or update while user is temporarily clearing the field during typing.
      return;
    }

    var normalized = trimmed.startsWith('.') ? '0$trimmed' : trimmed;
    if (normalized.endsWith('.')) {
      normalized = '${normalized}0';
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return;
    }

    if (parsed > product.currentStock) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.insufficientStock,
        message:
        'Only ${_formatQty(product.currentStock)} ${product.unit} available.',
      );
      quantities[product.id] = normalizeQuantity(product.currentStock);
      lineTotals.remove(product.id);
      return;
    }

    quantities[product.id] = normalizeQuantity(parsed);
    lineTotals.remove(product.id);
  }
  void removeProduct(String productId) {
    quantities.remove(productId);
    lineTotals.remove(productId);
    // purchasePrices.remove(productId);
  }

  void clearCart() {
    quantities.clear();
    lineTotals.clear();
    // purchasePrices.clear();
    noteController.clear();
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
      final product =
      products.firstWhereOrNull((item) => item.id == productId);

      if (product == null) return;

      total += lineTotal(product);
    });

    return total;
  }
  // double get subtotal {
  //   double total = 0;
  //
  //   quantities.forEach((productId, quantity) {
  //     final product = products.firstWhereOrNull(
  //       (product) => product.id == productId,
  //     );
  //
  //     if (product == null) return;
  //
  //     final price = purchasePriceOf(product);
  //
  //     total += price * quantity;
  //   });
  //
  //   return total;
  // }

  double get totalAmount {
    final total = subtotal;

    return total < 0 ? 0 : total;
  }

  double lineTotal(ProductItemModel product) {
    return lineTotals[product.id] ?? quantityOf(product.id) * product.purchasePrice;
  }
  void updateLineTotal(String productId, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      lineTotals.remove(productId);
      return;
    }

    final amount = double.tryParse(trimmed);
    if (amount == null || amount < 0) return;

    lineTotals[productId] = amount;

    final product = products.firstWhereOrNull((p) => p.id == productId);
    if (product != null && product.purchasePrice > 0) {
      final newQty = amount / product.purchasePrice;
      if (newQty > product.currentStock) {
        CustomSnackBar.warningSnackBar(
          title: AppConstants.insufficientStock,
          message:
          'Only ${_formatQty(product.currentStock)} ${product.unit} available.',
        );
        quantities[productId] = normalizeQuantity(product.currentStock);
      } else {
        quantities[productId] = normalizeQuantity(newQty < 0 ? 0 : newQty);
      }
    }
  }
  // =========================
  // Build RPC Items
  // =========================

  List<PurchaseItemModel> buildPurchaseItems() {
    final List<PurchaseItemModel> items = [];

    quantities.forEach((productId, quantity) {
      final product =
      products.firstWhereOrNull((item) => item.id == productId);

      if (product == null || quantity <= 0) return;

      final total = lineTotal(product);

      // Effective unit price based on final line total
      final effectivePurchasePrice = total / quantity;

      items.add(
        PurchaseItemModel(
          productId: product.id,
          article: product.article,
          color: product.color,
          size: product.size,
          unit: product.unit,
          quantity: quantity,
          purchasePrice: effectivePurchasePrice,
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

    if (!await NetworkManager.instance.checkInternet()) {
      return null;
    }
    try {
      isLoading.value = true;

      final items = buildPurchaseItems();

      final purchaseId = await repository.createPurchase(
        items: items,
        notes: noteController.text,
      );


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

  Future<void> fetchPurchaseItems(String purchaseId) async {
    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isPurchaseItemsLoading.value = true;
      final items = await repository.getPurchaseItems(purchaseId);
      currentPurchaseItems.assignAll(items);
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isPurchaseItemsLoading.value = false;
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

  String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }
}
