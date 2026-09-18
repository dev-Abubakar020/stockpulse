import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/productItemModel.dart';
import '../models/category_model.dart';
import '../repositories/product_repository.dart';
import 'allProductsController.dart';

class AddProductWizardController extends GetxController {
  // Step navigation (1, 2, 3)
  final RxInt currentStep = 1.obs;

  // STEP 1 Fields
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final Rxn<CategoryModel> selectedCategory =
  Rxn<CategoryModel>();
  final RxString selectedUnit = 'Piece (pcs)'.obs;
  final RxString imagePath = ''.obs;


  final categories = <CategoryModel>[].obs;
  final isCategoriesLoading = false.obs;

  final List<String> units = ['Piece (pcs)', 'Box', 'Kilogram (kg)', 'Litre (L)'];

  // STEP 2 Fields
  final purchasePriceController = TextEditingController();
  final salePriceController = TextEditingController();
  final RxInt initialStock = 24.obs;
  final RxInt lowStockLimit = 5.obs;
  final RxBool trackStock = true.obs;
  final RxBool activeForSale = true.obs;

  // Live computed values
  final RxDouble estimatedProfit = 60.0.obs;
  final RxDouble marginPercentage = 33.3.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-populate name or code as example mock if needed
    nameController.text = '';
    skuController.text = '';
    fetchCategories();
    // Add listeners to price changes for automatic margin calculation
    purchasePriceController.addListener(calculateMargin);
    salePriceController.addListener(calculateMargin);
  }

  void calculateMargin() {
    final double purchase = double.tryParse(purchasePriceController.text) ?? 0.0;
    final double sale = double.tryParse(salePriceController.text) ?? 0.0;

    if (sale > 0) {
      estimatedProfit.value = sale - purchase;
      marginPercentage.value = (estimatedProfit.value / sale) * 100;
    } else {
      estimatedProfit.value = 0.0;
      marginPercentage.value = 0.0;
    }
  }

  void incrementStock() => initialStock.value++;
  void decrementStock() {
    if (initialStock.value > 0) {
      initialStock.value--;
    }
  }

  void incrementLowStock() => lowStockLimit.value++;
  void decrementLowStock() {
    if (lowStockLimit.value > 0) lowStockLimit.value--;
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  Future<void> saveProduct() async {
    try {
      final repository = Get.find<ProductRepository>();

      final newProduct = ProductItemModel(
        id: '',

        article: nameController.text.trim(),

        categoryId: selectedCategory.value?.id,

        unit: selectedUnit.value,

        purchasePrice:
        double.tryParse(purchasePriceController.text) ?? 0.0,

        salePrice:
        double.tryParse(salePriceController.text) ?? 0.0,

        currentStock:
        initialStock.value.toDouble(),

        minStockThreshold:
        lowStockLimit.value.toDouble(),

        barcode: skuController.text.trim().isEmpty
            ? null
            : skuController.text.trim(),

        isActive: activeForSale.value,
      );

      await repository.addProduct(newProduct);

      // Refresh the all products controller list
      if (Get.isRegistered<ProductController>()) {
        Get.find<ProductController>().fetchProducts();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save product to database: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void nextStep() async {
    if (currentStep.value == 2) {
      await saveProduct();
    }
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  void resetWizard() {
    currentStep.value = 1;
    nameController.text = '';
    skuController.text = '5449000000996';
    purchasePriceController.text = '0';
    salePriceController.text = '0';
    selectedCategory.value = categories.isNotEmpty ? categories.first : null;
    selectedUnit.value = 'Piece (pcs)';
    initialStock.value = 24;
    lowStockLimit.value = 5;
    trackStock.value = true;
    activeForSale.value = true;
    calculateMargin();
  }

  @override
  void onClose() {
    purchasePriceController.removeListener(calculateMargin);
    salePriceController.removeListener(calculateMargin);
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      if (kDebugMode) {
        print('DEBUG: Fetching categories from Supabase repository...');
      }
      final repository = Get.find<ProductRepository>();

      final list = await repository.getCategories();
      if (kDebugMode) {
        print('DEBUG: Successfully retrieved ${list.length} categories from Supabase.');
      }
      for (var cat in list) {
        if (kDebugMode) {
          print('DEBUG: Category ID: ${cat.id}, Name: ${cat.name}, Active: ${cat.isActive}');
        }
      }
      
      categories.assignAll(list);

      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ERROR: Exception inside fetchCategories: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCategoriesLoading.value = false;
    }
  }
}
