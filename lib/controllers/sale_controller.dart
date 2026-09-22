import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:stockpulse/controllers/homecontroller.dart';

import '../models/productItemModel.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../repositories/sale_repository.dart';
import 'allProductsController.dart';

class SaleController extends GetxController {
  final SaleRepository repository;
  final ProductController productController;

  SaleController({
    required this.repository,
    required this.productController,
  });

  // ============================================================
  // STATE
  // ============================================================

  final RxBool isLoading = false.obs;
  final RxBool isSalesLoading = false.obs;

  /// productId -> quantity
  final RxMap<String, double> quantities =
      <String, double>{}.obs;

  /// Allows sale price to be changed for this sale only.
  final RxMap<String, double> salePrices =
      <String, double>{}.obs;

  final RxDouble discount = 0.0.obs;

  final RxString paymentMethod = 'cash'.obs;

  final RxList<SaleModel> sales =
      <SaleModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxInt selectedFilter = 0.obs;

  final TextEditingController noteController =
  TextEditingController();

  final TextEditingController discountController =
  TextEditingController();

  final TextEditingController searchController =
  TextEditingController();

  final TextEditingController receivedAmountController =
  TextEditingController();

  final List<String> filters = const [
    'All',
    'Completed',
    'Cancelled',
  ];

  // ============================================================
  // PRODUCTS
  // ============================================================

  List<ProductItemModel> get products =>
      productController.products;

  bool isSelected(String productId) =>
      quantities.containsKey(productId);

  double quantityOf(String productId) =>
      quantities[productId] ?? 0;

  double salePriceOf(ProductItemModel product) =>
      salePrices[product.id] ?? product.salePrice;

  // ============================================================
  // CART
  // ============================================================

  void addProduct(ProductItemModel product) {
    final currentQty = quantityOf(product.id);

    if (product.currentStock <= 0) {
      Get.snackbar(
        'Out of Stock',
        '${product.article} is currently out of stock.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentQty + 1 > product.currentStock) {
      Get.snackbar(
        'Insufficient Stock',
        'Only ${_formatQty(product.currentStock)} '
            '${product.unit} available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    quantities[product.id] = currentQty + 1;

    salePrices.putIfAbsent(
      product.id,
          () => product.salePrice,
    );
  }

  void decrementProduct(ProductItemModel product) {
    final currentQty = quantityOf(product.id);

    if (currentQty <= 1) {
      removeProduct(product.id);
      return;
    }

    quantities[product.id] = currentQty - 1;
  }

  void removeProduct(String productId) {
    quantities.remove(productId);
    salePrices.remove(productId);
  }

  void clearCart() {
    quantities.clear();
    salePrices.clear();

    discount.value = 0;
    paymentMethod.value = 'cash';

    discountController.clear();
    noteController.clear();
    receivedAmountController.clear();
  }

  // ============================================================
  // SALE PRICE
  // ============================================================

  void updateSalePrice(
      String productId,
      String value,
      ) {
    final price = double.tryParse(value);

    if (price == null || price < 0) {
      return;
    }

    salePrices[productId] = price;
  }

  // ============================================================
  // DISCOUNT
  // ============================================================

  void updateDiscount(String value) {
    discount.value =
        double.tryParse(value) ?? 0;
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  void changePaymentMethod(String value) {
    final method = value.toLowerCase();

    if (method != 'cash' && method != 'card') {
      return;
    }

    paymentMethod.value = method;
  }

  // ============================================================
  // TOTALS
  // ============================================================

  double get subtotal {
    double total = 0;

    quantities.forEach(
          (productId, quantity) {
        final product =
        products.firstWhereOrNull(
              (item) => item.id == productId,
        );

        if (product == null) return;

        total +=
            salePriceOf(product) * quantity;
      },
    );

    return total;
  }

  double get totalAmount {
    final value =
        subtotal - discount.value;

    return value < 0 ? 0 : value;
  }

  double lineTotal(
      ProductItemModel product,
      ) {
    return quantityOf(product.id) *
        salePriceOf(product);
  }

  double get receivedAmount {
    final text =
    receivedAmountController.text.trim();

    if (text.isEmpty) {
      return totalAmount;
    }

    return double.tryParse(text) ??
        totalAmount;
  }

  double get changeAmount {
    final value =
        receivedAmount - totalAmount;

    return value > 0 ? value : 0;
  }

  int get totalItemsCount {
    return quantities.values.fold<int>(
      0,
          (sum, qty) => sum + qty.toInt(),
    );
  }

  // ============================================================
  // BUILD RPC ITEMS
  // ============================================================

  List<SaleItemModel> buildSaleItems() {
    final List<SaleItemModel> items = [];

    quantities.forEach(
          (productId, quantity) {
        final product =
        products.firstWhereOrNull(
              (item) => item.id == productId,
        );

        if (product == null) return;

        items.add(
          SaleItemModel(
            productId: product.id,
            article: product.article,
            color: product.color,
            size: product.size,
            unit: product.unit,
            quantity: quantity,
            salePrice:
            salePriceOf(product),
          ),
        );
      },
    );

    return items;
  }

  // ============================================================
  // CREATE SALE
  // ============================================================

  Future<String?> createSale() async {
    if (quantities.isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Please add at least one product.',
      );
      return null;
    }

    if (discount.value < 0) {
      Get.snackbar(
        'Invalid Discount',
        'Discount cannot be negative.',
      );
      return null;
    }

    if (discount.value > subtotal) {
      Get.snackbar(
        'Invalid Discount',
        'Discount cannot exceed subtotal.',
      );
      return null;
    }

    // Client validation.
    // DB RPC also validates this again.
    for (final entry in quantities.entries) {
      final product =
      products.firstWhereOrNull(
            (p) => p.id == entry.key,
      );

      if (product == null) {
        Get.snackbar(
          'Product Error',
          'A selected product could not be found.',
        );
        return null;
      }

      if (entry.value > product.currentStock) {
        Get.snackbar(
          'Insufficient Stock',
          '${product.article} only has '
              '${_formatQty(product.currentStock)} '
              '${product.unit} available.',
        );
        return null;
      }
    }

    try {
      isLoading.value = true;

      final saleId =
      await repository.createSale(
        items: buildSaleItems(),
        discount: discount.value,
        paymentMethod:
        paymentMethod.value,
        notes: noteController.text,
      );

      // IMPORTANT:
      // Replace fetchProducts() if your actual
      // ProductController uses another refresh method.
      await productController.fetchProducts();

      await fetchSales();

      // Refresh Home Dashboard Data
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomeData();
      }

      return saleId;
    } catch (e) {
      Get.snackbar(
        'Sale Failed',
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // SALES LIST
  // ============================================================

  Future<void> fetchSales() async {
    try {
      isSalesLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      final result =
      await repository.getSales();

      sales.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      isSalesLoading.value = false;
    }
  }

  // ============================================================
  // SALE LIST SEARCH/FILTER
  // ============================================================

  void searchSales(String value) {
    searchQuery.value =
        value.trim().toLowerCase();
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  List<SaleModel> get filteredSales {
    Iterable<SaleModel> result = sales;

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value;

      result = result.where(
            (sale) =>
        sale.saleNo
            .toLowerCase()
            .contains(query) ||
            sale.totalAmount
                .toString()
                .contains(query),
      );
    }

    switch (selectedFilter.value) {
      case 1:
        result = result.where(
              (sale) =>
          sale.status.toLowerCase() ==
              'completed',
        );
        break;

      case 2:
        result = result.where(
              (sale) =>
          sale.status.toLowerCase() ==
              'void',
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
    fetchSales();
  }
}