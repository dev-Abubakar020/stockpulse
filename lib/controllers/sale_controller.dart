import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:stockpulse/controllers/homecontroller.dart';

import '../common/exceptional/platform_exceptions.dart';
import '../common/widgets/custom_snackbar.dart';
import '../models/productItemModel.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../repositories/sale_repository.dart';
import '../services/networkManager.dart';
import '../utils/app_constants.dart';
import 'allProductsController.dart';

class SaleController extends GetxController {
  final SaleRepository repository;
  final ProductController productController;

  SaleController({required this.repository, required this.productController});

  final RxBool isLoading = false.obs;
  final RxBool isSalesLoading = false.obs;
  final RxBool isSaleItemsLoading = false.obs;
  final RxList<SaleItemModel> currentSaleItems = <SaleItemModel>[].obs;
  final RxString creatorName = ''.obs;

  Future<void> fetchCreatorName(String saleId, {String? createdByUserId}) async {
    creatorName.value = await repository.getSaleCreatorName(
      saleId,
      createdByUserId: createdByUserId,
    );
  }

  /// productId -> quantity
  final RxMap<String, double> quantities = <String, double>{}.obs;

  /// Allows sale price to be changed for this sale only.
  // final RxMap<String, double> salePrices = <String, double>{}.obs;
  /// productId -> manually overridden line total
  final RxMap<String, double> lineTotals = <String, double>{}.obs;
  final RxDouble discount = 0.0.obs;

  final RxString paymentMethod = 'cash'.obs;

  final RxList<SaleModel> sales = <SaleModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxInt selectedFilter = 0.obs;

  final TextEditingController noteController = TextEditingController();

  final TextEditingController discountController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  final TextEditingController receivedAmountController =
      TextEditingController();

  final List<String> filters = const ['All', 'Completed', 'Cancelled'];

  List<ProductItemModel> get products => productController.products;

  bool isSelected(String productId) => quantities.containsKey(productId);

  double quantityOf(String productId) => quantities[productId] ?? 0;
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

  void addProduct(ProductItemModel product) {
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
  }

  void decrementProduct(ProductItemModel product) {
    final currentQty = quantityOf(product.id);
    final step = quantityStep(product);

    final newQty = normalizeQuantity(currentQty - step);

    if (newQty <= 0) {
      removeProduct(product.id);
      return;
    }

    quantities[product.id] = newQty;

    // Quantity changed → calculate fresh line total
    lineTotals.remove(product.id);
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
  }

  void clearCart() {
    quantities.clear();
    lineTotals.clear();
    discount.value = 0;
    paymentMethod.value = 'cash';

    discountController.clear();
    noteController.clear();
    receivedAmountController.clear();
  }
  double lineTotal(ProductItemModel product) {
    return lineTotals[product.id] ??
        (quantityOf(product.id) * product.salePrice);
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
    if (product != null && product.salePrice > 0) {
      final newQty = amount / product.salePrice;
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

  void updateDiscount(String value) {
    discount.value = double.tryParse(value) ?? 0;
  }

  void changePaymentMethod(String value) {
    final method = value.toLowerCase();

    if (method != 'cash' && method != 'card') {
      return;
    }

    paymentMethod.value = method;
  }

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

  double get totalAmount {
    final value = subtotal - discount.value;

    return value < 0 ? 0 : value;
  }


  double get receivedAmount {
    final text = receivedAmountController.text.trim();

    if (text.isEmpty) {
      return totalAmount;
    }

    return double.tryParse(text) ?? totalAmount;
  }

  double get changeAmount {
    final value = receivedAmount - totalAmount;

    return value > 0 ? value : 0;
  }

  int get totalItemsCount {
    return quantities.values.fold<int>(0, (sum, qty) => sum + qty.toInt());
  }

  List<SaleItemModel> buildSaleItems() {
    final List<SaleItemModel> items = [];

    quantities.forEach((productId, quantity) {
      final product =
      products.firstWhereOrNull((item) => item.id == productId);

      if (product == null || quantity <= 0) return;

      final total = lineTotal(product);

      // Effective unit price based on final line total
      final effectiveSalePrice = total / quantity;

      items.add(
        SaleItemModel(
          productId: product.id,
          article: product.article,
          color: product.color,
          size: product.size,
          unit: product.unit,
          quantity: quantity,
          salePrice: effectiveSalePrice,
        ),
      );
    });

    return items;
  }

  Future<String?> createSale() async {
    if (isLoading.value) return null;
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

    for (final entry in quantities.entries) {
      final product = products.firstWhereOrNull((p) => p.id == entry.key);

      if (product == null) {
        CustomSnackBar.errorSnackBar(
          title: AppConstants.productError,
          message: 'A selected product could not be found.',
        );
        return null;
      }

      if (entry.value > product.currentStock) {
        CustomSnackBar.warningSnackBar(
          title: AppConstants.insufficientStock,
          message:
              '${product.article} only has ${_formatQty(product.currentStock)} ${product.unit} available.',
        );
        return null;
      }
    }

    if (!await NetworkManager.instance.checkInternet()) {
      return null;
    }

    try {
      isLoading.value = true;
      final saleId = await repository.createSale(
        items: buildSaleItems(),
        discount: discount.value,
        paymentMethod: paymentMethod.value,
        notes: noteController.text,
      );

      await productController.fetchProducts();
      await fetchSales();

      // Refresh Home Dashboard Data
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHomeData();
      }

      return saleId;
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.saleFailed,
        message: exception.message,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSales() async {
    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isSalesLoading.value = true;
      final result = await repository.getSales();

      sales.assignAll(result);
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isSalesLoading.value = false;
    }
  }

  Future<void> fetchSaleItems(String saleId) async {
    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isSaleItemsLoading.value = true;
      final items = await repository.getSaleItems(saleId);
      currentSaleItems.assignAll(items);
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isSaleItemsLoading.value = false;
    }
  }

  void searchSales(String value) {
    searchQuery.value = value.trim().toLowerCase();
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
            sale.saleNo.toLowerCase().contains(query) ||
            sale.totalAmount.toString().contains(query),
      );
    }

    switch (selectedFilter.value) {
      case 1:
        result = result.where(
          (sale) => sale.status.toLowerCase() == 'completed',
        );
        break;

      case 2:
        result = result.where((sale) => sale.status.toLowerCase() == 'void');
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
